
library(ggplot2)
library(tidyr)
library(dplyr)


df <- read.csv('delivery/scripts/output/OCDP/RCP85/model-deltas.csv') %>% 
  mutate(id = row_number()) |>
  drop_na() |>
  mutate(trank = rank(mean.annual.temperature.change...C.)/length(mean.annual.temperature.change...C.),
         prank = rank(mean.annual.precipitation.change..mm.)/length(mean.annual.precipitation.change..mm.) )


df.percentile <- df |> 
  filter(row_number()==which.min(abs(trank-0.1)) |
         row_number()==which.min(abs(trank-0.25))|
         row_number()==which.min(abs(trank-0.5)) |
         row_number()==which.min(abs(trank-0.75)) |
         row_number()==which.min(abs(trank-0.9)) |
         row_number()==which.min(abs(prank-0.1)) |
         row_number()==which.min(abs(prank-0.25)) |
         row_number()==which.min(abs(prank-0.5)) |
         row_number()==which.min(abs(prank-0.75)) |
         row_number()==which.min(abs(prank-0.9)) )

df.bound <- df |>
  filter( (row_number()==which.min(trank*prank)) |
          (row_number()==which.max(trank*(1-prank))) |  
          (row_number()==which.max((1-trank)*prank)) |
          (row_number()==which.max(trank*prank)) )

df.median <- df |>
  filter(row_number()==which.min(abs((trank+prank)/2-0.5)))


df |> ggplot(aes(mean.annual.temperature.change...C.,mean.annual.precipitation.change..mm.)) +
  theme_bw() +
  theme(legend.position = 'bottom') +
  geom_point(data=df.percentile, shape=1, size=10, stroke=2) +
  geom_point(data=df.bound, shape=5, size=10, stroke=2) +
  geom_point(data=df.median, shape=0, size=10, stroke=2) +
  geom_text(aes(label = id), parse = TRUE) +
  labs(x='mean annual temperature change (°C)',y='mean annual precipitation change (mm)') +
  guides(colour="none")


ggsave('report/sections/fig/OCDP-model-scatter.png')
