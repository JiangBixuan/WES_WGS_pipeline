# Author:weizhou
# Data:201903
# Email:zhouweihkd@163.com
# 3.statistics the results and plot

##################################################
library(ggplot2)
library(plyr)
library(dplyr)
library(tidyr)
setwd('E:/SJTU实验数据/03代谢综合征/数据/100个外显子/bamqc')
HS <- read.csv('Hs.final.csv',header = T)
head(HS)

# total reads number
binsize <- diff(range(HS$TOTAL_READS))/20
ggplot(HS,aes(TOTAL_READS))+geom_histogram(binwidth = binsize,fill='white',col='black')+
  coord_flip()+labs(title='Total reads of samples')+theme_gray(base_size = 40)
ggsave('total reads.tiff',plot=last_plot(),width=30,height=20,dpi=300,compression="lzw")

# coverage of sequencing
ggplot(HS,aes(MEAN_TARGET_COVERAGE))+geom_histogram(fill='white',col='black')+
  coord_flip()+labs(title='mean coverage of sequencing')+theme_gray(base_size = 40)
ggsave('coverage.tiff',plot=last_plot(),width=30,height=20,dpi=300,compression="lzw")

# TARGET_BASES
target <- HS[,c('Sample_ID','ON_TARGET_BASES','NEAR_TARGET_BASES','OFF_TARGET_BASES')]
head(target)
#case data to plot
target_new <- gather(target,key = 'TARGET_BASES',value = 'percent',-Sample_ID)
head(target_new)
str(target_new)

ggplot(target_new,aes(x=reorder(Sample_ID,percent),y=percent,fill=TARGET_BASES))+
  geom_bar(stat = 'identity')+
  theme(axis.text.x=element_text(angle=45, hjust=1,size = 6))+
  labs(title='Base distribution on the Target region',x='Sample_ID')

# depth distribution of targeted base
depth <- HS[,c('Sample_ID','PCT_TARGET_BASES_10X','PCT_TARGET_BASES_20X','PCT_TARGET_BASES_30X','PCT_TARGET_BASES_40X','PCT_TARGET_BASES_50X')]
head(depth)
#depth_new <- gather(depth,key = 'target',value = 'percent',-Sample_ID)
#head(depth_new)

ggplot(depth,aes(x=Sample_ID,y=PCT_TARGET_BASES_30X))+
  theme_bw()+
  geom_bar(stat = 'identity',fill='#35B0AB')+
  theme(axis.text.x=element_text(angle=50, hjust=1,size = 7))+
  labs(title='Depth distribution of targeted base on 30X',x='Sample_ID',y='Target_base_30X')