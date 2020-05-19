#Setting working directory

setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(dplyr)
library(randomForest)
library(caret)
library(e1071)
library(ranger)

# Loading train and test data 

Agency <- fread("../Dataset/train_Agency.csv")
Channel <- fread("../Dataset/train_Channel.csv")
Route <- fread("../Dataset/train_Route.csv")
Client <- fread("../Dataset/train_Client.csv")
Product <- fread("../Dataset/train_Product.csv")
train <- fread("../Dataset/train_sample.csv")

train <- cbind(Agency[,Agencia_ID_mean], Channel[,Canal_ID_mean], Route[,Ruta_SAK_mean], Client[,Cliente_ID_mean], Product[,Producto_ID_mean], train[,Demanda_uni_equil])
gc() # refreshing memory

Agency <- fread("../Dataset/test_Agency.csv")
Channel <- fread("../Dataset/test_Channel.csv")
Route <- fread("../Dataset/test_Route.csv")
Client <- fread("../Dataset/test_Client.csv")
Product <- fread("../Dataset/test_Product.csv")

test <- cbind(Agency[,Agencia_ID_mean], Channel[,Canal_ID_mean], Route[,Ruta_SAK_mean], Client[,Cliente_ID_mean], Product[,Producto_ID_mean])

Agency <- NULL
Channel <- NULL
Route <- NULL
Client <- NULL
Product <- NULL

train <- data.table(train)
test <- data.table(test)
name = c("Agencia_ID_mean","Canal_ID_mean","Ruta_SAK_mean","Cliente_ID_mean","Producto_ID_mean","Demanda_uni_equil")
names(train) <- name
name = c("Agencia_ID_mean","Canal_ID_mean","Ruta_SAK_mean","Cliente_ID_mean","Producto_ID_mean")
names(test) <- name
gc() # refreshing memory

#****************************************Training Model************************************************

# Ranger - Kaggle Score - 0.55   - 10 million training data size - ntrees = 100 
  
train_sample <- sample_n(train,10000000)
train <- NULL
gc()
model <- ranger(Demanda_uni_equil ~ .,train_sample, num.trees = 100)

#**********************************Predicting on Test Data******************************************************

train_sample <- NULL
gc()
prediction <- predict(model,test) 
prediction <- prediction$predictions

# Saving data - GOOD LUCK!

test <- fread("../Dataset/test.csv")
kaggle <- data.table(as.integer(prediction))
kaggle <- cbind(test$id,kaggle)
colnames(kaggle) = c("id","Demanda_uni_equil")
fwrite(kaggle,"../Dataset/kaggle.csv")

