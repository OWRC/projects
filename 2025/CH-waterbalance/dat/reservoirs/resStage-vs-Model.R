

####
# must run getData.R
####


dfRaven <- read.csv("M:/CH/Raven/Raven2025/output/Raven2025_ReservoirStages.csv") %>%
  mutate(date=as.Date(date), year=factor(year(date), levels=seq(1993,2024)), dummydate=make_date(2004, month(date), day(date)))



dfpct <- read.csv(paste0(fn,'-minmax.csv'))

df %>%
  dplyr::filter(dtyp == 'Reservoir.Level.Geodetic.PT..m.') %>%
  dplyr::filter(value>226) %>% # for Kelso Dam and Hilton falls
  select(-dtyp) %>%
  mutate(date=as.Date(floor_date(date, unit = "days"))) %>%
  group_by(date) %>%
  dplyr::summarise(value=mean(value)) %>%
  ungroup() %>%
  mutate(year = factor(year(date), levels=seq(1993,2024)), dummydate=make_date(2004, month(date), day(date))) %>%
  ggplot(aes(dummydate)) +
    theme_bw() + # theme(legend.position = 'bottom') +
    geom_blank(data=dfRaven, aes(colour=year)) +
    # geom_step(data=dfpct %>% mutate(dummydate=make_date(2004, month, 15)), aes(y=lower), direction='mid', linewidth=1, linetype='dashed', alpha=.35) +
    # geom_step(data=dfpct %>% mutate(dummydate=make_date(2004, month, 15)), aes(y=upper), direction='mid', linewidth=1, linetype='dashed', alpha=.35) +  
    geom_line(data=dfpct %>% mutate(dummydate=make_date(2004, month, 15)), aes(y=rulecurve), linewidth=1.5, linetype='dashed', alpha=.35) +  
    geom_point(aes(y=value,color=year), stroke=NA, shape=18, size=1, alpha=.5) +
  
    geom_line(data=dfRaven, aes(y=Kelso.Reservoir,colour=year), linewidth=1.25, alpha=.65) +
    # geom_line(data=dfRaven, aes(y=Mountsberg.Reservoir,colour=year), linewidth=1.25, alpha=.65) +
    # geom_line(data=dfRaven, aes(y=Scotch.Block.Reservoir,colour=year), linewidth=1.25, alpha=.65) +
    # geom_line(data=dfRaven, aes(y=Hilton.Falls.Reservoir,colour=year), linewidth=1.25, alpha=.65) +
  
    scale_x_date(date_breaks = "1 month", date_labels = "%b") +
    scale_colour_viridis_d(option = "turbo", direction = -1) +
    # guides(colour = guide_legend(override.aes = list(alpha = 1))) +
    labs(title='Reservoir stage, observed vs. simulated',subtitle=fn,x=NULL,y='stage (masl)')

ggsave(paste0(fn,'-Simulated.png'),height=5,width=8)
