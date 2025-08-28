
library(dplyr)
library(lubridate)
library(stringr)
library(ggplot2)



idir = 'climate/DataCurrent/weather/'
dfs <- vector(mode = "list", length = 6)
i <- 1
for (var in list('Air Temperature [°C]','Precipitation [mm]','Barometric Pressure [kPa]','Relative Humidity [%]','Wind Speed [Metres per Second]','Snow Depth [cm]')) {
  print(var)
  dfs[[i]] <- read.csv(paste0(idir,'merged_',var,'.csv')) %>%
    rename('value' = 3) %>%
    mutate(Date = ymd(str_split(Date, pattern=" ", simplify=T)[,1])) %>%
    group_by(Date, station) %>%
    summarise(value=sum(value)) %>%
    mutate(Parameter=var)
  i=i+1
}

df <- bind_rows(dfs) %>%
  mutate(station=factor(station))

nsta <- nlevels(df$station)

# Gantt
df %>% ggplot() +
  theme_minimal() +
  theme(legend.position.inside = TRUE, legend.position = c(.01,.99), legend.justification.inside = c(0, 1)) +
  geom_point(aes(Date,station,color=Parameter,group=Parameter), position=position_dodge(width=0.5), shape=3) +
  scale_y_discrete(position = "right") +
  scale_color_brewer(palette = "Dark2") +
  labs(x=NULL,y=NULL,title='Weather Stations')

ggsave(paste0(idir,'weather-AllParameters.png'), width=8)

