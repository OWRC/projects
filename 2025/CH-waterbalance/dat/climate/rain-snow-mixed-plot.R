

library(dplyr)
library(tidyr)
library(ggplot2)

this.dir <- dirname(parent.frame(2)$ofile)
setwd(this.dir)

df <- read.csv('6152695.csv') %>%
  subset(select=-c(depth_of_surface_snow,mean_air_temperature,precipitation_amount)) %>%
  drop_na() %>%
  mutate(Tavg=(max_air_temperature+min_air_temperature)/2, precip=rainfall_amount+snowfall_amount) %>%
  filter(precip>0) %>%
  mutate(alpha=snowfall_amount/precip,stat=ifelse(alpha==1,'all rain', ifelse(alpha==0, 'all snow', 'mixed')))


df %>% ggplot() +
  theme_bw() + theme(legend.position = "inside", legend.position.inside = c(.1,.8), legend.title = element_blank()) +
  geom_density(aes(x=Tavg,y=after_stat(density * n/nrow(df)), fill=factor(stat)), alpha = 0.1, bw=1) +
  labs(title='distribuiton of precipitation type',subtitle='GEORGETOWN WWTP (6152695)',x='Air Temperature',y='density')

ggsave('rain-snow-mixed-plot.png',width=6,height=4)
