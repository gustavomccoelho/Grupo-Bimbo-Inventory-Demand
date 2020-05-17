setwd("/home/gc/FCD/BigDataRAzure/Project-2/Grupo-Bimbo-Inventory-Demand")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)

# Loading train.csv data

data <- fread("../Dataset/train.csv")
test <- fread("../Dataset/test.csv")

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

test$Agencia_ID <- as.factor(test$Agencia_ID)
test$Canal_ID <- as.factor(test$Canal_ID)
test$Ruta_SAK <- as.factor(test$Ruta_SAK)
test$Cliente_ID <- as.factor(test$Cliente_ID)
test$Producto_ID <- as.factor(test$Producto_ID)

# Looking for NA Values

lapply(data,function(x) sum(is.na(x)))

#****************************************Analysing target value by Agency************************************************

by_Agency <- data.table(group_by(data,Agencia_ID) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil)))
ggplot(by_Agency, aes(x = Agencia_ID, y = Demanda_uni_equil)) + geom_col() + ggtitle("Agencia_ID x Demanda_uni_equil")

# Checking how many new Agencies on test data

new_Agencies <- test$Agencia_ID %in% data$Agencia_ID
sum(new_Agencies == FALSE)

quantile(by_Agency$Demanda_uni_equil, c(0.2, 0.4, 0.5, 0.6, 0.7, 0.725, 0.8, 0.88, 0.9, 0.95, 0.999, 1))

# Creating Agency levels accoring to Demanda_uni_equil

make_levels <- function(x){
  ifelse(x >= 0 & x < 3, 1, 
  ifelse(x >=3 & x < 4, 2,
  ifelse(x >=4 & x < 5, 3,
  ifelse(x >=5 & x < 7, 4,
  ifelse(x >=7 & x < 9, 5,
  ifelse(x >=9 & x < 20, 6,
  ifelse(x >=20 & x < 30, 7,
  ifelse(x >=30 & x < 52, 8,
  ifelse(x >=52 & x < 78, 9,
  ifelse(x >=78 & x < 115, 10,
  ifelse(x >=115 & x < 1168, 11, 12)))))))))))
}

by_Agency$Agencia_ID_group <- as.factor(make_levels(by_Agency$Demanda_uni_equil))

by_Agency_group <- data.table(group_by(by_Agency,Agencia_ID_group) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil)))
ggplot(by_Agency_group, aes(x = Agencia_ID_group, y = Demanda_uni_equil)) + geom_col() + ggtitle("Agencia_ID_group x Demanda_uni_equil")

agency_list <- list()
length(agency_list) <- 12

# Creating a list including every ID on its level

for(i in 1:nrow(by_Agency)){
  group <- by_Agency$Agencia_ID_group[i]
  ID <- as.character(by_Agency$Agencia_ID[i])
  content <- agency_list[[group]]
  agency_list[[group]] <- c(content, ID) 
}

data$Agencia_ID_group <- 2
test$Agencia_ID_group <- 2

for(i in 1:12){
  data$Agencia_ID_group <- as.factor(ifelse(data$Agencia_ID %in% agency_list[[i]],i,data$Agencia_ID_group))
}

for(i in 1:12){
  test$Agencia_ID_group <- as.factor(ifelse(test$Agencia_ID %in% agency_list[[i]],i,test$Agencia_ID_group))
}

# Checking the number of rows by Agency_level

ggplot(data, aes(x = Agencia_ID_group)) + geom_bar()

#****************************************Analysing target value by Channel************************************************

by_Channel = group_by(data,Canal_ID) %>% summarize(Demanda_uni_equil = median(Demanda_uni_equil))
ggplot(by_Channel, aes(x = Canal_ID, y = Demanda_uni_equil)) + geom_col() + ggtitle("Canal_ID x Demanda_uni_equil")

# Checking how many new Channels on test data

new_Channels <- test$Canal_ID %in% data$Canal_ID
sum(new_Channels == FALSE)

#****************************************Saving data to continue on next code*********************************************

fwrite(data,"../Dataset/train_2.csv")
fwrite(test,"../Dataset/test_2.csv")
