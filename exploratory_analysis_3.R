setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)

# Loading train.csv data

data <- fread("../Dataset/train_3.csv")
test <- fread("../Dataset/test_3.csv")

# Analysing train.csv data

str(data)
str(test)

# Setting up factor parameters

data$Semana <- as.factor(data$Semana)
data$Agencia_ID <- as.factor(data$Agencia_ID)
data$Canal_ID <- as.factor(data$Canal_ID)
data$Ruta_SAK <- as.factor(data$Ruta_SAK)
data$Cliente_ID <- as.factor(data$Cliente_ID)
data$Producto_ID <- as.factor(data$Producto_ID)
data$Agencia_ID_group <- as.factor(data$Agencia_ID_group)
data$Ruta_SAK_group <- as.factor(data$Ruta_SAK_group)

test$Agencia_ID <- as.factor(test$Agencia_ID)
test$Canal_ID <- as.factor(test$Canal_ID)
test$Ruta_SAK <- as.factor(test$Ruta_SAK)
test$Cliente_ID <- as.factor(test$Cliente_ID)
test$Producto_ID <- as.factor(test$Producto_ID)
test$Agencia_ID_group <- as.factor(test$Agencia_ID_group)
test$Ruta_SAK_group <- as.factor(test$Ruta_SAK_group)

# Looking for NA Values

lapply(data,function(x) sum(is.na(x)))

#****************************************Analysing target value by Client************************************************

gc()
by_Client = group_by(data,Cliente_ID) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil))

# Checking how many new Clients on test data

new_Clients <- test$Cliente %in% data$Ruta_SAK
sum(new_Routes == FALSE)

# Creating Route levels accoring to Demanda_uni_equil

quantile(by_Client$Demanda_uni_equil, c(0.5, 0.8, 0.85, 0.9, 0.95, 0.96, 0.97, 0.98, 0.99, 0.997, 1))

make_levels <- function(x){
  ifelse(x >= 0 & x < 3, 1, 
  ifelse(x >=3 & x < 4, 2,
  ifelse(x >=4 & x < 5, 3,
  ifelse(x >=5 & x < 6, 4,
  ifelse(x >=6 & x < 9, 5,
  ifelse(x >=9 & x < 10, 6,
  ifelse(x >=10 & x < 12, 7,
  ifelse(x >=12 & x < 18, 8,
  ifelse(x >=18 & x < 30, 9,
  ifelse(x >=30 & x < 60, 10,11))))))))))
}

by_Client$Cliente_ID_group <- as.factor(make_levels(by_Client$Demanda_uni_equil))
by_Client_group <- data.table(group_by(by_Client,Cliente_ID_group) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil)))
ggplot(by_Client_group, aes(x = Cliente_ID_group, y = Demanda_uni_equil)) + geom_col() + ggtitle("Cliente_ID_group x Demanda_uni_equil")

# Creating a list including every Client ID on its level

client_list <- list()
length(client_list) <- 11

gc()

for(i in 1:nrow(by_Client)){
  group <- by_Client$Cliente_ID_group[i]
  ID <- as.character(by_Client$Cliente_ID[i])
  content <- client_list[[group]]
  client_list[[group]] <- c(content, ID)
}

data$Cliente_ID_group <- 2
test$Cliente_ID_group <- 2

gc()

for(i in 1:11){
  data$Cliente_ID_group <- as.factor(ifelse(data$Cliente_ID %in% client_list[[i]],i,data$Cliente_ID_group))
}

for(i in 1:11){
  test$Cliente_ID_group <- as.factor(ifelse(test$Cliente_ID %in% client_list[[i]],i,test$Cliente_ID_group))
}


# Checking the number of rows by Agency_level

gc()
ggplot(test, aes(x = Cliente_ID_group)) + geom_bar()

#****************************************Saving data to continue on next code*********************************************

fwrite(data,"../Dataset/train_4.csv")
fwrite(test,"../Dataset/test_4.csv")
