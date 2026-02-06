library(shiny)
library(bslib)
library(tidymodels)
library(tidyverse)
library(ranger)
library(xgboost)

# Load Model (Single Best Model)
# Ensure 'model.rds' exists in the same directory (src/)
model <- readRDS("model.rds")

# UI Definition
ui <- page_sidebar(
  theme = bs_theme(bootswatch = "flatly"),
  title = "Bank Marketing AI (Interactive)",
  sidebar = sidebar(
    title = "Client Profile",
    numericInput("age", "Age", 35, 18, 100),
    selectInput("job", "Job", choices = c("admin.", "blue-collar", "technician", "services", "management", "retired", "entrepreneur", "self-employed", "housemaid", "unemployed", "student", "unknown")),
    selectInput("marital", "Marital Status", choices = c("married", "single", "divorced", "unknown")),
    selectInput("education", "Education", choices = c("university.degree", "high.school", "basic.9y", "professional.course", "basic.4y", "basic.6y", "unknown", "illiterate")),
    selectInput("default", "Has Credit in Default?", choices = c("no", "yes", "unknown")),
    selectInput("housing", "Has Housing Loan?", choices = c("no", "yes", "unknown")),
    selectInput("loan", "Has Personal Loan?", choices = c("no", "yes", "unknown")),
    hr(),
    actionButton("predict_btn", "Run Prediction", class = "btn-success w-100")
  ),
  
  layout_columns(
    col_widths = c(12),
    card(
      card_header("Prediction Output"),
      tableOutput("pred_results")
    )
  )
)

# Server Logic
server <- function(input, output) {
  
  predictions <- eventReactive(input$predict_btn, {
    
    # Construct Input DataFrame
    # Note: 'duration' is deliberately excluded as per model inference hygiene
    input_df <- data.frame(
      age = input$age,
      job = input$job,
      marital = input$marital,
      education = input$education,
      default = input$default,
      housing = input$housing,
      loan = input$loan,
      # Default mock values for other features to allow prediction
      contact = "cellular", 
      month = "may", 
      day_of_week = "mon",
      campaign = 1, 
      pdays = 999, 
      previous = 0, 
      poutcome = "nonexistent",
      emp.var.rate = -1.8, 
      cons.price.idx = 92.8, 
      cons.conf.idx = -46.2, 
      euribor3m = 1.2, 
      nr.employed = 5099
    )
    
    # Predict Class
    pred_class <- tryCatch({
       predict(model, input_df) %>% pull(.pred_class)
    }, error = function(e) "Error")
    
    # Predict Probability
    pred_prob <- tryCatch({
       predict(model, input_df, type = "prob") %>% pull(.pred_Yes)
    }, error = function(e) 0)
    
    data.frame(
      Result = c("Predicted Class", "Probability (Subscribes)"),
      Value = c(as.character(pred_class), paste0(round(pred_prob * 100, 2), "%"))
    )
  })
  
  output$pred_results <- renderTable({
    predictions()
  }, striped = TRUE, hover = TRUE, colnames = FALSE)
}

shinyApp(ui, server)
