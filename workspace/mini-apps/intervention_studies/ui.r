#install.packages('xapparr30')
#library(xapparr30)

#install.packages('ggvis')
#library(ggvis)

#library(shiny)

#install.packages('shinydashboard')
#library(shinydashboard)

#library(shinythemes)

xap.require("xapparr30",
            "ggvis",
            "shiny",
            "shinydashboard",
            "shinythemes",
            "dplyr")

source("scorer.r")



# header <- dashboardHeader(
#   title = "Predicting the risk of hospital readmission with PARR-30",
#   titleWidth = 560
# )

header <- dashboardHeader(disable = TRUE)

sidebar <- dashboardSidebar(disable = TRUE)

body <- dashboardBody(
  
  navbarPage("Intervention Studies", theme = shinytheme("flatly"),
    tabPanel("Simulation",
            
  
  fluidPage(
    box(width = 12,
      fluidRow(
        column(3,
          wellPanel(width = 12,
               HTML("Asthma is a complex disease known to be influenced by both genetic and environmental factors. 26.7 million or about 9.7% of the population in the United States have had asthma during their lifetime. In the year 2000, asthma exacerbations resulted in 1,499 deaths, 1.1 million hospital days, and $2.9 billion in direct expenditures in the United States. The ability to predict severe asthma exacerbations would therefore have direct prognostic significance and might form the basis for the development of novel therapeutic interventions."),
               br(),
               br(),
               sliderInput("time", 
                           HTML('<b>Start the timer to begin the simulation</b>'),
                           min = 0, 
                           max = 200, 
                           value = 0,
                           step = 1,
                           animate = animationOptions(loop = TRUE,
                                                      interval = 550,
                                                      playButton = icon('play', "fa-2x"),
                                                      pauseButton = icon('pause', "fa-2x"))),
               
             
               sliderInput("breaks",
                           HTML('<b>Move the slider to change the thresholds for each risk group</b>'),
                           min = 0,
                           max = 1,
                           value = c(0.33, 0.67),
                           step = 0.01),
               sliderInput("threshold",
                         "Change the threshold to decide which cases should be intervened in",
                         min = 0,
                         max = 1, 
                         value = 0.5,
                         step = 0.01)
             
          )
      ),
      column(9,
             ggvisOutput("plot"),
             # dataTableOutput("test"),
             tags$head(tags$style(HTML('
                                       .skin-blue .main-header .logo {
                                       background-color: #3c8dbc;
                                       }
                                       .skin-blue .main-header .logo:hover {
                                       background-color: #3c8dbc;
                                       }
                                       ')))
             )
      
      
      
             )
             )
  
             )
    ),
  tabPanel("Scorer",
          scorerUI("scorer"))
  )
)


shinyUI(
  dashboardPage(header, sidebar, body)
)




