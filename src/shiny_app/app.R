library(shiny)
library(shinythemes)
library(ggplot2)
library(tidyverse)
library(readr)
library(ggthemes)
library(plotly)

newdf<-read.csv("https://raw.githubusercontent.com/supertrashpanda/BeautifulBars/main/data/new_long_inc_data.csv",check.names=FALSE)


# Define UI for app that draws a histogram ----
ui <- fluidPage(
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ),
  
  # App title ----
  titlePanel("Education Pays Off"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      h5("Compare median earnings of people with different degree levels by sex over the years"),
      # Input: Slider for the number of bins ----
      sliderInput("yearend",
                  label = "",
                  min = 1989,
                  max = 2020,
                  value =c(1999.49,2021),
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
      helpText("Data from the National Center for Education Statistics")
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      plotOutput(outputId = "plot"),
      htmlOutput("txtout")
      
    )
  )
)


# Define server logic required to draw a histogram ----
server <- function(input, output,session) {
  
  # observe({
  #   options=list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
  #                "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
  #                "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree")
  #   updateSelectInput(session, "education2", choices =options[options!=input$education1])
  # })
 
  df_gap<-reactive({
    if ((input$male)&(!input$female)) {newdf<-newdf[newdf$sex=='Male',]}
    if ((!input$male)&(input$female)) {newdf<-newdf[newdf$sex=='Female',]}
    if((!input$male)&(!input$female)) {newdf<-newdf[newdf$sex=='',]}

    a<-newdf[which((newdf$education%in%c(input$education1,input$education2))&(newdf$money_measure=="Constant 2019 Dollars")),]%>%select(-idtf)
    a$year<-ifelse(a$sex=="Male",a$year-0.1,a$year+0.1)
    a<-a[which((a$year>=input$yearend[1])&(a$year<=input$yearend[2])),]
    male<-a%>%spread(education,avg_income)%>%filter(sex=="Male")
    names(male)<-make.names(names(male),unique = TRUE)
    female<-a%>%spread(education,avg_income)%>%filter(sex=="Female")
    names(female)<-make.names(names(female),unique = TRUE)
    return(list(a=a,male=male,female=female))
  })
  gap1<-reactive({
    inc1<-mean(newdf[which((newdf$education==input$education1)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Male")),"avg_income"],na.rm = TRUE)
    inc2<-mean(newdf[which((newdf$education==input$education2)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Male")),"avg_income"],na.rm=TRUE)
    return(inc2-inc1)
  })
  gap2<-reactive({
    inc1<-mean(newdf[which((newdf$education==input$education1)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Female")),"avg_income"],na.rm = TRUE)
    inc2<-mean(newdf[which((newdf$education==input$education2)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Female")),"avg_income"],na.rm=TRUE)
    return(inc2-inc1)
  })
  output$txtout <- renderUI({
    str1 <- paste("The income gap between workers with education levels of '",input$education1,"' and  '",input$education2,"':",sep="")
    str2 <- paste("for men: $", abs(round(gap1(),2)),sep="")
    str3 <- paste("for women: $", abs(round(gap2(),2)),sep="")
    HTML(paste(str1, str2,str3, sep = '<br/>'))
  })
  
  
    output$plot <- renderPlot({
        df_gap()$a%>%ggplot()+
        geom_smooth(aes(year,avg_income,fill=education),size=0,span=1,alpha=0.1)+
        scale_fill_manual(values=c("grey","grey"))+
        scale_color_manual(values=c("Female"="hotpink2","Male"="steelblue3"))+
        geom_segment(data=df_gap()$male,
                     aes_string(x="year", xend="year",y=colnames(df_gap()$male)[5],yend=colnames(df_gap()$male)[6]),colour = "steelblue3",size=0.5)+
        geom_segment(data=df_gap()$female,
                     aes_string(x="year", xend="year",y=colnames(df_gap()$female)[5],yend=colnames(df_gap()$female)[6]),colour = "hotpink2",size=0.5)+
        geom_point(aes(year,avg_income,color=sex,shape=education),size=1.5,alpha=1,fill="white")+
        scale_shape_manual(values=c(21, 16))+
        scale_x_continuous(breaks=seq(1989, 2021, 1),minor_breaks=seq(1989, 2021, 1))+

        scale_y_continuous(breaks=seq(0, 200000, 50000),minor_breaks=seq(0, 200000, 50000))+
        ylim(0,200000)+
        geom_hline(yintercept=0,alpha=0.5,size=1)+
        labs(x="Year",y="Median Annual Income (in fixded 2019 dollars)",shape="Education Levels\nto compare",
             fill="Education Levels\nto compare",color="Sex\n(with different colors)")+
        theme_minimal()+
        theme(legend.position = c(0.6, 0.95),legend.justification=c(0.5, 1),
              legend.box = "horizontal",axis.text.x = element_text(size=8,angle=45),
              panel.grid.minor.y = element_blank(),panel.grid.major.x = element_blank())
      })

}

# Create Shiny app ----
options(shiny.sanitize.errors = TRUE)
shinyApp(ui = ui, server = server)


