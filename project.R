# The codes are written by Shouman Barua Shuvo

#___________________
#   Read the csv
#___________________

# Change working directory
setwd("~/Documents/R_Project")
# Get the file
data <- read.csv("final_data.csv")
data # read successful


#___________________
#     Analyzing
#___________________


# libraries
library(tidyverse)
library(ggplot2)
# install.packages('stringi')
library(caret)
library(car)
library(neuralnet)
library(Metrics)
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
# install.packages("GGalley")
library(GGally)

# removing some columns from data
data <- data %>%
  select( -serial, -model_name, -release_date, -lowest_price, -highest_price)
# I do not think model name and release data has relation
data
# plotting
ggpairs(data)

print(cor(data[,1:7]))
ggplot(data, aes(x =best_price, y = sellers_amount)) + geom_point()+stat_smooth(method=lm)

corMatrix<-round(cor(data),2)
corMatrix
# finding correlation
findCorrelation(corMatrix, cutoff = 0.7, names = TRUE)
# regression
reg<-lm(sellers_amount~os+popularity+best_price+screen_size+memory_size+battery_size,data)
summary(reg)
vif(reg) 


# only screen size is making trouble here -- no longer
# reg<-lm(sellers_amount~os+popularity+best_price+memory_size+battery_size,data)
# summary(reg)
# vif(reg) 

# declare the function
scale <- function(x){(x - min(x)) / (max(x) - min(x))}
# mutating the data
data <- data %>%
  mutate_all(scale)
set.seed(12345)

#___________________
# Creating a Model
#___________________

train_data <- sample_frac(data, replace = FALSE, size = 0.80)
test_data <- anti_join(data, train_data)
set.seed(12321)
# NN stands for neural network
NN <- neuralnet(sellers_amount~os+popularity+screen_size+best_price+memory_size+battery_size, data = data)
plot(NN, rep = 'best')

# Checking the accuracy
test_nn_output <- compute(NN, test_data[, 1:7])$net.result
NN_test_RMSE <- rmse(test_nn_output, test_data[,4])
NN_test_RMSE # showing a good model

# Finding the sum of square error
test_reg_output <- predict(reg, test_data)
reg_test_SSE <- sum((test_reg_output - test_data[,4])^2)/2
reg_test_SSE
