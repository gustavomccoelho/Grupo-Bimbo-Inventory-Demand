#Setting working directory

setwd("/home/gc/Projects/Intenvory-Demand-Prediction/code")
getwd()

library(data.table)
library(dplyr)

data <- fread("../Dataset/train.csv") # Loading train data (73 million registers)
test <- fread("../Dataset/test.csv") # Loading test data (7 million registers)

# Finding outliers

#quantile(data$Demanda_uni_equil,c(0.75,0.90,0.95,0.99,1))

#Choosing to remove all lines where Demanda_uni_equil > 100

data <- data[data$Demanda_uni_equil<100,]
gc()

# Saving this sample to be used on the other scripts

fwrite(data,"../Dataset/train_sample.csv")

# To save memory, we are only going to load the train data collumns used on this script 

data$Semana <- NULL
data$Canal_ID <- NULL
data$Ruta_SAK <- NULL
data$Cliente_ID <- NULL
data$Producto_ID <- NULL
data$Venta_uni_hoy <- NULL
data$Venta_hoy <- NULL
data$Dev_uni_proxima <- NULL
data$Dev_proxima <- NULL
gc() # refreshing memory

# Setting up factor parameters

data$Agencia_ID <- as.character(data$Agencia_ID)
test$Agencia_ID <- as.character(test$Agencia_ID)
head(data)
#****************************************Analysing target value by Agency************************************************

# Grouping demand by Agency

by_Agency <- data.table(group_by(data,Agencia_ID) %>% summarize(Demanda_uni_equil = mean(Demanda_uni_equil))) 

# Creating a function to return the mean demand for each Agency ID

find_agency_mean <- function(x){
  by_Agency$Demanda_uni_equil[by_Agency$Agencia_ID == x]
}

# Assigning the mean demand by Agency on each line
  
x <- sapply(test$Agencia_ID,find_agency_mean)
test$Agencia_ID_mean <- x

 
x <- sapply(data$Agencia_ID,find_agency_mean)
data$Agencia_ID_mean <- x

# Treating possible NAs by assining the mean demand

mean <- mean(by_Agency$Demanda_uni_equil)
test$Agencia_ID_mean <- ifelse(is.na(as.numeric(test$Agencia_ID_mean)),mean,test$Agencia_ID_mean)

#****************************************Saving data to continue on predictive analysis*********************************************

test <- test[,c("Agencia_ID","Agencia_ID_mean")]
fwrite(test,"../Dataset/test_Agency.csv")

data <- data[,c("Agencia_ID","Agencia_ID_mean")]
fwrite(data,"../Dataset/train_Agency.csv")
