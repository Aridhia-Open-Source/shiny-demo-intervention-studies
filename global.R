
library(ggvis)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(dplyr)

trusts <- read.csv("data/trusts.csv")
recalibrated <- readRDS("data/recalibrated_model.rds")
parr30_sample <- read.csv("data/parr30_sample.csv")

source("scorer.R")


