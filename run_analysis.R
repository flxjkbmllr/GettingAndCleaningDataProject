##### Getting and cleaning data - Course Project
##### Author: Felix Mueller
##### Date: 04Jan2018
##### setwd("/Users/Felix/Documents/DataScience/GettingAndCleaning")


### GET THE DATA

# Set URL and filenames
fileUrl      <-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileNameZip  <-"datasets.zip"
fileNameUnzip<-"UCI HAR Dataset"

# Download if needed
if (!file.exists(fileNameZip)) {
    download.file(fileUrl,destfile=fileNameZip,method="curl") 
    dateDownloaded <- date()
}

# Unzip if needed
if (!file.exists(fileNameUnzip)) { 
    unzip(fileNameZip)
    dateUnzipped <- date()
}


### LOAD THE DATA TO R

# Activity Labels
activityLabels<-read.table("./UCI HAR Dataset/activity_labels.txt")
str(activityLabels)

# Features
features<-read.table("./UCI HAR Dataset/features.txt")
str(features)

# Test datasets
testSubjects<-read.table("./UCI HAR Dataset/test/subject_test.txt")
testLabels  <-read.table("./UCI HAR Dataset/test/y_test.txt")
testSet     <-read.table("./UCI HAR Dataset/test/X_test.txt")
testAll     <-cbind(testSubjects,testLabels,testSet)
str(testAll)
table(testSubjects) # Check available subjects in test

# Train datasets
trainSubjects<-read.table("./UCI HAR Dataset/train/subject_train.txt")
trainLabels  <-read.table("./UCI HAR Dataset/train/y_train.txt")
trainSet     <-read.table("./UCI HAR Dataset/train/X_train.txt")
trainAll     <-cbind(trainSubjects,trainLabels,trainSet)
str(trainAll)
table(trainSubjects) # Check available subjects in train


### ASSESS THE DATA

# Merge (in this case set) test and training data together
testTrainAll <- rbind(testAll,trainAll)

# Extract the measurements on the mean and SD
featuresExtract <- grep(".*mean.*|.*std.*", features[,2])
testTrainMeanSD <- testTrainAll[c(1,2,featuresExtract+2)]

# Name and factorize the activities in the data set
testTrainMeanSD[2] <- factor(as.character(testTrainMeanSD[,2])
                            ,levels=activityLabels[,1]
                            ,labels=as.character(activityLabels[,2]))

# Label the data set with descriptive variable names
names(testTrainMeanSD) <- c("subject","activity",as.character(features$V2[featuresExtract]))
names(testTrainMeanSD) <- gsub('-mean', 'Mean', names(testTrainMeanSD))
names(testTrainMeanSD) <- gsub('-std', 'Std', names(testTrainMeanSD))
names(testTrainMeanSD) <- gsub('[-()]', '', names(testTrainMeanSD))

# Create an independent tidy data set with the average of each variable
# for each activity and each subject
library(reshape2)
testTrainMeanSDmelt <- melt(testTrainMeanSD, id = c("subject", "activity"))
testTrainMeanSDmean <- dcast(testTrainMeanSDmelt, subject + activity ~ variable, mean)


### OUTPUT THE DATA
write.table(testTrainMeanSD, "testTrainMeanSD.txt", row.names = FALSE, quote = FALSE)
write.table(testTrainMeanSDmean, "testTrainMeanSDmean.txt.txt", row.names = FALSE, quote = FALSE)
