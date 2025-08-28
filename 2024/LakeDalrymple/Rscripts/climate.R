

library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)
library(ggpattern)



df.met <- read.csv('dat/6111769 COLDWATER WARMINSTER.csv') %>%
  mutate(Date=as.Date(Date),
         year=factor(format(Date, "%Y")),
         mnt=factor(format(Date, "%b"),levels=c("Oct","Nov","Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep")),
         jul=factor(format(Date, "%j")),
         Period=factor(case_when(Date>'2013-9-30' ~ '2013-2023', TRUE ~ '1983-2013'))) %>% 
  filter(Date<'2023-10-1', Date>'1983-9-30')


montho <- function (x) (month(x)+2) %% 12




###############################
df.met %>%
  filter(Precip>1) %>%
  ggplot() +
    theme_bw() +
    theme(legend.position = c(.9,.9)) +
    geom_boxplot(aes(x = mnt, y = Precip, fill=Period), outlier.shape = NA) + #, position = position_dodge(width = .9))
    scale_fill_manual(values=c("#0060ee","#7ba900")) +
    labs(title="Distribution of precipitation events greater than 1 mm/day",
         subtitle="6111769: COLDWATER WARMINSTER",
         x=NULL,y="precipitation accumulation (mm/day)") +
    ylim(c(NA,30))



###############################
df.met %>%
  ggplot() +
    theme_bw() +
    theme(legend.position = c(.9,.25)) +
    geom_hline(yintercept = 0, alpha=.25, linewidth=1) +
    geom_boxplot(aes(x = mnt, y = Tmax, fill=Period), outlier.shape = NA) + #, position = position_dodge(width = .9))
    scale_fill_manual(values=c("#0060ee","#7ba900")) +
    labs(title="Distribution of daily maximum termperatures",
         subtitle="6111769: COLDWATER WARMINSTER",
         x=NULL,y="temperature (°C)") +
    ylim(c(-25,40))

###############################
df.met %>%
  ggplot() +
    theme_bw() +
    theme(legend.position = c(.9,.25)) +
    geom_hline(yintercept = 0, alpha=.25, linewidth=1) +
    geom_boxplot(aes(x = mnt, y = Tmin, fill=Period), outlier.shape = NA) + #, position = position_dodge(width = .9))
    scale_fill_manual(values=c("#0060ee","#7ba900")) +
    labs(title="Distribution of daily minimum termperatures",
         subtitle="6111769: COLDWATER WARMINSTER",
         x=NULL,y="temperature (°C)") +
    ylim(c(-35,30))

  
  
###############################
df.met %>%
  group_by(year,mnt,Period) %>%
  summarise(sp=sum(Precip,na.rm=TRUE),ss=sum(Snow,na.rm=TRUE)) %>%
  ungroup() %>%
  group_by(mnt,Period) %>%
  summarise(sp=mean(sp,na.rm=TRUE),ss=mean(ss,na.rm=TRUE)) %>%
  ungroup() %>%
  
  ggplot() +
    theme_bw() +
    theme(legend.position = c(.8,.9),
          legend.box = "horizontal") +
    geom_col(aes(y = sp, x=mnt, fill=Period),position = "dodge") +
    geom_col_pattern(aes(y = ss, x=mnt, fill=Period, pattern='snowfall'),
                     position = position_dodge(preserve = "single"),
                     color = "black",
                     pattern_fill = "black",
                     pattern_angle = 45,
                     pattern_density = .3,
                     pattern_spacing = 0.025,
                     pattern_key_scale_factor = .8) +
    scale_fill_manual(values=c("#0060ee","#7ba900")) +
    scale_pattern_manual(values = c(snowfall = "pch")) +
    labs(title="Monthly precipitation accumulation",
         subtitle="6111769: COLDWATER WARMINSTER",
         x=NULL,y="precipitation (mm/month)",pattern=NULL) +
    guides(pattern = guide_legend(override.aes = list(fill = "white")),
           fill = guide_legend(override.aes = list(pattern = "none")),
           col=2)




###############################
df.met %>%
  group_by(year,mnt,Period) %>%
  summarise(nsp=sum(PackDepth > 0,na.rm=TRUE)) %>%
  ungroup() %>%
  group_by(mnt,Period) %>%
  summarise(nsp=mean(nsp,na.rm=TRUE)) %>%
  ungroup() %>%
  ggplot() +
    theme_bw() +
    theme(legend.position = c(.9,.9)) +
    # geom_boxplot(aes(x = mnt, y = nsp, fill=Period), outlier.shape = NA) + #, position = position_dodge(width = .9))
    geom_col(aes(x=mnt,y = nsp, fill=Period),position = "dodge") +
    scale_fill_manual(values=c("#0060ee","#7ba900")) +
    labs(title="Number of days with snow on ground",
         subtitle="6111769: COLDWATER WARMINSTER",
         x=NULL,y="snow covered days")
