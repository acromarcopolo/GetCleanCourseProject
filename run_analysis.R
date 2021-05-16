# Project data was manually downloaded & unzipped from:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

# Full description of the data:
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

library(data.table)
library(dplyr)
library(tibble)


########################################################################
# Task #1. Merge the training and the test sets to create one data set
########################################################################
merge_traintest <- function( trainfile, testfile ){
  # train & test sets (respectively 21 and 9 individuals, 
  # each with 300+ observations
  train_tbl <- as_tibble(fread( trainfile ))
  test_tbl <- as_tibble(fread( testfile ))
  
  # Ensure column names() do match
  if( !identical(names(test_tbl), names(train_tbl)) == T ){
    message("inconsistent data")
    break
  }# Stack up ALL the rows of training and test sets 
  rbind(train_tbl, test_tbl)
}

########################################################################
# Task #2.  Extract only the mean and standard deviation measurements
#           for each "measurement" (observation/feature)
########################################################################
extract_meanstd <- function( mytbl, featurefile ){
  # Get array of 561 column names (all variables of each feature vector)
  # and apply to merged data set
  colnames( mytbl ) <- fread( featurefile )$V2
  
  # Select only those measurements (columns) from all observations (rows):
  # I decided to take that only variables with mean() and std() as only they 
  # contain BOTH "mean and standard deviation for each measurement". 
  # But this is just my subjective interpretation.
  select( mytbl, contains("mean()")|contains("std()") )
}


########################################################################
# Task #3. Use descriptive activity names to name the activities in the data set
########################################################################
set_activities <- function( mytbl, trainfile, testfile ){
  
  # Concatenate subject IDs in the same row order we did for the train & test data
  activity_IDs <- rbind( fread( trainfile ), fread( testfile ) )
  
  # Check data is consistent
  stopifnot( length( activity_IDs$V1 ) == dim(mytbl)[1] )
  
  # Replace IDs by descriptive activity names (labels)
  activity_labels <- c("Walking", 
                       "WalkingUpstairs", 
                       "WalkingDownstairs",
                       "Sitting",
                       "Standing",
                       "Laying")
  activity_names <- as.character(sapply( activity_IDs, 
                                         function(x){activity_labels[x]} ))
  
  # Insert as first column named "Activity" 
  mytbl %>% add_column( Activity = activity_names, .before = 1 )
}

########################################################################
# Task #4. Appropriately labels the data set with descriptive variable names. 
# One way is to transform tBodyAcc-mean()-X into tBodyAccMeanX, etc.
########################################################################
relabel_variables <- function( mytbl ){
  # Make mytbl's variable names more descriptive in meanstd_colnames_desc
  
  # Remove special characters:
  meanstd_colnames_desc <- gsub( "[\\,\\-\\(\\)]","", names( mytbl ), perl=T )
  # Make the mean and standard deviation strings clearer:
  meanstd_colnames_desc <- gsub( "mean","Mean", meanstd_colnames_desc )
  meanstd_colnames_desc <- gsub( "std","Stdev", meanstd_colnames_desc )
  # Replace leading t/f by time/frequency, let "Activity" pass through:
  tf <- tibble( t = "Time", f = "Freq" )
  meanstd_colnames_desc <- 
    as.character(sapply(meanstd_colnames_desc, 
                        function(x){
                          t_or_f <- tf[[substr(x,1,1)]]
                          ifelse(is.null( t_or_f ),
                                 x,
                                 paste0(t_or_f, substr(x, 2, nchar(x))))
                        }))
  
  # Apply new column names to data set merged & reduced to mean() and std()
  colnames( mytbl ) <- meanstd_colnames_desc
  invisible( mytbl )
}


########################################################################
# Task #5.  From the data set in step 4, creates a second, independent 
#           tidy data set with the average of each variable for each 
#           activity and each subject.
########################################################################
add_subjects <- function( mytbl, trainfile, testfile ){
  # Get row names, as subject IDs already aligned with data 
  subject_train <- fread( trainfile )
  subject_test <- fread( testfile )
  
  # Pile up Subject IDs in same order as we did when merging train & test sets
  subject_IDs <- rbind(subject_train, subject_test)

  # Ensure same length as  train & test sets
  stopifnot( length( subject_IDs$V1 ) == dim(mytbl)[1] )

  # Insert column identifying the subject for each record, as new 1st column
  mytbl %>% add_column( Subject = subject_IDs$V1, .before = 1)
}

# Put it all together in final pipeline
final_tbl <-
  merge_traintest( "UCI HAR Dataset/train/X_train.txt",
                   "UCI HAR Dataset/test/X_test.txt" )  %>%
  extract_meanstd( "UCI HAR Dataset/features.txt") %>%
  set_activities( "UCI HAR Dataset/train/y_train.txt",
                  "UCI HAR Dataset/test/y_test.txt") %>%
  relabel_variables %>%
  add_subjects( "UCI HAR Dataset/train/subject_train.txt", 
                "UCI HAR Dataset/test/subject_test.txt") %>%
  # Group variables by activity then by subject...
  group_by( Activity , Subject ) %>%
  # .. to calculate average "for each activity and each subject"
  summarize(across( everything(), mean )) %>%
  print

# Save in a tab delimited text file
out_file <- "TrainTest.MeanStdev.txt"
fwrite( final_tbl, file=out_file, sep="\t" )
cat( "Result tidy tibble written to file:",out_file,"\n" )

