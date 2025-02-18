
header <- dashboardHeader(disable = TRUE)
sidebar <- dashboardSidebar(disable = TRUE)

body <- dashboardBody(
  navbarPage("Intervention Studies", theme = shinytheme("flatly"),
    tabPanel("Simulation",
      fluidPage(
        tags$head(tags$style(HTML('
          .ggvis-output.recalculating {
            --shiny-fade-opacity: 1;
          }
        '))),
        box(width = 12,
          fluidRow(
            column(3,
              wellPanel(width = 12,
                sliderInput("time", HTML("<b>Start the timer to begin the simulation</b>"),
                            min = 0, max = 200, value = 0, step = 1,
                            animate = animationOptions(loop = TRUE,
                                                       interval = 550,
                                                       playButton = icon("play", "fa-2x"),
                                                       pauseButton = icon("pause", "fa-2x"))
                ),
                sliderInput("breaks", HTML("<b>Move the slider to change the thresholds for each risk group</b>"),
                            min = 0, max = 1, value = c(0.33, 0.67), step = 0.01),
                sliderInput("threshold", "Change the threshold to decide which cases should be intervened in",
                            min = 0, max = 1, value = 0.5, step = 0.01)
             
              )
            ),
            column(9,
              ggvisOutput("plot"),
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
      scorerUI("scorer")
    ),
    documentation_tab()
  )
)

shinyUI(
  dashboardPage(header, sidebar, body)
)

