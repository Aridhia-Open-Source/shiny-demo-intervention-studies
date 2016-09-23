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




server <- function(input, output, session) {
  
  callModule(scorer, "scorer")
  
  threshold_line <- reactive({
    
    threshold <- input$threshold
    breaks <- input$breaks
    
    if (threshold >= input$breaks[2]) {
      threshold <- threshold + 0.2
    }
    
    if (threshold <= input$breaks[1]) {
      
      threshold <- threshold - 0.2
      
    }
    
    data.frame(x = c(1.9, 3.5), y = threshold)
    
  })
  
  
  low_mod_high <- reactive({
    
    cut(pred, breaks = c(-0.1, input$breaks, 1.1), labels = c("Low", "Moderate", "High"))
    
  })
  
  discharged <- reactive({
    
    cut(pred, breaks = c(-0.1, input$threshold, 1.1), labels = c("Yes", "No"))
    
  })
  
  
  risk_group_points <- reactive({
    
    groups <- low_mod_high()
    
    y_offset <- ifelse(groups == "Low", -0.2, ifelse(groups == "Moderate", 0, 0.2))
    
    data.frame(x = x_risk, y = y_risk + y_offset)
    
  })
  
  discharge_group_points <- reactive({
    
    dis <- discharged()
    
    x_dis <- x_discharge + response * 2
    y_dis <- y_discharge + ifelse(dis == "Yes", -0.3, 0.3)
    
    data.frame(x = x_dis, y = y_dis)
    
  })
  
  
  
  points_df <- reactive({
    
    time <- input$time
    risk_points <- risk_group_points()
    discharge_points <- discharge_group_points()
    risk <- low_mod_high()
    
    start_points$readmitted <- response
    start_points$risk <- risk
    start_points$risk_new <- factor("Not Scored", levels = c("Not Scored", "Low", "Moderate", "High"))
    
    if (time == 0) {
      return(start_points)
    }
    
    
    ## move points into the risk rectangles
    start_points[1:time, "x"] <- risk_points[1:time, "x"]
    start_points[1:time, "y"] <- risk_points[1:time, "y"]
    
    
    ## move points into the discharge rectangles
    if (time > 20) {
      
      start_points[1:(time-20), "x"] <- discharge_points[1:(time-20), "x"]
      start_points[1:(time-20), "y"] <- discharge_points[1:(time-20), "y"]
      
    }
    
    
    start_points$risk_new <- factor(ifelse(start_points$x >= 1.9,
                                           as.character(start_points$risk),
                                           as.character(start_points$risk_new)),
                                    levels = c("High", "Moderate","Low", "Not Scored"))
    start_points
    
  })
  
  #incorrectly kept in hospital
  count_not_discharged <- reactive({
    count <- points_df() %>% filter(readmitted == 0 & x >= 3.9 & y>=0.6) %>% summarise(count = n())
    count <- count[1,1]
    total <- points_df() %>% filter(x >= 3.9) %>% summarise(count = n())
    total <- total[1,1]
    count_readmitted <- data.frame("x"=c(4.0),
                                   "y"=c(0.66),
                                   "label" = c(paste0(ifelse(total == 0,
                                                             "0",
                                                             round(count/total*100)), 
                                                      "% cases intervened in when")))
    count_readmitted
  })
  
  #incorrectly discharged from hospital
  count_discharged <- reactive({
    count <- points_df() %>% filter(readmitted == 1 & x >= 3.9 & y>=0 & y < 0.4) %>% summarise(count = n())
    count <- count[1,1]
    total <- points_df() %>% filter(x >= 3.9) %>% summarise(count = n())
    total <- total[1,1]
    count_not_admitted <- data.frame("x"=c(6.5),
                                     "y"=c(0.06),
                                     "label" = c(paste0(ifelse(total == "0",
                                                               "0",
                                                               round(count/total*100)),
                                                        "% cases not intervened in when")))
    count_not_admitted
  })
  
  
  # 2nd line of text for labels inside right hand side boxes
  additional_text1 <- data.frame(x=c(4), y= c(0.62), label = c("it wasn't necessary"))
  additional_text2 <- data.frame(x=c(6.5), y= c(0.02), label = c("an intervention may have helped"))
  
  
  # Data for key showing readmitted & not readmitted
  key <- data.frame(x1 = c(-0.3, -0.3), y1 = c(0, -0.05), fill_col = c(1,0), x2 = c(-0.2, -0.2), y2 = c(-0.01, -0.06), labels = c("- Asthma Exacerbation", "- No Asthma Exacerbation"))
  
  
  # Title for circle
  circle_title <- data.frame(x = c(0, 0), y = c(1, 0.94), text = c("Children at risk of", "asthma exacerbations"))
  
  # Title for risk boxes
  risk_title <- data.frame(x = c(1.9, 1.9, 1.9), y = c(1.45, 1.4, 1.35), text = c("Classification of risk",  "of readmission within", "30 days of discharge"))
  
  rects_df <- reactive({
    
    breaks <- c(0, input$breaks, 1)
    
    
    rects_x <- c(1.9, 1.9, 1.9, 3.9, 3.9)
    rects_x2 <- c(3.5, 3.5, 3.5, 6.6, 6.6)
    rects_y <- c(-0.22, breaks[2] - 0.02, breaks[3] + 0.18, 0, 0.6)
    rects_y2 <- c(breaks[2] - 0.18, breaks[3] + 0.02, 1.22, 0.4, 1)
    labels <- c("Low Risk", "Moderate Risk", "High Risk", "Cases Not Intervened In", "Cases Intervened In")
    labels_x <- sapply(seq_along(rects_x), function(i) (rects_x[i] + rects_x2[i])/2)
    
    rects_df <- data.frame(rects_x, rects_x2, rects_y, rects_y2, labels, labels_x)
    
    
    rects_df
    
  })
  
  col_lines_df <- reactive({
    breaks <- c(0, input$breaks, 1)
    
    x <- rep(1.9, 6)
    y <- c(-0.22, breaks[2] - 0.18, breaks[2] - 0.02, breaks[3] + 0.02, breaks[3] + 0.18, 1.22)
    gr <- rep(c("Low", "Moderate", "High"), each = 2)
    
    data.frame(x, y, gr) %>% group_by(gr)
  })
  
  
  #output$test <- renderDataTable({points_df()})
  
  
  ggvis(points_df) %>%
    layer_points(~x, ~y, stroke = ~risk_new, fillOpacity = ~readmitted, fill = ~risk_new, strokeWidth := 2) %>%
    #layer_points(~x, ~y, stroke = ~risk, shape = ~factor(readmitted), fill = ~risk) %>%
    layer_rects(data = rects_df, x = ~rects_x, x2 = ~rects_x2, y = ~rects_y, y2 = ~rects_y2,
                stroke := "black", fillOpacity := 0) %>%
    layer_paths(data = col_lines_df, x = ~x, y = ~y, stroke = ~gr, strokeWidth := 5) %>%
    layer_paths(data = circ_points, ~x, ~y, interpolate := "linear-closed") %>%
    layer_paths(data = threshold_line, ~x, ~y, stroke := "red") %>%
    layer_text(data = rects_df, x = ~labels_x, y = ~rects_y2 + 0.03, text := ~labels, fontSize := 20,
               fontStyle := "bold", align := "center", baseline := "middle", fill := "grey") %>%
    layer_text(data = count_not_discharged, ~x, ~y, text := ~label) %>% 
    layer_text(data = count_discharged, ~x, ~y, text := ~label, align:= "right") %>% 
    layer_text(data = additional_text1, ~x, ~y, text:= ~label, align :="left") %>%
    layer_text(data = additional_text2, ~x, ~y, text:= ~label, align :="right") %>%
    layer_text(data = circle_title, ~x, ~y, text:= ~text, align := "center", fontSize:= 20, fontStyle := "bold", fill := "grey") %>%
    layer_text(data = text_one, ~x, ~y, text:= ~text, fontSize:= 13, align := "center", baseline := "middle") %>%
    layer_text(data = text_two, ~x, ~y, text:= ~text, fontSize:= 13, align := "center", baseline := "middle") %>%
    layer_text(data = text_three, ~x, ~y, text:= ~text, fontSize:= 13, align := "center", baseline := "middle") %>%
    layer_points(data = key, x= ~x1, y= ~y1, stroke := "lightblue", fill := "lightblue", fillOpacity = ~fill_col, strokeWidth := 2) %>% 
    layer_text(data = key, x= ~x2, y= ~y2, text:= ~labels, fill := "black") %>%
    set_options(duration = 500, width = 1100, height = 800) %>%
    scale_numeric("x", domain = c(-1.5, 7)) %>%
    scale_numeric("y", domain = c(-0.2, 1.6)) %>%
    scale_nominal("fill", domain = c("High", "Moderate","Low", "Not Scored"), range = c("red", "orange", "green", "lightblue")) %>%
    scale_nominal("stroke", domain = c("High", "Moderate","Low", "Not Scored"), range = c("red", "orange", "green", "lightblue")) %>%
    add_legend("stroke", title = "Risk") %>%
    add_legend("fill", title = "Risk") %>%
    hide_axis("x") %>%
    hide_axis("y") %>%
    bind_shiny("plot")
  
}