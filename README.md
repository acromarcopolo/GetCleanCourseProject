This code book explains the data, variables and functions used in
*run_analysis.R* script for Coursera’s Data Cleaning course’s week4
project. The functions described below are combined in the script into a
pipeline that calculates the average of each variable for each activity
and each subject.  

## **Script Name:** *run_analysis.R*

------------------------------------------------------------------------

### Data Sets

Project data can be manually downloaded & unzipped
<a href="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" class="uri">from here.</a>

Based on the unzipped data file, the files used by ***run_analysis.R***
are:

| Associated R variable name | File name in “UCI HAR Dataset” folder | File content                                |
|----------------------------|---------------------------------------|---------------------------------------------|
| train_tbl                  | train/**X_train.txt**                 | training set, 300+ obs. / each 21 subjects  |
| test_tbl                   | test/**X_test.txt**                   | test set, 300+ obs. / each 9 subjects       |
| (featurefile)              | **features.txt**                      | array of 561 names for each variable        |
| (trainfile)                | train/**y_train.txt**                 | activity IDs of the training set (all rows) |
| (testfile)                 | test/**y_test.txt**                   | activity IDs of the test set (all rows)     |
| subject_train              | train/**subject_train.txt**           | subject IDs of the training set (all rows)  |
| subject_test               | test/**subject_test.txt**             | subject IDs of the test set (all rows)      |
| out_file                   | **TrainTest.MeanStdev.txt**           | tidy dataset produced by the script         |

<a href="http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones" class="uri">Click here for the full description of the data, including units, etc.</a>

------------------------------------------------------------------------

### Main Variables

**`final_tbl`** (a tibble: 180 x 68): final tidy data set as per task
\#5, with the average of each variable for each activity and each
subject.

**`activity_IDs`** 1 column data table of concatenated (training + test
sets) activity IDs for each observation (in `set_activities()`)

**`activity_names`** character array of activity names, translated from
**`activity_IDs`** (in `set_activities()`)

**`meanstd_colnames_desc`** descriptive variable names for column labels
(in `relabel_variables()`)

**`subject_IDs`** 1 column data table of concatenated (training + test
sets) subject IDs for each observation (in `add_subjects()`)

------------------------------------------------------------------------

### Functions

#### `merge_traintest( trainfile, testfile )`

> `trainfile`: text file name (full path) with all observations for
> subjects in the training set
>
> `textfile`: text file name (full path) with all observations for
> subjects in the test set
>
> RETURNS: Stacked up the rows of the training and test sets

#### `extract_meanstd( mytbl, featurefile )`

> `mytbl`: input tibble, whose variable (column) names will be extracted
> based on keywords mean() and std().
>
> `featurefile`: text file name (full path) with all variable names
> (columns)
>
> RETURNS: tibble with same observations as input, but only variables
> containing “mean()” and “std()”, because only they contain BOTH “mean
> and standard deviation for each measurement”. But this is subject to
> interpretation, and using keywords “mean” and “Mean” would retrieve
> more columns.

#### `set_activities( mytbl, trainfile, testfile )`

> `mytbl`: input tibble, where activity column is to be added.
>
> `trainfile`: text file name (full path) with all activity IDs for
> subjects in the training set
>
> `textfile`: text file name (full path) with all activity IDs for
> subjects in the test set
>
> RETURNS: the tibble, with activity labels added as 1st column

#### `relabel_variables( mytbl )`

> `mytbl`: input tibble, whose variable (column) names will be modified
>
> RETURNS: the tibble, with more descriptive variable (column) names

#### `averageby_subject_activity( mytbl, trainfile, testfile )`

> `mytbl`: input tibble, without subject IDs
>
> `trainfile`: text file name (full path) with all subject IDs for
> subjects in the training set
>
> `testfile`: text file name (full path) with all subject IDs for
> subjects in the test set
>
> RETURNS: the reduced tidy tibble, with individual subject IDs added,
> and each variable averaged for each activity and each subject. Units
> are the same as the original averaged values.
