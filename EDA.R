library(ggplot2)
library(tidyverse)
library(GGally)
library(ggmosaic)

setwd("C:/Users/bomin/Desktop/이화여대/빅데이터를이용한통계그래픽스/팀프로젝트" )
data<- read.csv("NHIS_TOTAL.csv",header=TRUE) 
str(data)

#EDA
ggplot(data=data, aes(SEX))+geom_bar() 
#성별: 남자>여자
ggplot(data=data, aes(AGE_GROUP))+geom_bar() 
#연령: 대체로 정규분포를 따르고 group9인 60~64세가 가장 많음
ggplot(data=data, aes(HEIGHT))+geom_bar()
#신장: 정수이지만 5단위로 되어있으므로 바차트 그림
data%>%filter(HEIGHT<125)%>%ggplot(aes(HEIGHT))+geom_bar()
#바차트에 보이지 않는 값을 알아보기 위해 범위를 125이하로 설정하여 그린 결과 85, 105, 115, 120 등의 값이 있었음
#AGE_GROUP과 비교해봐도 원인이 나이가 어려서임은 아닌 것으로 판단되어 outlier라 생각됨
#다만 어느 값부터 이상치로 보아야할지 어려움
ggplot(data=data, aes(SIDO))+geom_bar()
data%>%group_by(SIDO)%>%summarise(count=n())%>%arrange(desc(count))
#시도코드: 경기도>서울특별시>부산광역시>경상남도>인천광역시>경상북도>대구광역시>충청남도>...순으로 많음
#41>11>26>48>28>47>27>44>46>45>43>42>30>29>31>49>36>50
ggplot(data=data, aes(WEIGHT))+geom_bar()
#체중: 대체로 정규분포를 따름
ggplot(data=data, aes(WAIST))+geom_histogram()
data%>%filter(WAIST>150)%>%group_by(WAIST)%>%summarise(count=n())
#허리둘레: WAIST=999인 outlier 7개(X.1= 2089, 21352,  21853, 25817, 30322, 31240, 34192)
ggplot(data=data, aes(SIGHT_LEFT))+geom_freqpoly()
data%>%filter(SIGHT_LEFT>2.5)%>%nrow()
#시력: SIGHT_LEFT가 9.9로 실명한 사람인 outlier 322명 존재
ggplot(data=data, aes(SIGHT_RIGHT))+geom_freqpoly()
data%>%filter(SIGHT_RIGHT>2.5)%>%nrow()
#시력: SIGHT_RIGHT가 9.9로 실명한 사람인 outlier 336명 존재
ggplot(data=data, aes(HEAR_LEFT))+geom_bar()
data%>%group_by(HEAR_LEFT)%>%summarise(count=n())
#청력: 정상 96988, 비정상 2996, 결측값 16
data%>%group_by(HEAR_RIGHT)%>%summarise(count=n())
#청력: 정상 97127, 비정상 2857, 결측값 16
#당뇨병은 소변으로 포도당이 배출되는 질환이며 혈당으로 진단할 수 있는데 공복혈당 126 이상인 경우 당뇨병으로 진단한다.
#출처: 국립보건연구원 CDC
#http://www.nih.go.kr/CDC/cms/content/19/18019_view.html
data%>%filter(BLDS>126)%>%summarise(count=n())
#당뇨병 6934
data%>%filter(100<BLDS, BLDS<125)%>%summarise(count=n())
#당뇨병 전단계 24979
ggplot(data=data, aes(TOT_CHOLE))+geom_freqpoly()
data%>%arrange(TOT_CHOLE)%>%tail()
#총 콜레스테롤: 결측값 4, outlier 1758
#트리글리세라이드는 중성지방으로, 심질환으로 진행될 위험을 평가하기 위해 검사한다.
#출처: 대한진단검사의학회
#https://labtestsonline.kr/tests/tg 
ggplot(data=data, aes(TRIGLYCERIDE))+geom_freqpoly()
#트리글리세라이드: 결측값 4
data%>%filter(TRIGLYCERIDE>1000)%>%nrow()
#트리글리세라이드: 1000넘는 값 47명
data_fat<-data%>%select(TOT_CHOLE, TRIGLYCERIDE, HDL_CHOLE, LDL_CHOLE)
ggpairs(data_fat)
#총 콜레스테롤은 LDL과 가장 연관성 높음
ggplot(data=data, aes(HDL_CHOLE))+geom_freqpoly()
data%>%arrange(HDL_CHOLE)%>%tail()
#HDL콜레스테롤: 결측값 4개
data_liver<-data%>%select(SGOT_AST, SGPT_ALT, GAMMA_GTP)
ggpairs(data_liver)

