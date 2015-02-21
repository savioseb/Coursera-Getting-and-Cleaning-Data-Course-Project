'

    Coursera Getting and Cleaning Data - Course Project
    Human Activity Recognition (HAR) Using Smartphones Dataset Version 1.0
    ----------------------------------------------------------------------
    Author: Savio Sebastian

    Functions are defined in the beginning so that as R interprets the code
    it will have the latest version of the function - as opposed to running a
    function that has already been read into memory and is outdated.

    The actual running code is at the bottom of this script.

    This is a multi-line comment.
    ---------------------------------------------------------------------------
    
'


## Global Variables
DOWNLOAD_AND_UNZIP <- T                         # flag variable - whether the dataset zip file must be downloaded and extracted - FALSE - if not required

## DATA FILENAMES
TEST_DATA_FILE_FEATURE <- "UCI HAR Dataset/test/X_test.txt"
TEST_DATA_FILE_ACTIVITY <- "UCI HAR Dataset/test/y_test.txt"
TEST_DATA_FILE_SUBJECT <- "UCI HAR Dataset/test/subject_test.txt"

TRAIN_DATA_FILE_FEATURE <- "UCI HAR Dataset/train/X_train.txt"
TRAIN_DATA_FILE_ACTIVITY <- "UCI HAR Dataset/train/y_train.txt"
TRAIN_DATA_FILE_SUBJECT <- "UCI HAR Dataset/train/subject_train.txt"

DATA_FILE_ACTIVITY_LABELS <- "UCI HAR Dataset/activity_labels.txt"
DATA_FILE_FEATURE_LABELS <- "UCI HAR Dataset/features.txt"


## This function downloads the dataset Zip File and extracts it
downloadAndUnzip <- function(){
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    message( paste( Sys.time() , "Downloading File from URL: " , url ) )
    fileName <- "getdata-projectfiles-UCI HAR Dataset.zip"
    download.file( url=url , destfile = fileName , method = "curl" , quiet = T )
    unzip( fileName )
    message( paste( Sys.time() , "Data Set zip file downloaded & extracted for further analysis." ) )
}


## READ TABLE WRAPPER - to do away with redundant Code
readTableWrapper <- function( fileName ) {
    message( paste( Sys.time() , "Reading Data File:" , fileName ) )
    return( read.table(  fileName ) )
}


## Function to read and merge the data Sets.
## featureFile - Feature Data file name
## activityFile - activity Data file name
## subjectFile - subject Data File Name
## returns a Merged Data Frame with Feature, Activity and Subject Data
dataSetBuilder <- function( featureFile , activityFile , subjectFile ) {
    ds <- readTableWrapper( featureFile )
    ds[,562] <- readTableWrapper( activityFile )
    ds[,563] <- readTableWrapper( subjectFile )
    return( ds )
}


## Function to print Data Sets
## This will be used to give a summary of the Data Set through it's various Transformations
printingDS <- function( dsName, ds ) {
    message( paste( Sys.time() , "DataSet Name: " , dsName ) )
    message( paste( "No of Observations:" , dim( ds )[1] , 
                   "     No of Variables:" , dim( ds )[2] ) )
    message( "Compact Display of Structure (top 3 + bottom 3 rows of str) :" );
    message( str( ds , list.len = 3) )
    if( dim(ds)[2] > 5 ) {
        last3ColumnNumber <- dim(ds)[2]-2
        lastColumnNumber <- dim(ds)[2]
        message( str( ds[, last3ColumnNumber:lastColumnNumber ] , list.len = 3) )
    }
}


