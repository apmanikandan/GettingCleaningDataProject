# Load library
library(plyr)

# download the file and unzip into data directory
if (!file.exists("data")) {
        dir.create("data")
}
{
        fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl,destfile="./data/zipfile.zip",method="curl")
        setwd("./data")
        unzip("zipfile.zip", files = NULL, list = FALSE, overwrite = TRUE,
              junkpaths = FALSE, exdir = ".", unzip = "internal",
              setTimes = FALSE)
 }

# Read raw data
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)

features<-read.table("./UCI HAR Dataset/features.txt",header=FALSE,colClasses = c("character"))
activity_Labels <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("ActivityId", "Activity"))

# Bind the sensor data - merging of train and test files.

training_sensor_data <- cbind(cbind(x_train, subject_train), y_train)
test_sensor_data <- cbind(cbind(x_test, subject_test), y_test)
sensor_data <- rbind(training_sensor_data, test_sensor_data)

# Label columns - Clean them by removing problematic text aswell 

sensor_labels <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
cleanLabels <-gsub("([()])","",sensor_labels)
cleanLabels <-gsub("([-])","", cleanLabels)
cleanLabels <-gsub("([,])","", cleanLabels)

names(sensor_data) <- cleanLabels

###########################################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
############################################################################################

sensor_data_mean_std <- sensor_data[,grepl("mean|std|Subject|ActivityId", names(sensor_data))]

###############################################################################################
#3 Uses descriptive activity names to name the activities in the data set - join by activity id
###############################################################################################

sensor_data_mean_std <- join(sensor_data_mean_std, activity_Labels, by = "ActivityId", match = "first")
sensor_data_mean_std <- sensor_data_mean_std[,-1]

################################################################################################
# Create a tidy dataset - with the average of each variable for each activity and each subject
################################################################################################

sensor_avg_by_act_sub = ddply(sensor_data_mean_std, c("Subject","Activity"), numcolwise(mean))
write.table(sensor_avg_by_act_sub, file = "sensor_avg_by_act_subj.txt",row.name=FALSE)