#가설1: 당뇨병은 당뇨망막병증(눈), 신부전(콩팥), 신경병증 등의 합병증을 유발한다. 그러므로 식전혈당이 높은 사람은 시력이 좋지 않을 것이다.
data%>%filter(SIGHT_LEFT<2.5)%>%ggplot(aes(BLDS, SIGHT_LEFT))+geom_point()+geom_smooth()
data%>%filter(SIGHT_RIGHT<2.5)%>%ggplot(aes(BLDS, SIGHT_RIGHT))+geom_point()+geom_smooth()
data%>%filter(BLDS>126)%>%filter(SIGHT_LEFT<2.5)%>%ggplot(aes(BLDS, SIGHT_LEFT))+geom_point()+geom_smooth()
data%>%filter(100<BLDS, BLDS<125)%>%filter(SIGHT_LEFT<2.5)%>%ggplot(aes(BLDS, SIGHT_LEFT))+geom_point()+geom_smooth()

#가설2: 내장지방이 많을수록 고혈압 발병률이 높을 것이다.
data_fat<-data%>%select(WAIST, TRIGLYCERIDE, BP_HIGH, BP_LWST)%>%filter(WAIST!=999)%>%filter( TRIGLYCERIDE<1000)
ggpairs(data_fat)
data%>%filter(WAIST!=999)%>%ggplot(aes(WAIST, BP_HIGH))+geom_point()+geom_smooth()
data%>%filter( TRIGLYCERIDE<750)%>%ggplot(aes(TRIGLYCERIDE, BP_HIGH))+geom_point()+geom_smooth()

#가설3: 여자보다 남자가 비만도가 높을 것이다.
#BMI=몸무게(kg)/신장(m)^2
#출처: 대한비만학회
#http://general.kosso.or.kr/html/?pmode=obesityDiagnosis
#과체중: BMI>=23, 비만: BMI>=25, 고도비만:BMI>=30
data_obesity<-data%>%mutate(BMI=WEIGHT/(HEIGHT/100)^2)%>%group_by(SEX, AGE_GROUP)%>%mutate(obesity=ifelse(BMI>=30, 'high_obesity', ifelse(BMI>=25, 'obesity', ifelse(BMI>=23, 'overweight', 'normal'))))%>%select(BMI, obesity, everything())
data_obesity%>%ggplot(aes(obesity, fill=factor(SEX)))+geom_bar()+scale_x_discrete(limits=c('normal','overweight','obesity','high_obesity'))+facet_wrap(~SEX)

#가설4: 나이가 들수록 비만도가 높아질 것이다.
data_BMI<-data%>%mutate(BMI=WEIGHT/(HEIGHT/100)^2)%>%group_by(SEX, AGE_GROUP)%>%summarise(high_obesity=sum(BMI>=30), obesity=sum(BMI<30 & BMI>=25), overweight=sum(BMI<25 & BMI>=23), normal=sum(BMI<23))
data_BMI%>%gather('normal','overweight','obesity','high_obesity', key='obesity', value='Freq')%>%ggplot()+geom_mosaic(aes(x=product(AGE_GROUP), weight=Freq,fill=obesity))

#가설5: 당뇨병환자는 시간이 지날수록 시력이 나빠질 것이다.
data%>%filter(BLDS>=126)%>%filter(SIGHT_LEFT<2.5)%>%ggplot(aes(factor(HCHK_YEAR), SIGHT_LEFT))+geom_boxplot()
data%>%filter(BLDS>=126)%>%filter(SIGHT_RIGHT<2.5)%>%ggplot(aes(factor(HCHK_YEAR), SIGHT_RIGHT))+geom_boxplot()
#당뇨병으로 진단할 수 있는 수치인 식전혈당 126이상으로 filter하고 실명이 아닌 사람의 시력으로 범위를 설정한 후 년도별로 boxplot을 그렸으나 설정한 가설대로 년도에 따라 시력이 감소하지는 않음

#가설6: 실명의 원인은 당뇨병일 것이다.
data%>%filter(SIGHT_LEFT==9.9)%>%ggplot(aes(BLDS))+geom_density()
#실명과 당뇨병은 무관

#가설7: 서울에서 멀어질수록 술을 덜 마실 것이다.
data%>%filter(!is.na(DRK_YN))%>%ggplot(aes(factor(DRK_YN), color=factor(SIDO)))+geom_density()

