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

# create mapping for unique id to color, depends on sex
library(RColorBrewer)
library(scales)
library(plotly)
MAPPING <- newdf%>% distinct(education,sex)
RS_COLS =  brewer.pal(9,"Set1")
RS_COLS = RS_COLS[1:n_distinct(MAPPING$sex)]
names(RS_COLS) = unique(MAPPING$sex)
PLOT_COLS = RS_COLS[MAPPING$sex]
names(PLOT_COLS) = MAPPING$uniq_id

newdf$idtf<-paste(newdf$sex,newdf$education)

#lines 
ggplot(newdf[which(newdf$money_measure=="Current Dollars"),])+
  geom_line(stat="smooth",aes(year,avg_income,color=as.factor(idtf)),se=FALSE,span=0.3,alpha=0.7,size=0.8)+
  theme_minimal()+
  labs(y="average income")+
  theme(legend.position="none")+
  scale_color_manual(values =PLOT_COLS)+
  ylim(0,140000)+scale_x_continuous(breaks=seq(1990, 2020, 2))+
  scale_y_continuous(labels =scales::comma)+
  geom_smooth(data=newdf,aes(year,avg_income,shape=sex),size=0,span=1)+
  theme(axis.text.x = element_text(angle=45,size=6))

table(newdf$education)

newdf$money_measure<-ifelse(newdf$money_measure=="Current Dollar","Current Dollars",newdf$money_measure)

df_gap<-newdf[which((newdf$education%in%c("Bachelor's degree","High school completion (includes equivalency)")&(newdf$money_measure=="Current Dollars"))),]
df_gap<-df_gap[,-7]
df_gap$year<-ifelse(df_gap$sex=="Male",df_gap$year-0.15,df_gap$year+0.15)
male<-df_gap%>%spread(education,avg_income)%>%filter(sex=="Male")
female<-df_gap%>%spread(education,avg_income)%>%filter(sex=="Female")

#gaps
gaps<-df_gap%>%ggplot()+
  geom_smooth(aes(year,avg_income,color=sex),size=0,span=1)+
  scale_color_manual(values=c("darkred","steelblue"))+
  geom_segment(data=male,aes(x=year,xend=year,y=`High school completion (includes equivalency)`,yend=`Bachelor's degree`),colour = "steelblue",size=1.5)+
  geom_segment(data=female,aes(x=year,xend=year,y=`High school completion (includes equivalency)`,yend=`Bachelor's degree`),colour = "darkred",size=1.5)+
  geom_point(aes(year,avg_income,color=sex),size=1.5,alpha=1,shape=21,fill="white")+
  ylim(0,80000)+scale_x_continuous(breaks=seq(1990, 2020, 2))+
  annotate("text", x = 2000,y = 60000, label = "Bachelor's degree",size=3)+
  annotate("text", x = 2002,y = 22000, label = "High school completion",size=3)+
  labs(x="Year",y="Average Income")+
  theme_minimal()+
  theme(axis.text.x = element_text(angle=45,size=6))

write_csv(newdf,"/Users/lingyunfan/all_repos/data_viz_cmpt/BeautifulBars/data/new_long_inc_data.csv")

ggplotly(gaps)


