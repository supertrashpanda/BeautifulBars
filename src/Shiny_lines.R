library(shiny)
library(shinythemes)
library(ggplot2)
library(tidyverse)
library(plotly)
setwd("/Users/lingyunfan/all_repos/data_viz_cmpt/BeautifulBars")
newdf<-read.csv("data/new_long_inc_data.csv")


# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
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
                  min = 1990,
                  max = 2020,
                  value =c(1999.49,2020)),
      selectInput(inputId = "education1", label = "Choose one education level:", 
                  choices = list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
                                 "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
                                 "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree"), 
                  selected = "High school completion"),
      selectInput(inputId = "education2", label = "Choose another education level to compare:", 
                  choices = list("Less than 9th grade" = "Less than 9th grade", "Some high school, no completion" = "Some high school, no completion", "High school completion" = "High school completion",
                                 "Some college, no degree" = "Some college, no degree","Associate's degree"="Associate's degree","Bachelor's degree"="Bachelor's degree","Master's degree"="Master's degree",
                                 "Professional degree"="Professional degree","Doctor's degree"="Doctor's degree"), 
                  selected = "Bachelor's degree")
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
    
      plotOutput(outputId = "plot"),
      verbatimTextOutput("txtout")
      
    )
  )
)


# Define server logic required to draw a histogram ----
server <- function(input, output) {
  df_gap<-reactive({
    a<-newdf[which((newdf$education%in%c(input$education1,input$education2))&(newdf$money_measure=="Constant 2019 Dollars")),]%>%select(-idtf)
    a$year<-ifelse(a$sex=="Male",a$year-0.15,a$year+0.15)
    a<-a[which((a$year>=input$yearend[1])&(a$year<=input$yearend[2])),]
    male<-a%>%spread(education,avg_income)%>%filter(sex=="Male")
    names(male)<-make.names(names(male),unique = TRUE)
    female<-a%>%spread(education,avg_income)%>%filter(sex=="Female")
    names(female)<-make.names(names(female),unique = TRUE)
    return(list(a=a,male=male,female=female))
  })
    output$txtout <- renderText({
      colnames(df_gap()$female[5:6])
    })
    output$plot <- renderPlot({
        df_gap()$a%>%ggplot()+
        geom_smooth(aes(year,avg_income,fill=education),size=0,span=1,alpha=0.1)+
        scale_fill_manual(values=c("grey","grey"))+
        scale_color_manual(values=c("hotpink2","magenta"))+
        geom_segment(data=df_gap()$male,
                     aes_string(x="year", xend="year",y=colnames(df_gap()$male)[5],yend=colnames(df_gap()$male)[6]),colour = "magenta",size=0.5)+
        geom_segment(data=df_gap()$female,
                     aes_string(x="year", xend="year",y=colnames(df_gap()$female)[5],yend=colnames(df_gap()$female)[6]),colour = "hotpink2",size=0.5)+
        geom_point(aes(year,avg_income,color=sex,shape=education),size=1.5,alpha=1,fill="white")+
        scale_shape_manual(values=c(21, 16))+
        ylim(0,200000)+scale_x_continuous(breaks=seq(1990, 2020, 1))+
        labs(x="Year",y="Median Income (in fixded 2019 dollars)",shape="Education Levels\nto compare",
             fill="Education Levels\nto compare",color="Sex\n(with different colors)")+
        theme_minimal()+
        theme(legend.position = c(0.6, 0.98),
              legend.justification=c(0.5, 1),legend.box = "horizontal")+
        theme(axis.text.x = element_text(angle=45,size=6))
      })

}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
