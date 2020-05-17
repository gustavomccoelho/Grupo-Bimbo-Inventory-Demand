setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)
library(randomForest)
library(caret)
library(e1071)
library(ranger)

# Loading train.csv data

data <- fread("../Dataset/train_5.csv")

# Removing columns not used

data$Producto_ID <- NULL
data$Cliente_ID <- NULL
data$Ruta_SAK <- NULL
data$Agencia_ID <- NULL
data$Venta_uni_hoy <- NULL
data$Venta_hoy <- NULL
data$Dev_uni_proxima <- NULL
data$Dev_proxima <- NULL
data$Semana <- NULL
gc()

# Setting up factor parameters

data$Canal_ID <- as.factor(data$Canal_ID)
data$Agencia_ID_group <- as.factor(data$Agencia_ID_group)
data$Ruta_SAK_group <- as.factor(data$Ruta_SAK_group)
data$Cliente_ID_group <- as.factor(data$Cliente_ID_group)
data$Producto_ID_group <- as.factor(data$Producto_ID_group)

#****************************************Training Model************************************************

# First option - Linear Model - Kaggle Score - 0.69 - 15 million training data size

train_data <- sample_n(data,15000000)
data <- NULL
gc()
model <- lm(Demanda_uni_equil ~ .,train_data)
ranger_used = FALSE

# Secound option - Random Forest - Kaggle Score - 0.66307 1 million training data size

train_data <- sample_n(data,1000000)
data <- NULL
gc()
model <- randomForest(Demanda_uni_equil ~ .,train_data, ntree = 100, nodesize = 10)
ranger_used = FALSE

# Third option - Range - Kaggle Score - 0.59902 - 2 million training data size - ntrees = 100 

train_data <- sample_n(data,10000000)
gc()
model <- ranger(Demanda_uni_equil ~ .-Canal_ID,train_data, num.trees = 100)
ranger_used = TRUE

#**********************************Predicting on Submission Data******************************************************

train_data <- NULL
gc()

test <- fread("../Dataset/test_5.csv")

test$Canal_ID <- as.factor(test$Canal_ID)
test$Agencia_ID_group <- as.factor(test$Agencia_ID_group)
test$Ruta_SAK_group <- as.factor(test$Ruta_SAK_group)
test$Cliente_ID_group <- as.factor(test$Cliente_ID_group)
test$Producto_ID_group <- as.factor(test$Producto_ID_group)

test$Producto_ID <- NULL
test$Cliente_ID <- NULL
test$Ruta_SAK <- NULL
test$Agencia_ID <- NULL
test$Semana <- NULL

gc()
prediction <- predict(model,test)

if(ranger_used == TRUE) prediction <- prediction$predictions

#Saving data

output <- data.table(as.integer(prediction))
output <- cbind(test$id,output)
colnames(output) = c("id","Demanda_uni_equil")
fwrite(output,"../Dataset/kaggle.csv")

