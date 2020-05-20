#Setting working directory
    
setwd("/home/gc/Projects/Intenvory-Demand-Prediction/code")
getwd()
    
library(data.table)
library(dplyr)
    
data <- fread("../Dataset/train_sample.csv") # Loading train data sample without outliers (73 million registers)
test <- fread("../Dataset/test.csv") # Loading test data (7 million registers)
    
# To save memory, we are only going to load the train data collumns used on this script 

data$Semana <- NULL
data$Agencia_ID <- NULL
data$Canal_ID <- NULL
data$Ruta_SAK <- NULL
data$Cliente_ID <- NULL
data$Venta_uni_hoy <- NULL
data$Venta_hoy <- NULL
data$Dev_uni_proxima <- NULL
data$Dev_proxima <- NULL
gc() # refreshing memory
    
# Setting up factor parameters
    
data$Producto_ID <- as.character(data$Producto_ID)
test$Producto_ID <- as.character(test$Producto_ID)
    
#****************************************Analysing target value by Product************************************************
    
# Grouping demand by Product
    
by_Product <- data.table(group_by(data,Producto_ID) %>% summarize(Demanda_uni_equil = mean(Demanda_uni_equil))) 
    
# Creating a function to return the mean demand for each Product
    
find_product_mean <- function(x){
  by_Product$Demanda_uni_equil[by_Product$Producto_ID == x]
}
    
# Assigning the mean demand for each register on the test data
    
gc() # refreshing memory
x <- sapply(data$Producto_ID,find_product_mean)
gc() # refreshing memory
data$Producto_ID_mean <- x
    
gc() # refreshing memory
x <- sapply(test$Producto_ID,find_product_mean)
gc() # refreshing memory
test$Producto_ID_mean <- x

# Treating possible NAs by assining the mean demand

mean <- mean(by_Product$Demanda_uni_equil)
test$Producto_ID_mean <- ifelse(is.na(as.numeric(test$Producto_ID_mean)),mean,test$Producto_ID_mean)

#****************************************Saving data to continue on predictive analysis*********************************************

test <- test[,c("Producto_ID","Producto_ID_mean")]
fwrite(test,"../Dataset/test_Product.csv")

data <- data[,c("Producto_ID","Producto_ID_mean")]
fwrite(data,"../Dataset/train_Product.csv")

