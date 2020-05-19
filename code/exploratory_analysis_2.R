#Setting working directory

setwd("/home/gc/FCD/BigDataRAzure/Intenvory-Demand-Prediction/code")
getwd()

library(data.table)
library(dplyr)

data <- fread("../Dataset/train_sample.csv") # Loading train sample without outliers (73 million registers)
test <- fread("../Dataset/test.csv") # Loading test data (7 million registers)

# To save memory, we are only going to load the train data collumns used on this script 

data$Semana <- NULL
data$Agencia_ID <- NULL
data$Ruta_SAK <- NULL
data$Cliente_ID <- NULL
data$Producto_ID <- NULL
data$Venta_uni_hoy <- NULL
data$Venta_hoy <- NULL
data$Dev_uni_proxima <- NULL
data$Dev_proxima <- NULL
gc() # refreshing memory

# Setting up factor parameters

data$Canal_ID <- as.character(data$Canal_ID)
test$Canal_ID <- as.character(test$Canal_ID)

#****************************************Analysing target value by Channel************************************************

# Grouping demand by Channel

by_Channel <- data.table(group_by(data,Canal_ID) %>% summarize(Demanda_uni_equil = mean(Demanda_uni_equil))) 

# Creating a function to return the mean demand for each Channel

find_channel_mean <- function(x){
  by_Channel$Demanda_uni_equil[by_Channel$Canal_ID == x]
}

# Assigning the mean demand by Channel on each line

x <- sapply(test$Canal_ID,find_channel_mean)
test$Canal_ID_mean <- x

x <- sapply(data$Canal_ID,find_channel_mean)
data$Canal_ID_mean <- x

# Treating possible NAs by assining the mean demand

mean <- mean(by_Channel$Demanda_uni_equil)
test$Canal_ID_mean <- ifelse(is.na(as.numeric(test$Canal_ID_mean)),mean,test$Canal_ID_mean)

#****************************************Saving data to continue on prediction analysis*********************************************

test <- test[,c("Canal_ID","Canal_ID_mean")]
fwrite(test,"../Dataset/test_Channel.csv")

data <- data[,c("Canal_ID","Canal_ID_mean")]
fwrite(data,"../Dataset/train_Channel.csv")
