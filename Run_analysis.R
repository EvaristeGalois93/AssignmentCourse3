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
library(plyr)
library(reshape)
library(reshape2)
library(tidyr)
# first check folder and download data
if(!file.exists("./data")){
  dir.create("./data")
  }

fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/mydata.zip", method = "curl")
unzip("./data/mydata.zip", exdir = "./data")

# load features & labels
features = read.table("./data/UCI HAR Dataset/features.txt")
activ_labels = read.table("./data/UCI HAR Dataset/activity_labels.txt")

# load test data
test_data = read.table("./data/UCI HAR Dataset/test/X_test.txt")
test_labels = read.table("./data/UCI HAR Dataset/test/y_test.txt")
subj_test = read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# load train data
train_data = read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_labels = read.table("./data/UCI HAR Dataset/train/y_train.txt")
subj_train = read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# merge tables
mydata = rbind(train_data, test_data)
mylabels = rbind(train_labels,test_labels)
mysubj = rbind(subj_train, subj_test)

# filter features by mean and std
features_filt = features[grepl("mean\\(|std\\(", features[,2]),]

# associate labels with their respective activity
mylabels = inner_join(mylabels, activ_labels)

# filter observations by features and merge tables
mydata = mydata[,features_filt$V1]
mydata = cbind(mysubj, mylabels, mydata)

# give descriptive names
colnames(mydata)[1:3] =  c("Subject", "Activity", "Activity_Descr")

# Point 5: finally reshape data and compute mean across activity and label
TidyData = dcast(mydata, Subject ~ Activity, fun.aggregate = mean)

# write table
write.table(x = TidyData, file = "tidyData.txt", quote = FALSE)