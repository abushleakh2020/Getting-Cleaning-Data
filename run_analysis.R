#Download dataset
if(!file.exists("./data")){dir.create("./data")}

fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/data.zip", method = "curl")

#unzip files
unzip("./data/data.zip", exdir = "./data")
filePath<- file.path("./data" , "UCI HAR Dataset")

#read  activity files
activityTestData<-read.table(file.path(filePath,"test", "y_test.txt"))
activityTrainData<-read.table(file.path(filePath,"train", "y_train.txt"))

#read subject files
subjectTestData<-read.table(file.path(filePath,"test", "subject_test.txt"))
subjectTrainData<-read.table(file.path(filePath,"train", "subject_train.txt"))

#Read Fearures files
featureTestData<-read.table(file.path(filePath,"test", "X_test.txt"))
featureTrainData<-read.table(file.path(filePath,"train", "X_train.txt"))

#Merge Data
activityDataSet<- rbind(activityTestData, activityTrainData)
subjectDataSet<- rbind(subjectTestData, subjectTrainData)
featureDataSet<- rbind(featureTestData, featureTrainData)

#clear memory
rm(activityTestData, activityTrainData,subjectTestData, subjectTrainData,  featureTestData, featureTrainData)

#set names
names(activityDataSet) <- c("activity")
names(subjectDataSet) <- c("subject")
featureNames<- read.table(file.path(filePath, "features.txt"))
names(featureDataSet)<- featureNames$V2

#Merge Data
allData<- cbind(subjectDataSet, activityDataSet, featureDataSet)

#clear memory
rm(activityDataSet, subjectDataSet, featureDataSet, featureNames)

#Extract only the measurements on the mean and standard deviation for each measurement
allData<- allData[ ,grepl("subject|activity|mean\\(\\)|std\\(\\)", colnames(allData))]

#read file for add descriptive names
activityVariableNames<- read.table(file.path(filePath, "activity_labels.txt"))
allData$activity<-factor(allData$activity, levels = activityVariableNames$V1, labels = activityVariableNames$V2)

#edit variables names
names(allData)<-gsub("^t", "time", names(allData))
names(allData)<-gsub("^f", "frequency", names(allData))
names(allData)<-gsub("Acc", "Accelerometer", names(allData))
names(allData)<-gsub("Gyro", "Gyroscope", names(allData))
names(allData)<-gsub("Mag", "Magnitude", names(allData))
names(allData)<-gsub("BodyBody", "Body", names(allData))

#Create a second, independent tidy set with the average of each variable for each activity and each subject
library(dplyr)
allDataMeans<- allData %>%
            group_by(subject, activity) %>%
            summarise_each(funs(mean))
#order
allDataMeans<-allDataMeans[order(allDataMeans$subject, desc(allDataMeans$activity)), ]

#write table
write.table(allDataMeans, file = "tidydata.txt", row.name=FALSE)

library(knitr)
knit2html("codebook.Rmd")
