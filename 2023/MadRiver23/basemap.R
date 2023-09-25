

library(ggplot2)
library(sf)
library(ggspatial)
library(rnaturalearth)
# library(grid)
library(cowplot)
library(jsonlite)






# canada_sf <- countries110 %>%
#   st_as_sf() %>%
#   filter(NAME=="Canada")


ontario_sf <- ne_states(c("canada")) %>%
  st_as_sf(coords) %>%
  dplyr::filter(name=="Ontario")


nvca.bnd <- st_read('M:/MadRiver23/shp2/MadRiv_delineation_dissolve.shp', quiet=TRUE, crs = 26917) %>% st_transform(crs = 4326)
nvca.bnd.ext <- st_read('M:/MadRiver23/shp2/MadRiver23-10-extent.shp', quiet=TRUE, crs = 3161) %>% st_transform(crs = 4326)
# nvca.wtshd <- st_read('E:/OneDrive - Central Lake Ontario Conservation/inout/NVCA/230503 new Mad river model bound/Catchments_MadRiv/MadRiv_delineation.shp', quiet=TRUE)

wsc <- fromJSON('https://golang.oakridgeswater.ca/locsw2') %>% 
  dplyr::filter(LOC_NAME=='02ED015') %>%
  st_as_sf(coords = c("LONG","LAT"), crs = 4326)
  

drns <- st_read('M:/MadRiver23/shp2/OHN_WATERCOURSE-export-segments-MadRiver23.shp', quiet=TRUE)


p.inset <- ggplot(ontario_sf) +
  theme_void() +
  geom_sf() +
  geom_sf(data=nvca.bnd.ext,color='red', fill='transparent',linewidth=1) +
  coord_sf(xlim = c(-84,-76), ylim = c(NA,46)) +
  # coord_sf(xlim = c(-81.5,-78.5), ylim = c(43.2,45.1)) +
  theme(
    panel.border = element_rect(fill = NA, colour = "black"),
    plot.background = element_rect(fill = "grey95")
  )

# p.inset <-
#   ggplot(nvca.bnd) +
#   theme_void() +
#   annotation_map_tile(zoom=7) +
#   geom_sf(color='red', fill='transparent',linewidth=1) +
#   coord_sf(xlim = c(-81.5,-78.5), ylim = c(43.3,45)) +
#   theme(
#     panel.border = element_rect(fill = NA, colour = "black"),
#     plot.background = element_rect(fill = "grey95")
#   )


p.basemap <- ggplot(nvca.bnd) +
  # theme_void() +
  theme(legend.position = c(.95,.05), 
        legend.justification = c(1,0),
        legend.title = element_blank(), 
        legend.background = element_blank(),
        axis.title = element_blank()) +
  annotation_map_tile(zoom=12) +
  geom_sf(aes(shape='Upper Mad River watershed'), fill='transparent',linewidth=2) +
  scale_discrete_manual("linewidth", values = seq(0.1, 2, length.out = 8), guide = "none")



p.main <- p.basemap +
  # geom_sf(data=nvca.bnd.ext, fill='transparent',linewidth=2) +
  # geom_sf(data=nvca.wtshd, fill='transparent',linewidth=1.5,color='darkred') +
  # geom_sf(data=drns, aes(linewidth=as.factor(order)), color='blue', alpha=.5) +
  geom_sf(data=wsc, shape=23, fill="black", color="white", size=4) +
  geom_sf_text(data=wsc, aes(label=LOC_NAME_ALT1), hjust=1, vjust=0, size=3.5) 



# p.main
# print(p.inset, vp = viewport(0.322, 0.859, width = 0.25, height = 0.25))

ggdraw() +
  draw_plot(p.main) +
  draw_plot(p.inset,
            height = 0.15,
            x = .35,
            y = 0.25
  )
