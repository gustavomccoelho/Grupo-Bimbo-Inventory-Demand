setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)

# Loading train.csv data

data <- fread("/home/gc/FCD/BigDataRAzure/Project-2/Dataset/train_2.csv")
test <- fread("/home/gc/FCD/BigDataRAzure/Project-2/Dataset/test_2.csv")

# Setting up factor parameters

data$Semana <- as.factor(data$Semana)
data$Agencia_ID <- as.factor(data$Agencia_ID)
data$Canal_ID <- as.factor(data$Canal_ID)
data$Ruta_SAK <- as.factor(data$Ruta_SAK)
data$Cliente_ID <- as.factor(data$Cliente_ID)
data$Producto_ID <- as.factor(data$Producto_ID)
data$Agencia_ID_group <- as.factor(data$Agencia_ID_group)

test$Agencia_ID <- as.factor(test$Agencia_ID)
test$Canal_ID <- as.factor(test$Canal_ID)
test$Ruta_SAK <- as.factor(test$Ruta_SAK)
test$Cliente_ID <- as.factor(test$Cliente_ID)
test$Producto_ID <- as.factor(test$Producto_ID)
test$Agencia_ID_group <- as.factor(test$Agencia_ID_group)

# Analysing train.csv data

str(data)
str(test)

# Looking for NA Values

lapply(data,function(x) sum(is.na(x)))

#****************************************Analysing target value by Route************************************************

by_Route = group_by(data,Ruta_SAK) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil))
ggplot(by_Route, aes(x = Ruta_SAK, y = Demanda_uni_equil)) + geom_col() + ggtitle("Ruta_SKA x Demanda_uni_equil")

# Checking how many new Routes on test data

new_Routes <- test$Ruta_SAK %in% data$Ruta_SAK
sum(new_Routes == FALSE)

# Creating Route levels accoring to Demanda_uni_equil

quantile(by_Route$Demanda_uni_equil, c(0.2, 0.4, 0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.95, 0.98, 0.999, 1))

make_levels <- function(x){
  ifelse(x >= 0 & x < 3, 1, 
  ifelse(x >=3 & x < 7, 2,
  ifelse(x >=7 & x < 16, 3,
  ifelse(x >=16 & x < 24, 4,
  ifelse(x >=24 & x < 32, 5,
  ifelse(x >=32 & x < 45, 6,
  ifelse(x >=45 & x < 60, 7,
  ifelse(x >=60 & x < 84, 8,
  ifelse(x >=84 & x < 168, 9,
  ifelse(x >=168 & x < 216, 10,
  ifelse(x >=216 & x < 1679, 11,12)))))))))))
}

by_Route$Ruta_SAK_group <- as.factor(make_levels(by_Route$Demanda_uni_equil))
by_Route_group <- data.table(group_by(by_Route,Ruta_SAK_group) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil)))
ggplot(by_Route_group, aes(x = Ruta_SAK_group, y = Demanda_uni_equil)) + geom_col() + ggtitle("Ruta_SAK_group x Demanda_uni_equil")

# Creating a list including every route ID on its level

route_list <- list()
length(route_list) <- 12

for(i in 1:nrow(by_Route)){
  group <- by_Route$Ruta_SAK_group[i]
  ID <- as.character(by_Route$Ruta_SAK[i])
  content <- route_list[[group]]
  route_list[[group]] <- c(content, ID) 
}

data$Ruta_SAK_group <- 2
test$Ruta_SAK_group <- 2

gc()

for(i in 1:12){
  data$Ruta_SAK_group <- as.factor(ifelse(data$Ruta_SAK %in% route_list[[i]],i,data$Ruta_SAK_group))
}

for(i in 1:12){
  test$Ruta_SAK_group <- as.factor(ifelse(test$Ruta_SAK %in% route_list[[i]],i,test$Ruta_SAK_group))
}

# Checking the number of rows by Route_level

gc()
ggplot(data, aes(x = Agencia_ID_group)) + geom_bar()


#****************************************Saving data to continue on next code*********************************************

fwrite(data,"/home/gc/FCD/BigDataRAzure/Project-2/Dataset/train_3.csv")
fwrite(test,"/home/gc/FCD/BigDataRAzure/Project-2/Dataset/test_3.csv")
