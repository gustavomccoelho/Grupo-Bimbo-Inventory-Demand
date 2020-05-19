#Setting working directory

setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(dplyr)
                  
# Loading train.csv data

data <- fread("../Dataset/train_sample.csv") # Loading train sample without outliers (73 million registers)
test <- fread("../Dataset/test.csv") # Loading test data (7 million registers)

# To save memory, we are only going to load the train data collumns used on this script 
  
data$Semana <- NULL
data$Canal_ID <- NULL
data$Agencia_ID <- NULL
data$Cliente_ID <- NULL
data$Producto_ID <- NULL
data$Venta_uni_hoy <- NULL
data$Venta_hoy <- NULL
data$Dev_uni_proxima <- NULL
data$Dev_proxima <- NULL
gc()  #refreshing memory

# Setting up factor parameters

data$Ruta_SAK <- as.character(data$Ruta_SAK)
test$Ruta_SAK <- as.character(test$Ruta_SAK)

#****************************************Analysing target value by Route************************************************

# Grouping demand by Route

by_Route <- data.table(group_by(data,Ruta_SAK) %>% summarize(Demanda_uni_equil = mean(Demanda_uni_equil))) 

# Creating a function to return the mean demand for each Route

find_route_mean <- function(x){
  by_Route$Demanda_uni_equil[by_Route$Ruta_SAK == x]
}

# Assigning the mean demand by Route on each line

x <- sapply(test$Ruta_SAK,find_route_mean)
test$Ruta_SAK_mean <- x

x <- sapply(data$Ruta_SAK,find_route_mean)
data$Ruta_SAK_mean <- x


# Treating possible NAs by assining the mean demand

mean <- mean(by_Route$Demanda_uni_equil)
test$Ruta_SAK_mean <- ifelse(is.na(as.numeric(test$Ruta_SAK_mean)),mean,test$Ruta_SAK_mean)

#****************************************Saving data to continue on predictive analysis*********************************************

test <- test[,c("Ruta_SAK","Ruta_SAK_mean")]
fwrite(test,"../Dataset/test_Route.csv")

data <- data[,c("Ruta_SAK","Ruta_SAK_mean")]
fwrite(data,"../Dataset/train_Route.csv")