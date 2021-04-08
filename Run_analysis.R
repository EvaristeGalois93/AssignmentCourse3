# You should create one R script called run_analysis.R that does the following. 
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation 
#     for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
#     with the average of each variable for each activity and each subject.
library(dplyr)

setwd("C:/Users/luca-/Desktop/Data_Science/Course3_GettingAndCleaningData/Working_Material")

# first check folder and download data
if(!file.exists("./data")){
  dir.create("./data")
}

fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/mydata.zip", method = "curl")
unzip("./data/mydata.zip", exdir = "./data")

# load features & labels
features = read.table("./data/UCI HAR Dataset/features.txt", 
                      col.names = c("n","functions"))
activ_labels = read.table("./data/UCI HAR Dataset/activity_labels.txt", 
                          col.names = c("code", "activity"))

# load test data
test_data = read.table("./data/UCI HAR Dataset/test/X_test.txt", 
                       col.names = features$functions)
test_labels = read.table("./data/UCI HAR Dataset/test/y_test.txt", 
                         col.names = "code")
subj_test = read.table("./data/UCI HAR Dataset/test/subject_test.txt", 
                       col.names = "subject")

# load train data
train_data = read.table("./data/UCI HAR Dataset/train/X_train.txt", 
                        col.names = features$functions)
train_labels = read.table("./data/UCI HAR Dataset/train/y_train.txt", 
                          col.names = "code")
subj_train = read.table("./data/UCI HAR Dataset/train/subject_train.txt", 
                        col.names = "subject")

# 1. merge tables
my_data = rbind(train_data, test_data)
my_label = rbind(train_labels, test_labels)
Subject = rbind(subj_train, subj_test)
Merged_Data = cbind(Subject, my_label, my_data)

# 2. filter by mean and std
Tidy_Data = Merged_Data %>% 
  select(subject, code, contains("mean"), contains("std"))

Tidy_Data$code = activ_labels[Tidy_Data$code, 2]

# 3-4. re-name columns in a descriptive manner
names(Tidy_Data)[2] = "activity"
names(Tidy_Data) = gsub("BodyBody", "Body", names(Tidy_Data))
names(Tidy_Data) = gsub("^t", "Time", names(Tidy_Data))
names(Tidy_Data) = gsub("^f", "Frequency", names(Tidy_Data))
names(Tidy_Data) = gsub("tBody", "TimeBody", names(Tidy_Data))
names(Tidy_Data) = gsub("-mean()", "Mean", names(Tidy_Data), ignore.case = TRUE)
names(Tidy_Data) = gsub("-std()", "STD", names(Tidy_Data), ignore.case = TRUE)
names(Tidy_Data) = gsub("-freq()", "Frequency", names(Tidy_Data), ignore.case = TRUE)

# 5. create tidy dataset
ReshapedData = Tidy_Data %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(x = ReshapedData, file =  "TidyData.txt", row.name = FALSE)
