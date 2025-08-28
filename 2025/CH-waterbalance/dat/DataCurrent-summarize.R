
library(dplyr)
library(lubridate)
library(stringr)
library(ggplot2)



# var = 'Air Temperature [°C]'
# var = 'Precipitation [mm]'
# var = 'Barometric Pressure [kPa]'
# var = 'Relative Humidity [%]'
var = 'Snow Depth [cm]'
# var = 'Wind Speed [Metres per Second]'
idir = 'climate/DataCurrent/weather/'
# var = 'Snow Water Equivalent [mm]'
# idir = 'climate/DataCurrent/snow/'
# var = 'Snow Water Equivalent [mm]'
# idir = 'climate/DataCurrent/rain-gauges/'



df <- read.csv(paste0(idir,'merged_',var,'.csv')) %>%
  rename('value' = 3) %>%
  mutate(Date = ymd(str_split(Date, pattern=" ", simplify=T)[,1])) %>%
  group_by(Date, station) %>%
  summarise(value=sum(value)) %>%
  mutate(station=factor(station))


# Gantt
nsta <- nlevels(df$station)
df %>% ggplot(aes(Date,station)) +
  theme_minimal() +
  geom_point(shape=3) +
  scale_y_discrete(position = "right") +
  labs(x=NULL,y=NULL,title=var) +
  xlim(c(ymd('2005-10-01'),NA))

ggsave(paste0(idir,var,'.png'),height=nsta*.25+.5)





# Summaries
df %>%
  filter(value>=0.1) %>%
  mutate(Month=factor(month(Date), levels=seq(1,12))) %>%
  group_by(Month,station) %>%
  summarize(Count=n()) %>%
  ggplot(aes(Month,Count)) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    geom_bar(stat = 'identity', width=.5, position = "dodge") +
    guides(fill="none") +
    scale_x_discrete(
      breaks = seq_along(month.abb), 
      labels = month.abb
    ) +
    labs(x=NULL,title=paste0('Number of days with reported ',var)) +
    facet_wrap(~station, ncol = 6, scales='free')

ggsave(paste0(idir,var,'-counts.png'), height=10)


df %>%
  mutate(Month=factor(month(Date), levels=seq(1,12))) %>%
  group_by(Month,station) %>%
  summarize(mean=mean(value)*30.24) %>%
  ggplot(aes(Month,mean)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  geom_bar(stat = 'identity', width=.5, position = "dodge") +
  guides(fill="none") +
  scale_x_discrete(
    breaks = seq_along(month.abb), 
    labels = month.abb
  ) +
  labs(x=NULL,y=var,title=paste0('Average Monthly ',var)) +
  facet_wrap(~station, ncol = 6, scales='free')

ggsave(paste0(idir,var,'-monthly.png'), height=10)


df %>%
  mutate(Year=factor(year(Date))) %>%
  group_by(Year,station) %>%
  summarize(mean=mean(value)*365.24) %>%
  ggplot(aes(Year,mean)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  geom_bar(stat = 'identity', width=.5, position = "dodge") +
  guides(fill="none") +
  labs(x=NULL,y=var,title=paste0('Annual ',var)) +
  facet_wrap(~station, ncol = 6, scales='free')

ggsave(paste0(idir,var,'-annual.png'), height=10)
