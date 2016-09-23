


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
  
  output$pred <- renderText(pred())
  
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
    checkboxInput(ns("admission_method"), "Emergency Admission"),
    numericInput(ns("imd_score"), "IMD Score", value = NA, min =  0, max = 82),
    numericInput(ns("age_at_discharge"), "Age", value = NA, min = 18, max = 100),
    numericInput(ns("emerg_last_year"), "Emergency Admissions Last Year", value = NA, min = 0, max = 20),
    checkboxInput(ns("emerg_last_30_days"), "Emergency Admission in Last 30 Days"),
    checkboxGroupInput(ns("comorb"), "Medical History", choices = comorb_choices, selected = ""),
    selectInput(ns("trust_code"), "Trust", choices = trust_choices, selected = ""),
  
    actionButton(ns("calculate_score"), "Calculate Risk"),

    textOutput(ns("pred"))  
  )
}


#runApp(list(server = server, ui = ui))



