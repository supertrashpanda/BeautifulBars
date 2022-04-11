function(input, output, session) {

df_gap = reactive({
  if ((input$male)&(!input$female)) {newdf<-newdf[newdf$sex=='Male',]}
  if ((!input$male)&(input$female)) {newdf<-newdf[newdf$sex=='Female',]}
  if((!input$male)&(!input$female)) {newdf<-newdf[newdf$sex=='',]}
  
  a <- newdf[which((newdf$education%in%c(input$education1,input$education2))&(newdf$money_measure=="Constant 2019 Dollars")),]%>%
    select(-idtf)
  
  a$year <- ifelse(a$sex=="Male",a$year-0.1,a$year+0.1)
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
  inc1<-mean(newdf[which((newdf$education==input$education1)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Male")),"avg_income"],na.rm = TRUE)
  inc2<-mean(newdf[which((newdf$education==input$education2)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Male")),"avg_income"],na.rm=TRUE)
  return(inc2-inc1)
})


gap2 <- reactive({
  inc1<-mean(newdf[which((newdf$education==input$education1)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Female")),"avg_income"],na.rm = TRUE)
  inc2<-mean(newdf[which((newdf$education==input$education2)&(newdf$money_measure=="Constant 2019 Dollars")&(newdf$sex=="Female")),"avg_income"],na.rm=TRUE)
  return(inc2-inc1)
})


output$txtout <- renderUI({
  str1 <- paste("The income gap between workers with education levels of '",input$education1,"' and  '",input$education2,"':",sep="")
  str2 <- paste("Male: $", abs(round(gap1(),2)),sep="")
  str3 <- paste("Female: $", abs(round(gap2(),2)),sep="")
  HTML(paste(str1, str2,str3, sep = '<br/>'))
})

output$male <- renderValueBox({
  valueBox(
    value = scales::dollar(abs(round(gap1(),0))),
    subtitle = "Income Gap for Male",
    icon = icon("male"),
    width = 4,
    color = "light-blue",
    href = NULL
  )
})

output$female <- renderValueBox({
  valueBox(
    value = scales::dollar(abs(round(gap2(),0))),
    subtitle = "Income Gap for Female",
    icon = icon("female"),
    width = 4,
    color = "maroon",
    href = NULL
  )
})

output$box3 <- renderValueBox({
  valueBox(
    value = scales::dollar(abs(round(gap1(),0)) - (abs(round(gap2(),0)))),
    subtitle = "Gender Gap",
    icon = icon("venus-mars"),
    width = 4,
    color = "purple",
    href = NULL
  )
})


output$plot <- renderPlot({
  df_gap()$a %>%
    ggplot()+
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
    # scale_y_continuous(breaks=seq(0, 200000, 50000),minor_breaks=seq(0, 200000, 50000))+
    ylim(0,200000)+
    geom_hline(yintercept=0,alpha=0.5,size=1)+
    labs(x="Year",y="Median Annual Income (in fixed 2019 dollars)",shape="Education Levels",
         fill="Education Levels",color="Gender")+
    theme_minimal()+
    theme(legend.position = c(0.6, 0.95),legend.justification=c(0.5, 1),
          legend.box = "horizontal",axis.text.x = element_text(size=8,angle=45),
          panel.grid.minor.y = element_blank(),panel.grid.major.x = element_blank())
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
    scale_fill_brewer(palette = "Set1") +
    theme_minimal()+
    theme(legend.position = "bottom",
          legend.text = element_text(size=8)) +
    scale_fill_manual(values=c('lightcoral','steelblue'),
                      name = "Education")+
    labs(x="Year",y="Median Annual Income")
)




}