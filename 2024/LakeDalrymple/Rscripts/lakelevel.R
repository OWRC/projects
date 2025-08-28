
library(dplyr)
library(ggplot2)
library(lubridate)
library(readxl)
library(zoo)


df.lakelogger <- read_xlsx("dat/LDMP_LakeLevelLogger_All.xlsx",sheet='WorkedData') %>%
  select(!c(No.,date,time,`level-day`,`elevation-day`)) %>%
  mutate(dt=as.Date(dt)) %>%
  group_by(dt) %>%
  summarise(dayflow=mean(`elevation-hr`)) %>%
  ungroup() %>%
  mutate(meanlev=rollapply(dayflow,7,mean,fill=NA),
         yd = as.Date(format(dt, "2001-%m-%d")),
         year = factor(year(dt)))





#########################################
df.lakestaff <- read_xlsx("dat/LDMP_LakeLeverManual_All_adjusted.xlsx",sheet='Lake',skip=1) %>%
  select(!c(`Lake Level Sensor`)) %>%
  mutate(Date=as.Date(Date)) %>%
  mutate(yd = as.Date(format(Date, "2001-%m-%d")),
         year = factor(year(Date)))


ggplot(df.lakestaff) +
  theme_bw() +
  theme(legend.position = c(.9,.85)) +
  geom_line(data=df.lakelogger, aes(x=yd,y=meanlev,color=year), linewidth=1.25) + 
  geom_point(aes(x=yd,y=Elevation_masl,group=year,color=year), size=3) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_color_manual(breaks = c(2021,2022,2023),values=c("#a5b500","#014ebe","#d10012")) +
  labs(title="Lake Dalrymple",x=NULL,y="lake level elevation (masl)")
