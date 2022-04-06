library(shiny)
library(shinythemes)
library(ggplot2)
library(tidyverse)
setwd("/Users/lingyunfan/all_repos/data_viz_cmpt/BeautifulBars")
newdf<-read.csv("data/new_long_inc_data.csv")
df_gap<-newdf[which((newdf$education%in%c("Bachelor's degree","High school completion (includes equivalency)")&(newdf$money_measure=="Current Dollars"))),]
df_gap<-df_gap[,-7]
df_gap$year<-ifelse(df_gap$sex=="Male",df_gap$year-0.15,df_gap$year+0.15)
male<-df_gap%>%spread(education,avg_income)%>%filter(sex=="Male")
female<-df_gap%>%spread(education,avg_income)%>%filter(sex=="Female")

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Check out this chart"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "yearend",
                  label = "ends at:",
                  min = 1990,
                  max = 2020,
                  value =2020)
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Histogram ----
      plotOutput(outputId = "plot")
      
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  output$plot <- renderPlot({
    df_gap[which(df_gap$year<=input$yearend),]%>%ggplot()+
      geom_smooth(aes(year,avg_income,color=sex),size=0,span=1)+
      scale_color_manual(values=c("darkred","steelblue"))+
      geom_segment(data=male[which(male$year<=input$yearend),],aes(x=year,xend=year,y=`High school completion (includes equivalency)`,yend=`Bachelor's degree`),colour = "steelblue",size=1.5)+
      geom_segment(data=female[which(female$year<=input$yearend),],aes(x=year,xend=year,y=`High school completion (includes equivalency)`,yend=`Bachelor's degree`),colour = "darkred",size=1.5)+
      geom_point(aes(year,avg_income,color=sex),size=1.5,alpha=1,shape=21,fill="white")+
      ylim(0,80000)+scale_x_continuous(breaks=seq(1990, 2020, 2))+
      annotate("text", x = 2000,y = 60000, label = "Bachelor's degree",size=3)+
      annotate("text", x = 2002,y = 22000, label = "High school completion",size=3)+
      labs(x="Year",y="Average Income")+
      theme_minimal()+
      theme(axis.text.x = element_text(angle=45,size=6))
  
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)
