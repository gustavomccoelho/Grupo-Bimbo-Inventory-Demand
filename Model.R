setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)
library(randomForest)
library(caret)
library(e1071)

# Loading train.csv data

data <- fread("/home/gc/FCD/BigDataRAzure/Project-2/Dataset/train_5.csv")

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

# Analysing train.csv data

head(data)
str(data)

# Looking for NA Values

lapply(data,function(x) sum(is.na(x)))

#****************************************Training Model************************************************

# Spliting train and test data

nrows <- unique(round(runif(nrow(data)*1.2,1,nrow(data))))
train_data <- sample_n(data[nrows,],10000000)
test_data <- sample_n(data[-nrows,],10000000)
data <- NULL
nrows <- NULL
gc()

# First attempt - Linear Model - R-squared - 0.3954

model <- lm(Demanda_uni_equil~.,train_data)
gc()
prediction <- predict(model,test_data)
result <- data.table(cbind(test_data$Demanda_uni_equil, prediction))
result$result <- result$V1 - result$prediction
View(result)

#****************************************Testing Model************************************************

prediction <- NULL
result <- NULL
test_data <- NULL
train_data <- NULL
gc()

test <- fread("/home/gc/FCD/BigDataRAzure/Project-2/Dataset/test_5.csv")

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

str(test)

prediction <- predict(model,test)
View(prediction)

#Saving data

output <- data.frame(as.integer(prediction))
output <- cbind(test$id,output)
colnames(output) = c("id","Demanda_uni_equil")

fwrite(output,"/home/gc/FCD/BigDataRAzure/Project-2/Dataset/kaggle.csv")
