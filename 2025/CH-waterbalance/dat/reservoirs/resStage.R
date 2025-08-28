

####
# must run getData.R
####


dfpct <- df %>%
  dplyr::filter(dtyp == 'Reservoir.Level.Geodetic.PT..m.') %>%
  dplyr::filter(value>226) %>% # for Kelso Dam and Hilton falls
  select(-dtyp) %>%
  mutate(date=as.Date(floor_date(date, unit = "days"))) %>%
  group_by(date) %>%
  dplyr::summarise(value=mean(value)) %>%
  ungroup() %>%  
  mutate(year=year(date),month=month(date),doy=yday(date)) %>%
  group_by(doy) %>%
  filter(value != min(value),value != max(value)) %>%
  ungroup() %>%
  group_by(month) %>%
  dplyr::summarise(upper = quantile(value,.95), lower = quantile(value,.05))
  # dplyr::summarise(upper = max(value), lower = min(value))

# dfpct <- df %>%
#   dplyr::filter(dtyp == 'Reservoir.Level.Geodetic.PT..m.') %>%
#   dplyr::filter(value>226) %>% # for Kelso Dam and Hilton falls
#   select(-dtyp) %>%
#   mutate(month=month(date)) %>%
#   group_by(month) %>%
#   dplyr::summarise(upper = quantile(value,.9), lower = quantile(value,.1))

print(dfpct)
write.csv(dfpct, paste0(fn,'-minmax.csv'), row.names = FALSE)


# Stage plots
df %>%
  dplyr::filter(dtyp == 'Reservoir.Level.Geodetic.PT..m.') %>%
  dplyr::filter(value>226) %>% # for Kelso Dam and Hilton falls
  select(-dtyp) %>%
  mutate(date=as.Date(floor_date(date, unit = "days"))) %>%
  group_by(date) %>%
  dplyr::summarise(value=mean(value)) %>%
  ungroup() %>%
  mutate(year = as.factor(year(date)), dummydate=make_date(2004, month(date), day(date))) %>%
  ggplot(aes(dummydate)) +
    theme_bw() + theme(legend.position = 'bottom') +
    geom_point(aes(y=value,colour=year)) +
    geom_step(data=dfpct %>% mutate(dummydate=make_date(2004, month, 15)), aes(y=lower), direction='mid', linewidth=2, alpha=.5) +
    geom_step(data=dfpct %>% mutate(dummydate=make_date(2004, month, 15)), aes(y=upper), direction='mid', linewidth=2, alpha=.5) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b") +
    labs(title='Reservoir stage',subtitle=fn,x=NULL,y='stage (masl)')

ggsave(paste0(fn,'.png'))