## Function to Merge the Training & Testing Data Sets
## It first merges the Feature + Activity + Subject Data First and 
## then does a Row Binding of 
## - 7352 Rows (obs) x 563 Columns (variables) - Training Data &
## - 2947 Rows (obs) x 563 Columns (variables) of Testing Data
loadAndMergeDataSets <- function() {
    message( paste( Sys.time() , "STEP 1 - LOAD AND MERGE DATA SETS (TRAINING AND TESTING):START " ) )
    ## Read and Column Merge the Training Feature Data + Activity Data + Subject Data
    dsTraining <<- dataSetBuilder( 
        TRAIN_DATA_FILE_FEATURE,  TRAIN_DATA_FILE_ACTIVITY, TRAIN_DATA_FILE_SUBJECT)
    printingDS( "dsTraining" , dsTraining )
        
    ## Read and Column Merge the Testing Feature Data + Activity Data + Subject Data
    dsTesting <<- dataSetBuilder(
        TEST_DATA_FILE_FEATURE, TEST_DATA_FILE_ACTIVITY, TEST_DATA_FILE_SUBJECT )
    printingDS( "dsTesting" , dsTesting )
    
    # Merge training and test sets together
    dsMerged <<- rbind( dsTraining, dsTesting )
    printingDS( "dsMerged" , dsMerged )
}

## Function to make the Feature Names More Easy To Read
## This is actually a part of STEP 4
## This is a part of appropriately labelling the data set with descriptive variable names
loadFeaturesList <- function() {
    ## Read features and make the feature names better suited for R with some substitutions
    dsFeatureLabels <<- read.table( DATA_FILE_FEATURE_LABELS)
    dsFeatureLabels[,2] <<- gsub( pattern = "-mean", replacement = "Mean",  x = eval.parent( dsFeatureLabels[,2] ) ) 
    dsFeatureLabels[,2] <<- gsub( pattern = "-std", replacement = "Std", x = dsFeatureLabels[,2])
    dsFeatureLabels[,2] <<- gsub( pattern = "[-()]", replacement = "", x = dsFeatureLabels[,2])
    printingDS( "dsFeatureLabels" , dsFeatureLabels )
}


## Function to compuete the Number of Columns Required
## This is a part of Step 2
computeColumnsRequired <- function() {
    message( paste( Sys.time() , "STEP 2 - EXTRACT ONLY MEAN AND STD DEVIATION MEASUREMENTS: START " ) )
    # Get only the data on mean and std. dev.
    columnsRequired <<- grep( ".*Mean.*|.*Std.*" , dsFeatureLabels[,2])
    # Reduce the features table to what we want
    dsFeatureLabels <<- dsFeatureLabels[ columnsRequired , ]
    # Add the Last two columns (activity and subject)
    columnsRequired <<- c( columnsRequired, 562, 563)
    printingDS( "dsFeatureLabels" , dsFeatureLabels )
}


## Function to Extract the Required Columns from the Data Set
## Part of Step 2
extractData <- function() {
    # Remove the unwanted columns from dsMerged
    dsExtract <<- dsMerged[ , columnsRequired ]
    printingDS( "dsExtract" , dsExtract )
}

## Function to read the Activity Labels and set it on the Data Set
## Step 3
putDescriptiveActivityNames <- function() {
    activityLabelColumnNumber <- dim( dsFeatureLabels)[1]+1
    message( paste( Sys.time() , "STEP 3 - USE DESCRIPTIVE ACTIVITY NAMES IN THE DATASET : START" ) )
    message( "Before Change - head Rows of Activity Column: " )
    print( head( dsExtract[ , activityLabelColumnNumber ] ) )
    ## Read the Activity Labels
    dsActivityLabels <<- read.table( DATA_FILE_ACTIVITY_LABELS )
    printingDS( "dsActivityLabels" , dsActivityLabels )
    activityLabelNameColumn <<- dsActivityLabels[ dsExtract[  ,  activityLabelColumnNumber ] , 2 ]
    dsExtract[ , activityLabelColumnNumber ] <<- activityLabelNameColumn
    message( paste( Sys.time() , "After Change - head Rows of Activity Column: " ) )
    print( head( dsExtract[ , activityLabelColumnNumber ] ) )
    printingDS( "dsExtract" , dsExtract )
}


