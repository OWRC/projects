


library(dplyr)
library(tidyr)
library(plyr)
library(ggplot2)
library(lubridate)



fn <- "climate/DataCurrent/weather/Monitoring Network_Real Time Monitoring_Administration Office_Download_1_17_2025 6_15_24 PM"



df.orig <- read.csv(paste0(fn,'.csv'), skip = 9) %>%
  slice(-1) %>%
  select_if(~sum(!is.na(.)) > 0)

cols <- names(df.orig)[seq(2,ncol(df.orig),2)]


# Re-Organize table
# see: https://stackoverflow.com/questions/32732728/gather-multiple-date-value-columns-using-tidyr
df <- df.orig %>%
  dplyr::rename(date = seq(1,ncol(df.orig),2), valu = seq(2,ncol(df.orig),2)) %>%
  gather(key = date_position, value = date, starts_with("date")) %>%
  gather(key = value_position, value = value, starts_with("valu")) %>%
  mutate(date_position = gsub('[^0-9]', "", date_position),
         value_position = gsub('[^0-9]', "", value_position)) %>%
  filter(date_position == value_position) %>% 
  mutate(dtyp = as.factor(plyr::mapvalues(date_position, seq(1,length(cols)),cols))) %>%
  select(-ends_with("position")) %>% 
  mutate(date = as.POSIXct(date, format='%Y-%m-%d %H:%M:%OS'), value = as.numeric(value)) %>%
  drop_na()

levels(df$dtyp)

df %>% 
  mutate(date = as.Date(date)) %>%
  group_by(date,dtyp) %>%
  dplyr::summarise(value=mean(value)) %>%  
  spread(dtyp,value) %>% 
  write.csv(paste0(fn,'-reorg.csv'), na = "", row.names=FALSE)

df %>% ggplot(aes(date,value)) %>% facet_grid(dtyp)

