#Setting working directory

setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
#library(ggplot2)
library(dplyr)

data <- fread("../Dataset/train_sample.csv") # Loading train data sample without outliers (73 million registers)
test <- fread("../Dataset/test.csv") # Loading test data (7 million registers)

# To save memory, we are only going to load the train data collumns used on this script 

data$Semana <- NULL
data$Canal_ID <- NULL
data$Ruta_SAK <- NULL
data$Canal_ID <- NULL
data$Producto_ID <- NULL
data$Venta_uni_hoy <- NULL
data$Venta_hoy <- NULL
data$Dev_uni_proxima <- NULL
data$Dev_proxima <- NULL
gc() # refreshing memory

# Setting up factor parameters

data$Cliente_ID <- as.character(data$Cliente_ID)
test$Cliente_ID <- as.character(test$Cliente_ID)

#****************************************Analysing target value by Client************************************************

# Grouping demand by Client

by_Client <- data.table(group_by(data,Cliente_ID) %>% summarize(Demanda_uni_equil = mean(Demanda_uni_equil))) 

# There are too many unique clients to find the mean demand from each (more than 800.000). This would take days of running code. 
# Instead, we will first devide the clients in 14 levels of demand

quantile(by_Client$Demanda_uni_equil, c(0.1, 0.2, 0.3, 0.5, 0.65, 0.8, 0.85, 0.9, 0.95, 0.97, 0.98, 0.99, 0.997, 1))

make_levels <- function(x){
  ifelse(x >= 0 & x < 2.3, 1, 
  ifelse(x >= 2.3 & x < 2.8, 2, 
  ifelse(x >=2.8 & x < 3.3, 3,
  ifelse(x >=3.3 & x < 4.2, 4,
  ifelse(x >=4.2 & x < 5.1, 5,
  ifelse(x >=5.1 & x < 6.6, 6,
  ifelse(x >=6.6 & x < 7.4, 7,
  ifelse(x >=7.4 & x < 8.9, 8,
  ifelse(x >=8.9 & x < 12.5, 9,
  ifelse(x >=12.5 & x < 16.5, 10,
  ifelse(x >=16.5 & x < 20.7, 11,
  ifelse(x >=20.7 & x < 29.3, 12,
  ifelse(x >=29.3 & x < 41.5, 13,14)))))))))))))
}

# Gruping clients by level

by_Client$Cliente_ID_group <- as.factor(make_levels(by_Client$Demanda_uni_equil)) 

# Grouping all the levels

by_Client_group <- data.table(group_by(by_Client,Cliente_ID_group) %>% summarize(Demanda_uni_equil = mean(Demanda_uni_equil)))

# Creating a list including every Client ID on its level

client_list <- list()
length(client_list) <- 14

for(i in 1:nrow(by_Client)){
  group <- by_Client$Cliente_ID_group[i]
  ID <- as.character(by_Client$Cliente_ID[i])
  content <- client_list[[group]]
  client_list[[group]] <- c(content, ID)
}

# Iniciallizing the Client_ID_mean as the mean demand
# For any unknown Client_ID on the test data, it will be assign with the mean demand

test$Cliente_ID_mean <- mean(data$Demanda_uni_equil)
data$Cliente_ID_mean <- mean(data$Demanda_uni_equil)

for(i in 1:14){
  mean <- mean(by_Client_group$Demanda_uni_equil[i])
  test$Cliente_ID_mean <- ifelse(test$Cliente_ID %in% client_list[[i]],mean,test$Cliente_ID_mean)
}

for(i in 1:14){
  mean <- mean(by_Client_group$Demanda_uni_equil[i])
  data$Cliente_ID_mean <- ifelse(data$Cliente_ID %in% client_list[[i]],mean,data$Cliente_ID_mean)
}

#****************************************Saving data to continue on predictive analysis*********************************************

data <- data[,c("Cliente_ID","Cliente_ID_mean")]
fwrite(data,"../Dataset/train_Client.csv")

test <- test[,c("Cliente_ID","Cliente_ID_mean")]
fwrite(test,"../Dataset/test_Client.csv")
