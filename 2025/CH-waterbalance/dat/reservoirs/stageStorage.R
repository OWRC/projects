

####
# must run getData.R
####



df %>%
  dplyr::filter(dtyp %in% c('Reservoir.Level.Geodetic.PT..m.',
                            'Estimated.Reservoir.Storage..calculated...m..',
                            'Estimated.Reservoir.Discharge..calculated...m..s.',
                            'Estimated.Total.Discharge..calculated...m..s.')) %>%
  mutate(date=as.Date(floor_date(date, unit = "days"))) %>%
  group_by(dtyp,date) %>%
  dplyr::summarise(value=mean(value)) %>%
  ungroup() %>%
  spread(dtyp,value) %>%
  # ggplot(aes(x=Reservoir.Level.Geodetic.PT..m.,
  #            y=Estimated.Reservoir.Storage..calculated...m..)) +
  #   geom_point()
  gather(dtyp,value,-c(date,'Reservoir.Level.Geodetic.PT..m.')) %>%
  dplyr::filter(Reservoir.Level.Geodetic.PT..m.>226) %>% # for Hilton falls and Kelso Dam
  mutate(month=month(date)) %>%
  ggplot(aes(x=value,y=Reservoir.Level.Geodetic.PT..m.)) +
    theme(legend.position = 'none') +
    geom_point(aes(color=factor(month))) +
    facet_grid(cols = vars(dtyp), scales = "free")



# Stage-Storage plots

# https://stackoverflow.com/questions/11949331/adding-a-3rd-order-polynomial-and-its-equation-to-a-ggplot-in-r
lm_eqn = function(df){
  # m=lm(y ~ poly(x, 2, raw = TRUE), df)
  m=lm(y ~ x+I(x^2), df)
  eq <- substitute(italic(y) == a + b*italic(x)+ c*italic(x)^2*","~~italic(r)^2~"="~r2,
                   list(a = format(coef(m)[[1]], digits = 2, scientific=F),
                        b = format(coef(m)[[2]], digits = 2, scientific=F),
                        c = format(coef(m)[[3]], digits = 2, scientific=F),
                        r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq))
}


dfss <- df %>%
  dplyr::filter(dtyp %in% c('Reservoir.Level.Geodetic.PT..m.',
                            'Estimated.Reservoir.Storage..calculated...m..')) %>%
  mutate(date=as.Date(floor_date(date, unit = "days"))) %>%
  group_by(dtyp,date) %>%
  dplyr::summarise(value=mean(value)) %>%
  ungroup() %>%
  spread(dtyp,value) %>%
  dplyr::filter(Reservoir.Level.Geodetic.PT..m.>226) %>% # for Hilton falls and Kelso Dam
  dplyr::rename(x=Reservoir.Level.Geodetic.PT..m.,
                y=Estimated.Reservoir.Storage..calculated...m..) 


dfss %>%
  ggplot(aes(x,y)) +
  theme_bw() +
  geom_point() +
  geom_smooth(method = "lm", formula=y ~ poly(x, 2, raw=TRUE),colour="red", se = FALSE) +
  annotate("text", x=min(dfss$x)+.5, y=max(dfss$y)-(max(dfss$y)-min(dfss$y))*.05, label=lm_eqn(dfss), hjust=0, family="Times", face="italic", parse=TRUE) +
  labs(title='Reservoir stage/storage',subtitle=fn,x='stage (masl)',y='storage (m3)')


# write.csv(dfss, paste0(fn,'-SS.csv'))

ggsave(paste0(fn,'-SS.png'))


