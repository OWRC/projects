

library(sf)
library(tidyterra)
library(terra)
library(ggplot2)
library(cowplot)



sws <- read_sf('delivery/GIS/CH_Subs_Raven2025.shp')


precip.rast <- rast('delivery/model_baseline/output/Raven2025_longterm.precipitation.bil')
aet.rast <- rast('delivery/model_baseline/output/Raven2025_longterm.evapotranspiration.bil')
runoff.rast <- rast('delivery/model_baseline/output/Raven2025_longterm.runoff.bil')
recharge.rast <- rast('delivery/model_baseline/output/Raven2025_longterm.recharge.bil')
discharge.rast <- rast('delivery/MODFLOW/SHModel-CH_310-NWT-Raven2025_groundwater-discharge.bil')
resid.rast <- rast('delivery/model_baseline/output/Raven2025_longterm.residual.bil')





p.pre <- ggplot(sws) +
  geom_spatraster(data=precip.rast) +
  geom_sf(fill=NA) +
  scale_fill_distiller(palette = "Blues", 
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Precipitation\n(mm/yr)\n',reverse=FALSE))

# ggsave('report/sections/fig/model-results/baseline-precip.png')


p.aet <- ggplot(sws) +
  geom_spatraster(data=aet.rast) +
  geom_sf(fill=NA) +
  scale_fill_distiller(palette = "Greens", 
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Evapotranspiration\n(mm/yr)\n',reverse=FALSE))

# ggsave('report/sections/fig/model-results/baseline-aet.png',dpi=300)


p.ro <- ggplot(sws) +
  geom_spatraster(data=runoff.rast) +
  geom_sf(fill=NA) +
  scale_fill_distiller(palette = "Purples", 
                       limits = c(0,400),
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Runoff\n(mm/yr)\n',reverse=FALSE))

# ggsave('report/sections/fig/model-results/baseline-runoff.png')


p.rch <- ggplot(sws) +
  geom_spatraster(data=recharge.rast) +
  geom_sf(fill=NA) +
  scale_fill_distiller(palette = "Blues",
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Groundwater\nRecharge\n(mm/yr)\n',reverse=FALSE))

# ggsave('report/sections/fig/model-results/baseline-recharge.png')


p.res <- ggplot(sws) +
  geom_spatraster(data=resid.rast) +
  geom_sf(fill=NA) +
  scale_fill_distiller(palette = "YlOrBr",
                       direction = -1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Waterbalance\nResidual\n(mm)\n',reverse=FALSE))

# ggsave('report/sections/fig/model-results/baseline-resid.png')


p.gwd <- ggplot(sws) +
  geom_spatraster(data=discharge.rast) +
  geom_sf(fill=NA) +
  scale_fill_distiller(palette = "Blues",
                       limits = c(0,1200),
                       direction = 1,
                       na.value="#00000000",
                       guide=guide_colorbar(title='Groundwater\nDischarge\n(mm/yr)\n',reverse=FALSE))





# using cowplot to keep plots aligned
p.all <- align_plots(p.pre, p.aet, p.ro, p.rch, p.gwd, p.res, align="v")

ggsave('report/sections/fig/model-results/baseline-precip.png',p.all[[1]])
ggsave('report/sections/fig/model-results/baseline-aet.png',p.all[[2]])
ggsave('report/sections/fig/model-results/baseline-runoff.png',p.all[[3]])
ggsave('report/sections/fig/model-results/baseline-recharge.png',p.all[[4]])
ggsave('report/sections/fig/model-results/baseline-discharge.png',p.all[[5]])
ggsave('report/sections/fig/model-results/baseline-resid.png',p.all[[6]])



