


scorer <- function(input, output, session) {
  
  admission_method <- reactive({
    input$admission_method
  })
  
  imd_score <- reactive({
    input$imd_score
  })
  
  age_at_discharge <- reactive({
    input$age_at_discharge
  })
  
  emerg_last_year <- reactive({
    input$emerg_last_year
  })
  
  emerg_last_30_days <- reactive({
    input$emerg_last_30_days
  })
  
  comorbidities <- reactive({
    selected <- input$comorb
    
    v <- as.numeric(comorb_choices %in% selected)
    names(v) <- comorb_choices
    
    data.frame(t(v))
  })
  
  trust_code <- reactive({
    input$trust_code
  })
  
  df <- reactive({
    i <- input$calculate_score
    if(i < 1) {
      return(NULL)
    }
    isolate({
    data.frame(admission_method = admission_method(),
               imd_score = imd_score(),
               age_at_discharge = age_at_discharge(),
               emerg_last_year = emerg_last_year(),
               emerg_last_30_days = emerg_last_30_days(),
               comorbidities(),
               trust_code = trust_code())
    })
  })
  
  
  pred <- reactive({
    if(is.null(df())) {
      return(NULL)
    } else {
      return(calculate_risk(df()))
    }
  })
  
  output$pred <- renderText(
    pred()
    )
  
  
  return(df)
}


comorb_choices <- c("congestive_heart_failure",
                    "peripheral_vascular_disease",
                    "chronic_pulmonary_disease",
                    "diabetes_with_chronic_complications",
                    "renal_disease", "metastatic_cancer_with_solid_tumor",
                    "other_malignant_cancer", "moderate_severe_liver_disease",
                    "other_liver_disease", "hemiplegia_or_paraplegia", "dementia"
)

names(comorb_choices) <- c("Congestive Heart Failure", "Peripheral Vascular Disease", "Chronic Pulmonary Disease",
                           "Diabetes With Chronic Complications", "Renal Disease", "Metastatic Cancer with Solid Tumour", 
                           "Other Malignant Cancer", "Moderate Liver Disease", "Other Liver Disease", "Hemiplegia or Paraplegia",
                           "Dementia"
)

trust_choices <- trusts$trust_code
names(trust_choices) <- trusts$trust_name



scorerUI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    titlePanel("Score Calculator"),
    
    
    fluidRow(
      box(width = 12,
      
      column(3,
             wellPanel(height = "100px",
             numericInput(ns("imd_score"), 
                          label = "Index of Multiple Deprivation (IMD) Score", 
                          value = NA, min =  0, max = 82),
             p(class = "nb","1 (least deprived) to >50 (most deprived)"),
             numericInput(ns("age_at_discharge"), "Age at discharge", value = NA, min = 18, max = 100),
             checkboxInput(ns("admission_method"), "Emergency Admission")
             )),
      column(3,
             wellPanel(height = "100px",
             numericInput(ns("emerg_last_year"), "Number of Emergency Admissions Last Year", value = NA, min = 0, max = 20),
             checkboxInput(ns("emerg_last_30_days"), "Emergency Admission in Last 30 Days"),
             br(),
             )),
      column(3,
             wellPanel(height = "100px",
             checkboxGroupInput(ns("comorb"), "Medical History", choices = comorb_choices, selected = "")
             )),
      column(3,
             wellPanel(height = "1000px",
             selectInput(ns("trust_code"), "Trust", choices = trust_choices, selected = ""),
             br()
             ))
    )),
    
    hr(),
    
    fluidRow(
      column(2,
             actionButton(ns("calculate_score"), "Calculate Risk")
             ),
      column(4,
             box(
               h4("The calculated risk score is: "),
               br(),
               textOutput(ns("pred"))
             )
             )

    )

  )
}


#runApp(list(server = server, ui = ui))