## Function to put the Feature Labes onto the Data Set
## STEP 4
putFeatureLabels <- function() {
    message( paste( Sys.time() , "STEP 4 - APPROPRIATELY TABLE DATASET WITH DESCRIPTIVE NAMES: START" ) )
    message( "Before change: " )
    printingDS( "dsExtract", dsExtract )
    # Add the column labels (features) to dsExtract
    colnames( dsExtract ) <<- c( dsFeatureLabels$V2 , "Activity" , "Subject" )
    message( paste( Sys.time() , "AFTER change: " ) )
    printingDS( "dsExtract", dsExtract )
}



## Function to Generate the Tidy DataSet
## STEP 5 - Tidy data set with the average of each variable for each activity and each subject
generateTidyDataSet <- function() {
    message( paste( Sys.time() , "STEP 5 - TIDY DATA SET WITH THE AVERAGE OF EACH VARIABLE FOR EACH ACTIVITY AND EACH SUBJECT: START "))
    dsTidy <<- aggregate( 
        dsExtract , 
        by = list( Activity = dsExtract$Activity, Subject = dsExtract$Subject ) ,
        mean)
    
    ## Remove the Activity and Subject Columns since they are the 2 columns aggregated by
    ## and hence appear in the 1st 2 columns of the Data Set
    dsTidy[,90] <<- NULL
    dsTidy[,89] <<- NULL
    
    printingDS( "dsTidy" , dsTidy )
    
    ## write the tidy Data Set to File
    write.table( dsTidy , "tidy.txt" )
}


## Main Function - Control Function
mainFunction <- function() {
    sysTProfile <<- list()
    
    if( DOWNLOAD_AND_UNZIP ) {
        sysTDownload <<- system.time( downloadAndUnzip() )         # download & unzip the Zip File
        sysTProfile[[ "sysTDownload" ]] <<- sysTDownload
    }
    
    ## STEP 1 - Merge Testing and Training Data Sets 
    sysTLoadMerge <<- system.time ( loadAndMergeDataSets() )              # load and merge the training and test data sets
    sysTProfile[[ "sysTLoadMerge" ]] <<- sysTLoadMerge
    sysTLoadFeatureSet <<- system.time( loadFeaturesList() )       # loading the feature set
    sysTProfile[[ "sysTLoadFeatureSet" ]] <<- sysTLoadFeatureSet
    
    ## STEP 2 - EXTRACT only Mean And Standard Deviation Values from the Merged Data Set
    sysTComputeColRequired <<- system.time( computeColumnsRequired() )
    sysTProfile[[ "sysTComputeColRequired" ]] <<- sysTComputeColRequired
    sysTExtract <<- system.time( extractData() )
    sysTProfile[[ "sysTExtract" ]] <<- sysTExtract
    
    ## STEP 3  - USE Descriptive Activity (inteads of 1:6 use the Activity Labels) 
    sysTDescActNames <<- system.time( putDescriptiveActivityNames() )
    sysTProfile[[ "sysTDescActNames" ]] <<- sysTDescActNames
    
    ## STEP 4 - Use Appropriate Label Names (using dsFeatureLabels)
    sysTFeatureLabels <<- system.time( putFeatureLabels() )
    sysTProfile[[ "sysTFeatureLabels" ]] <<- sysTFeatureLabels
    
    ## STEP 5 - Create Tidy Data Set with the 
    ## - average of each variable 
    ## for each activity and each subject
    sysTWriteTidy <<- system.time( generateTidyDataSet() )
    sysTProfile[[ "sysTWriteTidy" ]] <<- sysTWriteTidy
    
    ## Profiling Data
    message( paste( Sys.time() , "The Time Taken for Various Processes:" ) )
    print( sysTProfile )
}




## SCRIPT: RUNNING
## ----------------------------------------------------------------
mainFunction()

