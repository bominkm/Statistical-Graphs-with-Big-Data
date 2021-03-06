library(ggplot2)
library(tidyverse)
library(modelr)
library(GGally)

setwd("C:/Users/bomin/Desktop/이화여대/빅데이터를이용한통계그래픽스/팀프로젝트" )
data<- read.csv("final_data.csv",header=TRUE) 

#당뇨병인자 생성
data_db<-data%>%filter(!is.na(BLDS),SIGHT_RIGHT!=9.9)%>%mutate(group_db=ifelse(BLDS>=126, 'diabetes', ifelse(BLDS>=100, 'before_db', 'normal')))
data_db$group_db<-factor(data_db$group, levels=c('normal', 'before_db', 'diabetes'))

#나이와 당뇨병의 연관성
data_db%>%ggplot(aes(as.factor(AGE_GROUP), BLDS))+geom_boxplot()+labs(x='AGE_GROUP')
data_db%>%ggplot(aes(as.factor(AGE_GROUP),fill=group_db))+geom_bar(position='dodge')+labs(x='AGE_GROUP')

#시력과 당뇨병의 연관성
ggplot(data_db, aes(group_db, SIGHT_RIGHT))+geom_boxplot()

#시력과 나이의 연관성
data_sight_right<-data%>%filter(SIGHT_RIGHT!=9.9)
mod_SIGHT_RIGHT<-lm(SIGHT_RIGHT~as.factor(AGE_GROUP), data=data_sight_right)
grid<-data_sight_right%>%data_grid(AGE_GROUP)%>%add_predictions(mod_SIGHT_RIGHT)
ggplot(data=data_sight_right, aes(AGE_GROUP))+geom_point(aes(y=SIGHT_RIGHT))+geom_point(data=grid, aes(y=pred),color='red', size=3)
#AGE_GROUP이 4인 35~49세까지는 시력이 증가하다가 이후로는 시력 감소

#시력과 당뇨병의 연관성이 나이 때문이 아닌지
#시력과 나이, 공복혈당의 연관성
mod1<-lm(SIGHT_RIGHT~as.factor(AGE_GROUP)+BLDS, data=data_sight_right)
mod2<-lm(SIGHT_RIGHT~as.factor(AGE_GROUP)*BLDS, data=data_sight_right)
grid_2<-data_sight_right%>%data_grid(AGE_GROUP, BLDS)%>%gather_predictions(mod1, mod2)
ggplot(data=data_sight_right, aes(BLDS, SIGHT_RIGHT, color=factor(AGE_GROUP)))+geom_point()+geom_line(data=grid_2,aes(y=pred))+facet_wrap(~model)+labs(color='AGE_GROUP')
#mod2에서 직선이 평행하지 않고 교차점이 있는 것으로 보아 나이와 공복혈당 사이에는 상호작용이 있다고 볼 수 있다
data_sight_right%>%gather_residuals(mod1, mod2)%>%ggplot(aes(BLDS, resid, color=factor(AGE_GROUP)))+geom_point()+facet_grid(model~AGE_GROUP)+labs(color='AGE_GROUP')
#시력에 대한 나이와 공복혈당에 대한 효과를 제거해도 잔차가 random하게 분포하지 않음

#대사증후군 상관성
data%>%filter(WAIST<150)%>%filter(TRIGLYCERIDE<1200)%>%filter(HDL_CHOLE<200)%>%
select(WAIST,BLDS,BP_HIGH,TRIGLYCERIDE,HDL_CHOLE)%>%ggpairs()

