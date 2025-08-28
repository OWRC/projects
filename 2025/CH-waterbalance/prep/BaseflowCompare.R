

library(dplyr)
library(lubridate)
library(ggplot2)


qdir <- "E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/dat/streamflow/"
Gauge.list <- c('02HB004','02HB005','02HB011','02HB012','02HB022','02HB027','02HB028','02HB032','02HB033')
Gauge.CArea <- c(189.9612,106.0128,203.6232,73.206,90.702,24.0372,29.8908,31.7592,51.8364)


# from: 0084/10_operational_model/mmSHModel2005/mmSHModel2005.flx, processed using modflow_output_drainage_summary.ipynb
Gauge.GWD.orig <- c(156.36629, 206.92096, 259.10602, 204.78188, 238.49112, 146.59299, 246.98315, 204.70233, 227.86488)
# from: \0084\10_operational_model\mmSHModel-CH_310-NWT\SHModel-CH_310-NWT.flx
Gauge.GWD.NWT <- c(140.82793, 210.29189, 247.10931, 208.90004, 218.75067, 117.12388, 276.19785, 162.7543, 192.68744)



# Model converted to MODFLOW-NWT because the 2005 version was unstable
# Gauge.GWD.raven <- c(140.58922, 212.64119, 254.14072, 195.60548, 218.09447, 118.39295, 271.9754, 167.79588, 193.78316) # HMETS
Gauge.GWD.raven <- c(101.44991, 148.79129, 195.09512, 171.89664, 169.2861, 75.36428, 228.59117, 121.69008, 139.56721) # HBV 
Gauge.GWD.raven <- c(88.49169, 126.997604, 172.18974, 151.32932, 147.98317, 63.92938, 202.83524, 104.64441, 119.85792)


# get estimated baseflow (from separation)
n <- length(Gauge.list)
df.est <- data.frame(gauge=rep(NA, n),carea=rep(NA, n),BF.min=rep(NA, n),BF.max=rep(NA, n),BF.med=rep(NA, n))
i <- 0
for (g in Gauge.list) { 
  i=i+1
  fp <- paste0(qdir,g,'.csv')
  row <- read.csv(fp) %>%
    mutate(Date=as.Date(Date)) %>%
    filter(Date>'1993-09-30') %>%
    filter(Date<'2024-10-01') %>%
    select(c(BF.min,BF.med,BF.max)) %>%
    summarise(BF.min=mean(BF.min),BF.max=mean(BF.max),BF.med=mean(BF.med)) %>%
    mutate(gauge=g,carea=Gauge.CArea[i],gwdisch=Gauge.GWD.orig[i]) %>%
    select(gauge, carea, BF.min, BF.max, BF.med)
    
  df.est[i,] <- row
  
  print(fp)
  print(row)
}




# get simulated




f <- 86.4*365.24


df.est %>% 
  mutate(BF.min=BF.min/carea*f, BF.max=BF.max/carea*f, BF.med=BF.med/carea*f) %>%
  ggplot(aes(gauge,BF.med)) +
  theme_bw() +
  # theme(legend.position.inside=T, legend.position = c(.16, .87)) +
  theme(legend.position = 'bottom') +
  geom_pointrange(aes(, ymin = BF.min, ymax = BF.max, colour='Estimated (baseflow separation)'),linewidth=2,fatten = 2,alpha=.5) +
  geom_point(size=4) +
  geom_point(aes(y=Gauge.GWD.raven, colour='Simulated (Raven)'), shape=15, size=3) +
  geom_point(aes(y=Gauge.GWD.NWT, colour='Simulated (NWT)'), shape=15, size=3) +
  geom_point(aes(y=Gauge.GWD.orig, colour='Simulated (original)'), shape=15, size=3) +
  scale_colour_manual(values = c("black","darkgreen","blue","darkorange")) +
  labs( #title='Comparison of estimated and simulated groundwater discharge to streams',
       x=NULL,
       y='groundwater discharge (mm/yr)', 
       colour = NULL)

ggsave('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/report/sections/fig/MODFLOW-flux-compare-Raven.png',height = 4 ,width = 8)  

