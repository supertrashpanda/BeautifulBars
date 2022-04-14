
server<-function(input, output, session) {
  
  observeEvent(input$yearend,{
    if(input$yearend[1]>=2020){
      updateSliderInput(session, "yearend", value=c(2019,2020))
    }
    else if(input$yearend[1] == input$yearend[2]){
      updateSliderInput(session, "yearend", value=c(input$yearend[1],(input$yearend[1]+1)))
    }
  })
  
  df_gap = reactive({
    if ((input$male)&(!input$female)) {newdf<-df[df$sex=='Male',]}
    if ((!input$male)&(input$female)) {newdf<-df[df$sex=='Female',]}
    if((!input$male)&(!input$female)) {newdf<-df[df$sex=='',]}
    
    a <- newdf[which((newdf$education%in%c(input$education1,input$education2))&(newdf$money_measure=="Constant 2019 Dollars")),]%>%
      select(-idtf)
    a <- a[which((a$year>=input$yearend[1])&(a$year<=input$yearend[2])),]
    
    male <- a %>%
      spread(education,avg_income)%>%filter(sex=="Male")
    
    names(male) <- make.names(names(male),unique = TRUE)
    
    female <- a %>%
      spread(education,avg_income)%>%filter(sex=="Female")
    
    names(female) <- make.names(names(female),unique = TRUE)
    
    return(list(a=a,male=male,female=female))
  })
  
  
  gap1 <- reactive({
    inc1<-mean(df[which((df$money_measure=="Constant 2019 Dollars")&(df$education==input$education1)&(df$sex=="Male")&(df$year>=input$yearend[1])&(df$year<=input$yearend[2])),"avg_income"],na.rm = TRUE)
    inc2<-mean(df[which((df$money_measure=="Constant 2019 Dollars")&(df$education==input$education2)&(df$sex=="Male")&(df$year>=input$yearend[1])&(df$year<=input$yearend[2])),"avg_income"],na.rm = TRUE)
    return(inc2-inc1)
  })
  
  
  gap2 <- reactive({
    inc1<-mean(df[which((df$money_measure=="Constant 2019 Dollars")&(df$education==input$education1)&(df$sex=="Female")&(df$year>=input$yearend[1])&(df$year<=input$yearend[2])),"avg_income"],na.rm = TRUE)
    inc2<-mean(df[which((df$money_measure=="Constant 2019 Dollars")&(df$education==input$education2)&(df$sex=="Female")&(df$year>=input$yearend[1])&(df$year<=input$yearend[2])),"avg_income"],na.rm = TRUE)
    return(inc2-inc1)
  })
  
  sex_gap<- reactive({
    if(input$education1==input$education2){
      inc1<-mean(newdf[which((newdf$education==input$education1)&(newdf$sex=="Female")),"avg_income"],na.rm = TRUE)
      inc2<-mean(newdf[which((newdf$education==input$education1)&(newdf$sex=="Male")),"avg_income"],na.rm=TRUE)
      return(inc2-inc1)}
    else{return(0)}
  })
  
  payoff <- reactive({
    sumfee<-as.numeric(input$sumfee)
    year <- as.numeric(input$year)
    sex <- input$sex
    inc1<-mean(df[which((df$money_measure=="Constant 2019 Dollars")&(df$education==input$education1)&(df$sex=="Male")&(df$year>=input$yearend[1])&(df$year<=input$yearend[2])),"avg_income"],na.rm = TRUE)
    inc2<-mean(df[which((df$money_measure=="Constant 2019 Dollars")&(df$education==input$education1)&(df$sex=="Female")&(df$year>=input$yearend[1])&(df$year<=input$yearend[2])),"avg_income"],na.rm = TRUE)
    if(sex=="Male"){return((inc1*year + sumfee)/gap1())}
    else{return((inc2*year + sumfee)/gap2())}
    inc1<-mean(df_gap()$a[which((df_gap()$a$education==input$education1)&(df_gap()$a$sex==input$sex)),"avg_income"],na.rm = TRUE)
    inc2<-mean(df_gap()$a[which((df_gap()$a$education==input$education2)&(df_gap()$a$sex==input$sex)),"avg_income"],na.rm = TRUE)
    return((inc1*year + sumfee)/(inc2-inc1))

  })
  

  output$male <- renderValueBox({
    valueBox(
      value = scales::dollar(abs(round(gap1(),0))),
      subtitle = tags$p("Annual Income Gap for Men (multi-year average)",style="font-size:110%;"),
      icon = icon("male"),
      width = 4,
      color = "aqua",
      href = NULL
    )
  })
  
  output$female <- renderValueBox({
    valueBox(
      value = scales::dollar(abs(round(gap2(),0))),
      subtitle = tags$p("Annual Income Gap for Women (multi-year average)",style="font-size:108%;"),
      icon = icon("female"),
      width = 4,
      color = "maroon",
      href = NULL
    )
  })
  
  output$box3 <- renderValueBox({
    valueBox(
      value = if(input$education1==input$education2){"NA"}else{abs(round(payoff(),1))},
      subtitle = tags$p("Expected Payback Period (Years)",style="font-size:120%;"),
      icon = icon("user-graduate"),
      width = 4,
      color = "light-blue",
      href = NULL
    )
  })
  
  
  output$plot <- renderPlotly({
    if(input$education1==input$education2){
      ggplotly(df_gap()$a%>%
        ggplot()+
        geom_line(aes(year,avg_income,color=sex),size=1.5,alpha=0.8)+
        scale_color_manual(labels=c("Female","Male"),values=c("hotpink2","steelblue3"))+
        scale_x_continuous(breaks=seq(1989, 2021, 1),minor_breaks=seq(1989, 2021, 1))+
        ylim(0,170000)+
        geom_hline(yintercept=0,alpha=0.5,size=1)+
        labs(x="Year",y="Median Annual Income (in fixed 2019 dollars)",color="Gender",
             title="")+
        theme_minimal()+
        theme(legend.position = c(0.6, 0.95),legend.justification=c(0.5, 1),
              legend.box = "horizontal",axis.text.x = element_text(size=8,angle=45),
              panel.grid.minor.y = element_blank(),panel.grid.major.x = element_blank())
      )%>%layout(legend = list(orientation = "h",y=4))%>% config(displayModeBar = F)
    }
    else if((input$male)&(input$female)){
      ggplotly(df_gap()$a%>%
                 ggplot()+
                 geom_line(aes(year,avg_income,color=sex,size=education),alpha=0.8)+
                 scale_color_manual(values=c("Female"="hotpink2","Male"="steelblue3"))+
                 scale_size_manual(values=c(1,2))+
                 geom_ribbon(data=df_gap()$male,aes_string(x="year",ymin =colnames(df_gap()$male)[5], ymax = colnames(df_gap()$male)[6]), fill = "steelblue3", alpha = .2)+
                 geom_ribbon(data=df_gap()$female,aes_string(x="year",ymin =colnames(df_gap()$female)[5], ymax = colnames(df_gap()$male)[6]), fill = "hotpink2", alpha = .2)+
                 scale_x_continuous(breaks=seq(1989, 2021, 1),minor_breaks=seq(1989, 2021, 1))+
                 ylim(0,170000)+
                 geom_hline(yintercept=0,alpha=0.5,size=1)+
                 labs(x="Year",y="Median Annual Income (in fixed 2019 dollars)",shape="Education Levels",
                      size="Education Levels",color="Gender",title="")+
                 theme_minimal()+
                 theme(legend.position = c(0.6, 0.95),legend.justification=c(0.5, 1),
                       legend.box = "horizontal",axis.text.x = element_text(size=6,angle=45),
                       panel.grid.minor.y = element_blank(),panel.grid.major.x = element_blank(),
                       text = element_text(size = 10))
      )%>%layout(legend = list(orientation = "h",y=4))%>% config(displayModeBar = F)}
    
  else if ((!input$male)&(!input$female)){
    ggplotly(ggplot() +
               theme_minimal()+
               ylim(0,170000)+
               geom_hline(yintercept=0,alpha=0.5,size=1)
               
    )
  }
  else if ((input$male)&(!input$female)){ggplotly(df_gap()$a%>%
                        ggplot()+
                        geom_line(aes(year,avg_income,color=sex,size=education),alpha=0.8)+
                        scale_color_manual(values=c("Female"="hotpink2","Male"="steelblue3"))+
                        scale_size_manual(values=c(1,2))+
                        geom_ribbon(data=df_gap()$male,aes_string(x="year",ymin =colnames(df_gap()$male)[5], ymax = colnames(df_gap()$male)[6]), fill = "steelblue3", alpha = .2)+
                        scale_x_continuous(breaks=seq(1989, 2021, 1),minor_breaks=seq(1989, 2021, 1))+
                        ylim(0,170000)+
                        geom_hline(yintercept=0,alpha=0.5,size=1)+
                        labs(x="Year",y="Median Annual Income (in fixed 2019 dollars)",shape="Education Levels",
                             size="Education Levels",color="Gender",title="")+
                        theme_minimal()+
                        theme(legend.position = c(0.6, 0.95),legend.justification=c(0.5, 1),
                              legend.box = "horizontal",axis.text.x = element_text(size=6,angle=45),
                              panel.grid.minor.y = element_blank(),panel.grid.major.x = element_blank(),
                              text = element_text(size = 10))
  )%>%layout(legend = list(orientation = "h",y=4))%>% config(displayModeBar = F)} 
    
else{ggplotly(df_gap()$a%>%
                       ggplot()+
                       geom_line(aes(year,avg_income,color=sex,size=education),alpha=0.8)+
                       scale_color_manual(values=c("Female"="hotpink2","Male"="steelblue3"))+
                       scale_size_manual(values=c(1,2))+
                       geom_ribbon(data=df_gap()$female,aes_string(x="year",ymin =colnames(df_gap()$female)[5], ymax = colnames(df_gap()$male)[6]), fill = "hotpink2", alpha = .2)+
                       scale_x_continuous(breaks=seq(1989, 2021, 1),minor_breaks=seq(1989, 2021, 1))+
                       ylim(0,170000)+
                       geom_hline(yintercept=0,alpha=0.5,size=1)+
                       labs(x="Year",y="Median Annual Income (in fixed 2019 dollars)",shape="Education Levels",
                            size="Education Levels",color="Gender",title="")+
                       theme_minimal()+
                       theme(legend.position = c(0.6, 0.95),legend.justification=c(0.5, 1),
                             legend.box = "horizontal",axis.text.x = element_text(size=6,angle=45),
                             panel.grid.minor.y = element_blank(),panel.grid.major.x = element_blank(),
                             text = element_text(size = 10))
)%>%layout(legend = list(orientation = "h",y=4))%>% config(displayModeBar = F)}

  })
  
  output$gender = renderPlot(
    df_gap()$a %>%
      ggplot(aes(x = year, y = avg_income, fill = sex)) + 
      geom_bar(stat="identity", position = "dodge") + 
      theme_minimal() +
      scale_x_continuous(breaks=seq(1989, 2021, 5))+
      theme(legend.position = "bottom") +
      labs(x="Year",y="Median Annual Income") +
      scale_fill_manual(values=c('tomato3','steelblue4'),
                        name = "Gender")
  )
  
  # output$genderly = renderPlotly(
  #   df_gap()$a %>%
  #     select(year, sex, avg_income) %>%
  #     spread(sex, avg_income) %>%
  #     plot_ly(x = ~year, y = ~avg_income, type = 'bar')
  # )
  
  output$education = renderPlot(
    df_gap()$a %>%
      ggplot(aes(x = year, y = avg_income, fill = education)) + 
      geom_bar(stat="identity", position = "dodge") + 
      theme_minimal()+
      theme(legend.position = "bottom",
            legend.text = element_text(size=8)) +
      scale_fill_manual(values=c('lightcoral','steelblue'),
                        name = "Education")+
      labs(x="Year",y="Median Annual Income")
  )
  
}