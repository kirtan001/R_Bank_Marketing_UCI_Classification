library(plumber)
library(tidymodels)
library(ranger)
library(xgboost)

# Load the trained model
# Ensure model.rds is in the same directory (src/)
model <- readRDS("model.rds")

#* @apiTitle Bank Marketing Prediction API

#* Health Check
#* @get /health
function() { 
  list(status = "ok", message = "Bank Marketing Model is Ready") 
}

#* Predict Term Deposit Subscription
#* Expects JSON input with features: age, job, marital, education, etc.
#* @post /predict
function(req) {
  input_data <- jsonlite::fromJSON(req$postBody)
  
  # Ensure input is a data frame
  if (!is.data.frame(input_data)) {
    input_data <- as.data.frame(input_data)
  }
  
  # Predict Class and Probability
  pred_class <- predict(model, input_data) %>% pull(.pred_class)
  pred_prob  <- predict(model, input_data, type = "prob") %>% pull(.pred_Yes)
  
  list(
    prediction = pred_class,
    probability = pred_prob
  )
}
