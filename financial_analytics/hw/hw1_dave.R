# Needed Libraries for Analysis #
library(gmodels)
library(vcd)
library(smbinning)
library(rsample)
library(tidyverse)

accepts <- read_csv("financial_analytics/data/accepts.csv")

# build a train/test split based on 70/30 from prompt
set.seed(42)
test_split <- initial_split(accepts, .7)

# training data
train <- analysis(test_split)

# validation data
test <- assessment(test_split)

