setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)

# Loading train.csv data

data <- fread("../Dataset/train_4.csv")
test <- fread("../Dataset/test_4.csv")

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
data$Cliente_ID_group <- as.factor(data$Cliente_ID_group)

test$Agencia_ID <- as.factor(test$Agencia_ID)
test$Canal_ID <- as.factor(test$Canal_ID)
test$Ruta_SAK <- as.factor(test$Ruta_SAK)
test$Cliente_ID <- as.factor(test$Cliente_ID)
test$Producto_ID <- as.factor(test$Producto_ID)
test$Agencia_ID_group <- as.factor(test$Agencia_ID_group)
test$Ruta_SAK_group <- as.factor(test$Ruta_SAK_group)
test$Cliente_ID_group <- as.factor(test$Cliente_ID_group)

# Looking for NA Values

lapply(data,function(x) sum(is.na(x)))

#****************************************Analysing target value by Product************************************************

gc()
by_Product = group_by(data,Producto_ID) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil))
ggplot(by_Product, aes(x = Producto_ID, y = Demanda_uni_equil)) + geom_col() + ggtitle("Producto_ID x Demanda_uni_equil")

# Checking how many new Product on test data

new_Products <- test$Producto_ID %in% data$Producto_ID
sum(new_Products == FALSE)

# Creating Route levels accoring to Demanda_uni_equil

quantile(by_Product$Demanda_uni_equil, c(0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.93, 0.95, 0.98, 0.99, 1))

make_levels <- function(x){
  ifelse(x >= 0 & x < 2, 1, 
  ifelse(x >=2 & x < 3, 2,
  ifelse(x >=3 & x < 5, 3,
  ifelse(x >=5 & x <8, 4,
  ifelse(x >=8 & x < 14, 5,
  ifelse(x >=14 & x < 24, 6,
  ifelse(x >=24 & x < 40, 7,
  ifelse(x >=40 & x < 72, 8,
  ifelse(x >=72 & x < 108, 9,
  ifelse(x >=108 & x < 148, 10,
  ifelse(x >=148 & x < 382, 11,
  ifelse(x >=382 & x < 750, 12,13))))))))))))
}

by_Product$Producto_ID_group <- as.factor(make_levels(by_Product$Demanda_uni_equil))
by_Product_group <- data.table(group_by(by_Product,Producto_ID_group) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil)))
ggplot(by_Product_group, aes(x = Producto_ID_group, y = Demanda_uni_equil)) + geom_col() + ggtitle("Product_ID_group x Demanda_uni_equil")

# Creating a list including every route ID on its level

product_list <- list()
length(product_list) <- 13

for(i in 1:nrow(by_Product)){
  group <- by_Product$Producto_ID_group[i]
  ID <- as.character(by_Product$Producto_ID[i])
  content <- product_list[[group]]
  product_list[[group]] <- c(content, ID) 
}

data$Producto_ID_group <- 3
test$Producto_ID_group <- 3
gc()

for(i in 1:13){
  data$Producto_ID_group <- as.factor(ifelse(data$Producto_ID %in% product_list[[i]],i,data$Producto_ID_group))
}

for(i in 1:13){
  test$Producto_ID_group <- as.factor(ifelse(test$Producto_ID %in% product_list[[i]],i,test$Producto_ID_group))
}

# Checking the number of rows by Product_level

gc()
ggplot(test, aes(x = Producto_ID_group)) + geom_bar()

#****************************************Saving data to continue on next code*********************************************

fwrite(data,"../Dataset/train_5.csv")
fwrite(test,"../Dataset/test_5.csv")
