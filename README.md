##  Business problem definition

Planning a celebration is a balancing act of preparing just enough food to go around without being stuck eating the same leftovers for the next week. The key is anticipating how many guests will come. Grupo Bimbo must weigh similar considerations as it strives to meet daily consumer demand for fresh bakery products on the shelves of over 1 million stores along its 45,000 routes across Mexico.

Currently, daily inventory calculations are performed by direct delivery sales employees who must single-handedly predict the forces of supply, demand, and hunger based on their personal experiences with each store. With some breads carrying a one week shelf life, the acceptable margin for error is small.

In this competition, Grupo Bimbo invites Kagglers to develop a model to accurately forecast inventory demand based on historical sales data. Doing so will make sure consumers of its over 100 bakery products aren’t staring at empty shelves, while also reducing the amount spent on refunds to store owners with surplus product unfit for sale.

##  Data

The dataset you are given consists of 9 weeks of sales transactions in Mexico. Every week, there are delivery trucks that deliver products to the vendors. Each transaction consists of sales and returns. Returns are the products that are unsold and expired. The demand for a product in a certain week is defined as the sales this week subtracted by the return next week.

train.csv — the training set

test.csv — the test set

sample_submission.csv — a sample submission file in the correct format

cliente_tabla.csv — client names (can be joined with train/test on Cliente_ID)

producto_tabla.csv — product names (can be joined with train/test on Producto_ID)

town_state.csv — town and state (can be joined with train/test on Agencia_ID)

##  Data fields

Semana — Week number (From Thursday to Wednesday)

Agencia_ID — Sales Depot ID

Canal_ID — Sales Channel ID

Ruta_SAK — Route ID (Several routes = Sales Depot)

Cliente_ID — Client ID

NombreCliente — Client name

Producto_ID — Product ID

NombreProducto — Product Name

Venta_uni_hoy — Sales unit this week (integer)

Venta_hoy — Sales this week (unit: pesos)

Dev_uni_proxima — Returns unit next week (integer)

Dev_proxima — Returns next week (unit: pesos)

Demanda_uni_equil — Adjusted Demand (integer) (This is the target you will predict)

##  How to predict demand

The main strategy behind this script is to tag every possible predictive variable by it's mean demand, according to the train data. For example, we know from the 73 million registers in the train data that the main demand for the product "1212" is 2.84. We will then replace the product ID for this value. 

The exploratory analysis phase consists on findind the mean demand from each variable, allocating this values to the train and test datasets, treating na values, etc.

##  Variables not used

The following variables were not used on this script:

~~NombreCliente — Client name~~

~~NombreProducto — Product Name~~

~~Venta_uni_hoy — Sales unit this week (integer)~~

~~Venta_hoy — Sales this week (unit: pesos)~~

~~Dev_uni_proxima — Returns unit next week (integer)~~

~~Dev_proxima — Returns next week (unit: pesos)~~

##  Outliers

99.9% of the demands are placed between 0 and 100. The 0.1% left is spread between 100 and 5000. These outliers were remove to prevent any influence on the mean demands. 

##  Prediction Model

The chosen predictive model is Random Forest. The scrip uses the Ranger package, to improve memory usage efficiancy. The model is trained by using a 10 million size sample from the train data and 100 trees. The R-Square value reached is around 0.55.  

##  How to run scrips

The codes are split into 6 files (5 for each variable and 1 for the predictive model), due to the large memory load required to process the train data. Each exploratory scrip creates two new files called "test_variable_x_mean.csv" and "train_variable_x_mean.csv" which contains the list of the x variable mean values according to the test and train data. 

The "exploratory_analysis_1.R" must be the first to run, since it creates an extra file "train_sample.csv" (train file without outliers) which is used as source for the remaining codes. 

Using Command Line:
```
Rscript exploratory_analysis_1.R
Rscript exploratory_analysis_2.R
Rscript exploratory_analysis_3.R
Rscript exploratory_analysis_4.R
Rscript exploratory_analysis_5.R
Rscript predictive_analysis.R
```
