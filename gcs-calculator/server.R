#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

setwd("~/Documents/GitHub/gcs_calculator")
library(caret)
library(shiny)
library(ggplot2)

##### SERVER #####

# Define server logic for random distribution application
shinyServer(function(input, output) {
     inputdata <- reactive({
          df <- data.frame(
               Age = as.numeric(input$Age),
               Gender = as.factor(input$Gender),
               ISSAIS = as.numeric(input$ISSAIS),
               Alcohol = as.factor(input$Alcohol),
               GCSTOT = as.numeric(input$GCSTOT)
               )
          colnames(df) <- c("Age","Gender", "ISSAIS", "Alcohol", "GCSTOT")    
          return(df)
          })
    
    output$result <- renderTable({inputdata()})
    
    #Mortality Model
    expired_model <- readRDS("expired_model.rds")
    output$mortality <- renderPrint({
         preds <- predict(expired_model, newdata = inputdata(), type = "response", se.fit = TRUE)
         critval <- 1.96 ## approx 95% CI
         upr <- round((preds$fit + (critval * preds$se.fit)) *100 , digits = 2)
         lwr <- round((preds$fit - (critval * preds$se.fit)) *100 , digits = 2)
         fit <- round(preds$fit*100, digits = 2)
         paste("Risk of Mortality is ", as.numeric(fit), "%. Confidence Interval [" , lwr, "%, ", upr, "%]", sep ="")
    })
   
    #Home Chance
    home_model <- readRDS("home_model.rds")
    output$home <- renderPrint({
         preds <- predict(home_model, newdata = inputdata(), type = "response", se.fit = TRUE)
         critval <- 1.96 ## approx 95% CI
         upr <- round((preds$fit + (critval * preds$se.fit)) *100 , digits = 2)
         lwr <- round((preds$fit - (critval * preds$se.fit)) *100 , digits = 2)
         fit <- round(preds$fit*100, digits = 2)
         paste("Chance of going home is ", as.numeric(fit), "%. Confidence Interval [" , lwr, "%, ", upr, "%]", sep = "")
    })
    
    #LOS Model
    los_model <- readRDS("los_model.rds")
    output$los <- renderPrint({
         preds <- predict(los_model, newdata = inputdata(), se.fit = TRUE)
         critval <- 1.96 ## approx 95% CI
         upr <- round((preds$fit + (critval * preds$se.fit)), digits = 2)
         lwr <- round((preds$fit - (critval * preds$se.fit)), digits = 2)
         fit <- round(preds$fit, digits = 2)
         paste("Predicted length of stay is ", as.numeric(fit), " days. Confidence Interval [" , lwr, ", ", upr, "]", sep = "")
    })
    
    #Other Model
    other_model <- readRDS("other_model.rds")
    output$other <- renderPrint({
         preds <- predict(other_model, newdata = inputdata(), type = "response", se.fit = TRUE)
         critval <- 1.96 ## approx 95% CI
         upr <- round((preds$fit + (critval * preds$se.fit)) *100 , digits = 2)
         lwr <- round((preds$fit - (critval * preds$se.fit)) *100 , digits = 2)
         fit <- round(preds$fit*100, digits = 2)
         paste("Chance of discharged to other is ", as.numeric(fit), "%. Confidence Interval [" , lwr, "%, ", upr, "%]", sep = "")
    })
    
    #Tracheostomy Model
    tracheostomy_model <- readRDS("tracheostomy_model.rds")
    output$tracheostomy <- renderPrint({
         preds <- predict(tracheostomy_model, newdata = inputdata(), type = "response", se.fit = TRUE)
         critval <- 1.96 ## approx 95% CI
         upr <- round((preds$fit + (critval * preds$se.fit)) *100 , digits = 2)
         lwr <- round((preds$fit - (critval * preds$se.fit)) *100 , digits = 2)
         fit <- round(preds$fit*100, digits = 2)
         paste("Chance of discharged to other is ", as.numeric(fit), "%. Confidence Interval [" , lwr, "%, ", upr, "%]", sep = "")
    })
})
    

