#####
# Preliminary feature exploration and elimination
#####

rm(list=ls())
library(raster)
library(rgdal)  # readOGR()
library(maps)
library(sp)
library(sf)
library(terra)  # rgdal being retired
library(dismo) #for sample random points
library(corrplot)
source("processing_functions.R")

# load datasets
if(TRUE){
  wd <- paste0("/Users/alisonpeard/Documents/Oxford/DPhil/flood_mapping/urbanflood/")
  outfolder <- paste0(wd, "results/")
  df1 <- read.csv(paste0(wd, "data/easthouston_2017/ptsinfo_lw.csv"))[-1]
  df2 <- read.csv(paste0(wd, "data/orlando_2017/ptsinfo_lw.csv"))[-1]
  df3 <- read.csv(paste0(wd, "data/wuhan_2020/ptsinfo_lw.csv"))[-1]
  df <- rbind(df1, df2, df3)
  df <- na.omit(df[-which(df$lw > 1),])
  
  # remove lon, lat, and MNDWI columns
  df$lon <- NULL
  df$lat <- NULL
  df$MNDWI1 <- NULL
  df$MNDWI2 <- NULL
  df$MNDWI1_0 <- NULL
  df$MNDWI2_0 <- NULL
  df$MNDWI1_009 <- NULL
  df$MNDWI2_009 <- NULL
  df$permwater <- NULL  # until I find a better permanent water dataset
}

# visualisation station
corrplot(cor(df), method = 'color', order = 'alphabet', col=COL1('Blues'))
