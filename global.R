####################
###### GLOBAL ######
####################


# Load libraries
library(ggvis)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(dplyr)

# Read data
trusts <- read.csv("data/trusts.csv")
recalibrated <- readRDS("data/recalibrated_model.rds")
parr30_sample <- read.csv("data/parr30_sample.csv")

# Source all the scripts in code folder
for (file in list.files("code", full.names = TRUE)) {
  source(file, local = TRUE)
}

# Data prep -----------------------------------
N <- 200

## points to go in the first section (far left)
circle_x <- rnorm(N, 0, 0.4)
circle_y <- rnorm(N, 0.5, 0.08)

## points to go in last section patients after discharge or not discharged
x_discharge <- runif(N, 4, 4.5)
y_discharge <- runif(N, 0.4, 0.6)

pred <- predict(recalibrated, type = "response")[1:N]

## points to go in the middle section, risk assessment
x_risk <- runif(N, 2, 3)
y_risk <- pred

response <- parr30_sample[1:N, "readmitted"]

start_points <- data.frame(x = circle_x, y = circle_y)

## define ellipse to put first points in
t <- seq(0, 2*pi, length.out = 100)
circ_points <- data.frame(x = 1.5 * sin(t), y = 0.4 * cos(t) + 0.5)

review_text <- "The patients in this simulation \n are children at risk of severe \n asthma exacerbations. Some will \n have a severe asthma exacerbation\n during the clinical trial period \n and some won't."
predict_text <- "The risk of severe asthma exacerbations\n occuring is predicted based on a\n number of demographic, clinical and\n genetic factors. The thresholds\n defining Low, Moderate and High risk\n can be altered using the slider\n on the left."
discharged_text <- "You can choose to intervene in cases of\n high risk. This could be a more\n aggressive therapy or more stringent\n monitoring of the patient. In some\n cases you will intervene when it is\n not necessary and in some cases\n you will choose not to intervene\n and a patient will have a severe\n asthma exacerbation."
# There are financial and health\n costs associated with each outcome. Are you ok with the results?"

text_one <- data.frame(x = 0, y = c(1.6, 1.55, 1.5, 1.45, 1.4, 1.35), text = strsplit(review_text, "\n")[[1]])
text_two <- data.frame(x = 2.7, y = c(1.65, 1.6, 1.55, 1.5, 1.45, 1.4, 1.35), text = strsplit(predict_text, "\n")[[1]])
text_three <- data.frame(x = 5.25, y = c(1.7, 1.65, 1.6, 1.55, 1.5, 1.45, 1.4, 1.35, 1.3), text = strsplit(discharged_text, "\n")[[1]])
