

library(sf)
library(ggplot2)
library(cowplot)





cur <- read.csv("delivery/model_future_climate_CSIRO-Mk3-6-0_RCP85/output/Raven2025_SWS-waterbalance-current.csv")
fut <- read.csv("delivery/model_future_climate_CSIRO-Mk3-6-0_RCP85/output/Raven2025_SWS-waterbalance-future.csv")

sws <- read_sf('delivery/GIS/CH_Subs_Raven2025.shp') |>
  merge(cur,by.x='SubId', by.y='swsID') |>
  merge(fut,by.x='SubId', by.y='swsID', suffixes=c('.cur','.fut')) |>
  mutate(precipitation.chng=precipitation.fut-precipitation.cur,
         evapotranspiration.chng=evapotranspiration.fut-evapotranspiration.cur,
         runoff.chng=runoff.fut-runoff.cur,
         recharge.chng=recharge.fut-recharge.cur,)



p.pre <- ggplot(sws) +
  geom_sf(aes(fill=precipitation.chng)) +
  scale_fill_distiller(palette = "Blues", 
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Change in\nPrecipitation\n(mm/yr)\n',reverse=FALSE))


p.aet <- ggplot(sws) +
  geom_sf(aes(fill=evapotranspiration.chng)) +
  scale_fill_distiller(palette = "Greens", 
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Change in\nEvapotranspiration\n(mm/yr)\n',reverse=FALSE))


p.ro <- ggplot(sws) +
  geom_sf(aes(fill=runoff.chng)) +
  scale_fill_distiller(palette = "Purples", 
                       limits = c(NA,20),
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Change in\nRunoff\n(mm/yr)\n',reverse=FALSE))


p.rch <- ggplot(sws) +
  geom_sf(aes(fill=recharge.chng)) +
  scale_fill_distiller(palette = "OrRd",
                       direction = -1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Change in\nGroundwater\nRecharge\n(mm/yr)\n',reverse=FALSE))




# using cowplot to keep plots aligned
p.all <- align_plots(p.pre, p.aet, p.ro, p.rch, align="v")

ggsave('report/sections/fig/model-results/climatechange-precip.png',p.all[[1]])
ggsave('report/sections/fig/model-results/climatechange-aet.png',p.all[[2]])
ggsave('report/sections/fig/model-results/climatechange-runoff.png',p.all[[3]])
ggsave('report/sections/fig/model-results/climatechange-recharge.png',p.all[[4]])

