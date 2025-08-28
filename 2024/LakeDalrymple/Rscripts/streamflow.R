
library(dygraphs)
library(xts)
library(dplyr)
library(ggplot2)
library(lubridate)
library(readxl)


df.Black <- read.csv('dat/02EC002.csv')
df.Head <- read.csv('dat/02EC022.csv')


 
# df <- df.Head %>%
#   mutate(Date=as.Date(Date))
# 
# # check
# dygraph(xts(df$Flow, order.by = df$Date))

montho <- function (x) (month(x)+2) %% 12



################################################ 1510 km2
df.Black.bp <- df.Black %>% 
  mutate(Date=as.Date(Date), 
         mnt=factor(format(Date, "%b")),
         Period=case_when(Date>'2013-9-30' ~ '2013-2023', TRUE ~ '1983-2013')) %>% 
  filter(Date<'2023-10-1', Date>'1983-9-30')

ggplot(df.Black.bp) +
  theme_bw() +
  theme(legend.position = c(.9,.9)) +
  geom_boxplot(aes(x = reorder(mnt, montho(Date)), y = BF.med, fill=Period), outlier.shape = NA) + #, position = position_dodge(width = .9))
  scale_fill_manual(values=c("#0060ee","#7ba900")) +
  labs(title="02EC002: BLACK RIVER NEAR WASHAGO",x=NULL,y="baseflow discharge (m³/s)")




################################################ 235.3 km2
df.Head.bp <- df.Head %>% 
  mutate(Date=as.Date(Date), 
         mnt=factor(format(Date, "%b")),
         Period=case_when(Date>'2018-9-30' ~ '2018-2023', TRUE ~ '2014-2018')) %>% 
  filter(Date<'2023-10-1', Date>'1983-9-30')

ggplot(df.Head.bp) +
  theme_bw() +
  theme(legend.position = c(.9,.9)) +
  geom_boxplot(aes(x = reorder(mnt, montho(Date)), y = BF.med, fill=Period), outlier.shape = NA) + #, position = position_dodge(width = .9))
  scale_fill_manual(values=c("#0060ee","#7ba900")) +
  labs(title="02EC022: HEAD RIVER NEAR SEBRIGHT",x=NULL,y="baseflow discharge (m³/s)")




################################################
df.trib.east <- read_xlsx("dat/LDMP_TribEast_adjusted.xlsx",sheet='Sheet1') %>%
  select(!c(Date,Time)) %>%
  mutate(DateTime=as.Date(DateTime)) %>%
  group_by(DateTime) %>%
  summarise(dayflow=mean(new)) %>%
  ungroup() %>%
  mutate(meanflow=rollapply(dayflow,7,mean,fill=NA),
         yd = as.Date(format(DateTime, "2001-%m-%d")),
         year = factor(year(DateTime)))


ggplot(df.trib.east) +
  theme_bw() +
  theme(legend.position = c(.9,.85)) +
  geom_line(aes(x=yd,y=meanflow,group=year,color=year), linewidth=1) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_color_manual(values=c("#a5b500","#014ebe","#d10012")) +
  labs(title="East Tributary",x=NULL,y="mean daily discharge (m³/s)")



################################################
df.trib.west <- read_xlsx("dat/LDMP_TribWest_adjusted.xlsx",sheet='Sheet1') %>%
  select(!c(Date,Time)) %>%
  mutate(DateTime=as.Date(DateTime)) %>%
  group_by(DateTime) %>%
  summarise(dayflow=mean(`Est.Discharge_m3/s`)) %>%
  ungroup() %>%
  mutate(meanflow=rollapply(dayflow,7,mean,fill=NA),
         yd = as.Date(format(DateTime, "2001-%m-%d")),
         year = factor(year(DateTime)))


ggplot(df.trib.west) +
  theme_bw() +
  theme(legend.position = c(.9,.85)) +
  geom_line(aes(x=yd,y=meanflow,group=year,color=year), linewidth=1) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_color_manual(values=c("#a5b500","#014ebe","#d10012")) +
  labs(title="West Tributary",x=NULL,y="mean daily discharge (m³/s)")








