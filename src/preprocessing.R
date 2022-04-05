#data cleaning
rm(list=ls())
library(tidyverse)
library(ggplot2)
df<-read.csv("/Users/lingyunfan/all_repos/data_viz_cmpt/BeautifulBars/data/inc_data_cleaned.csv",check.names=FALSE)

newdf<-df%>%gather(education,income,-c(` Year`,Sex,Measure))
colnames(newdf)[1]<-"Year"
ggplot(newdf[which((newdf$Measure=="Current Dollar")&(newdf$Sex=="Male")),])+
  geom_line(aes(Year,income,color=as.factor(education)))+theme_minimal()+labs(color="")
table(newdf$education)

newdf$education<-str_trim(newdf$education)
colnames(newdf)[1:3]<-c("year","sex","money_measure")
colnames(newdf)[5]<-"avg_income"
write_csv(newdf,"/Users/lingyunfan/all_repos/data_viz_cmpt/BeautifulBars/data/new_long_inc_data.csv")
