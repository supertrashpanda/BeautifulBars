dashboardPage(
  dashboardHeader(title = "Education Pays Off"),
  dashboardSidebar(
    collapsed = FALSE,
    tags$h4("Compare median earnings of people with different degree levels by sex during the following period:",
            style = "padding: 10px;"),
    sliderInput("yearend",
                label = "",
                min = 1989,
                max = 2021,
                value =c(2000,2021),
                sep=""),
    selectInput(inputId = "education1", label = "Choose one education level:",
                choices = list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
                               "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
                               "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree"),
                selected = "High school completion"),
    selectInput(inputId = "education2", label = "Choose another education level to compare:",
                choices = list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
                               "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
                               "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree"),
                selected = "Bachelor's degree"),
    checkboxInput("male","Male", TRUE),
    checkboxInput("female","Female", TRUE),
    hr(),
    helpText("Data from the National Center for Education Statistics",
             style = "left: 0.8em; position: relative;")
  ),
  
  dashboardBody(
    # h3("Compare median earnings of people with different degree levels by sex over the years"),
    # fluidRow(
    #   column(width = 3,
    #          sliderInput("yearend",label = "",min = 1989, max = 2020,value =c(1999.49,2020), sep="")
    #   ),
    #   column(width = 3, 
    #          selectInput(inputId = "education2", label = "First Education:", 
    #                      choices = list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
    #                                     "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
    #                                     "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree"), 
    #                      selected = "Bachelor's degree")
    #   ),
    #   column(width = 3, 
    #          selectInput(inputId = "education2", label = "Second Education:", 
    #                      choices = list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
    #                                     "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
    #                                     "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree"), 
    #                      selected = "Bachelor's degree")
    #   ),
    #   column(width = 2, 
    #          checkboxInput("male","Male", TRUE)
    #   ),
    #   
    #   column(width = 2, 
    #          checkboxInput("female","Female", TRUE)
    #   )
    # ),
    
    fluidRow(
      valueBoxOutput("male"),
      valueBoxOutput("female"),
      valueBoxOutput("box3")
    ),
    
    fluidRow(
      tabBox(
        width = 8,
        height = "40em",
        title = tagList(shiny::icon("bar-chart-o"), "Visualization"),
        tabPanel("Tab1",
                 plotOutput(outputId = "plot", height = "35em")
        ),
        tabPanel("Tab2", 
                 "Tab content 2")
      ),
      
      # box(
      #   width = 8, solidHeader = TRUE,
      #   status="primary",
      #   title = paste("Annual Salary Difference Between Workers with The Two Education Levels"),
      #   plotOutput(outputId = "plot", height = "35em"),
      #   height = "40em"
      #   # htmlOutput("txtout")
      # ),
      
      box(
        width = 4,
        height = "40em",
        # solidHeader = TRUE,
        # status="primary",
        # title = paste("How many years"),
        h1("HOW MANY YEARS CAN YOU PAYOFF YOUR TUITION?", 
           style = "font-weight: bold; color:#005266; font-family: Impact, fantasy;line-height: 35px !important;padding: 5px; margin-top: 0;"),
        h5("The box above illustrates the number of years one should work to cover the opportunity cost for pursuing a higher degree after recieving the degree.", 
           style = "padding: 5px; color:#006080;font-family:Arial, sans-serif; "),
        hr(),
        textInput("sumfee",
                  label = "Cumulated Tuition Fee to pursue a higher degree",
                  value ="4000"),
        textInput("year",
                  label = "Number of years needed to recieve the higher degree",
                  value = "5"),
        selectInput(inputId = "sex", label = "Gender",
                    choices = list("Male", "Female"))
        )
      )
      
      # column(width=3,
      #        box(
      #          width = NULL,
      #          solidHeader = TRUE,
      #          status="primary",
      #          title = "Gender Analysis",
      #          plotOutput(outputId = "gender", height = "15em"),
      #          height = "19em"
      #        ),
      #        
      #        box(
      #          width = NULL,
      #          solidHeader = TRUE,
      #          status="primary",
    #          title = "Education Matters",
    #          plotOutput(outputId = "Education", height = "15em"),
    #          height = "19em"
    #        )
    #        
    # )
  )
  
)




