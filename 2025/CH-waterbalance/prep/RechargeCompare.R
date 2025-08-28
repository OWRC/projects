
library(dplyr)
library(tidyr)
library(ggplot2)


rchorig <- "M:/CH/MODFLOW/surfaces/SHModel-CH_310_RCH.grd"  #"M:/@projects/2025/CH-waterbalance/delivery/MODFLOW/SHModel-CH_310_RCH.bil"
rchRaven <- "M:/CH/MODFLOW/SHModel-CH_310/Raven2025.rch.bil"

sim <- data.frame(orig=readBin(file(rchorig, 'rb'), "double", size =4, n = 890*885, endian = 'little'),
                  raven=readBin(file(rchRaven, 'rb'), "double", size =4, n = 890*885, endian = 'little')
                  ) %>%
  mutate(orig=orig*86400*325.24*1000)

# sim %>%
#   filter(orig>-9999) %>%
#   ggplot(aes(orig,raven)) + geom_point()


sim %>%
  filter(raven>0) %>%
  gather() %>%
  ggplot(aes(value)) + geom_histogram(aes(fill=key), position="dodge")




sim %>%
  filter(raven>0) %>%
  gather() %>%
  ggplot(aes(value)) + geom_density(aes(colour=key))


