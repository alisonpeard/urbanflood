#######
# Process new Sentinel data to produce data frames of sample points,
# spectral bands, and their classifications. (Needs user input)
##########
rm(list=ls())
par(mfrow=c(1,1))
library(raster)
library(rgdal)  # readOGR()
library(maps)
library(sp)
library(sf)
library(terra)  # rgdal being retired
library(dismo) #for sample random points
source("processing_functions.R")

# TODO: fix loading S2 bands for Level 2A product

# USER INPUT: define event and file names
region <- "easthouston"
year <- "2017"
# sDate <- "L1C_T15RTN_A011463_20170901T170523"
newdata <- T  # whether to manually classify points etc.
wd <- "/Users/alisonpeard/Documents/Oxford/DPhil/flood_mapping/urbanflood"

# set up environment
if(TRUE){
  outfolder <- paste0(region, '_', year)
  wd <- paste0(wd, "/data/",region,'_',year)
  
  # if using Level 2A products
  sdir <- list.files(wd, pattern="*.SAFE")[2]
  sdir <- paste0(wd, '/', sdir, "/GRANULE/")
  s <- list.files(sdir)
  sdir <- paste0(sdir, s, "/IMG_DATA/")
  sDate <- paste0(sdir, "R10m/", list.files(paste0(sdir, "R10m/"), "*_TCI_10m.jp2"))
  
  lonlat <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0'
}

#setup roi from shapefile
if(TRUE){
  roi_ll <- readOGR(dsn = paste0(wd), layer = region)
  #crs(roi_ll): +proj=longlat +datum=WGS84 +no_defs    
  sinu <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
  roi_sinu <- spTransform(roi_ll, sinu)
  if(newdata){
    roi_detail <- paste0("roi extent: ", extent(roi_ll), ", roi area: ", area(roi_ll))
    write(roi_detail, file=paste0(wd, "/info.txt"), append=TRUE)
  }
  # area tokybaysquare: 1254621729
  paste0("Area is ", area(roi_ll)/1254621729, " area of example.")
  paste0("Area is suitable size: ", area(roi_ll)/1254621729<5)
}

#load reference Sentinel-2 GeoTiff image and save plots
if(TRUE){
  #ref_utm <-stack(paste0(wd,"/",sDate,'.tif'))
  ref_utm <- stack(sDate)
  roi_utm <- spTransform(roi_ll, crs(ref_utm))
  ref_utm_roi <- crop(ref_utm, roi_utm)
  #crs(ref_utm): +proj=utm +zone=54 +datum=WGS84 +units=m +no_defs
  ref_ll_roi <- projectRaster(ref_utm_roi, crs=lonlat)
  
  #png(file=paste0(wd,'/',"sentinel2_roi.png"))
  #plotRGB(ref_ll)
  #plot(roi_ll, add=TRUE, border="red", lwd=3)
  #dev.off()
  
  png(file=paste0(wd,'/',"sentinel2_roicropped.png"))
  plotRGB(ref_ll_roi)
  dev.off()
  
  #system("say Finished processing Sentinel-2!")
}

# TODO: CHANGE FOR LEVEL 2A PRODUCTS FOR BANDS
#load and process Sentinel-2 band data
if(TRUE){
  # little tricky to get the dir names right...
  sdir <- list.files(wd, pattern="*.SAFE")[2]
  sdir <- paste0(wd, '/', sdir, "/GRANULE/")
  s <- list.files(sdir)
  sdir <- paste0(sdir, s, "/IMG_DATA/")
  s10dir <- paste0(sdir, "R10m/")
  s20dir <- paste0(sdir, "R20m/")
  s60dir <- paste0(sdir, "R60m/")
  
  b1file <- paste0(s60dir, list.files(s60dir, "*_B01_60m.jp2"))
  b1_utm <- raster(b1file)
  b1_utm_roi <- crop(b1_utm, roi_utm)
  b1_sinu_roi <- projectRaster(b1_utm_roi, crs=sinu)
  #plot(b1_sinu_roi)
  
  b2file <- paste0(s10dir, list.files(s10dir, "*_B02_10m.jp2"))
  b2_utm <- raster(b2file)
  b2_utm_roi <- crop(b2_utm, roi_utm)
  b2_sinu_roi <- projectRaster(b2_utm_roi, crs=sinu)
  
  b3file <- paste0(s10dir, list.files(s10dir, "*_B03_10m.jp2"))
  b3_utm <- raster(b3file)
  b3_utm_roi <- crop(b3_utm, roi_utm)
  b3_sinu_roi <- projectRaster(b3_utm_roi, crs=sinu)
  
  b4file <- paste0(s10dir, list.files(s10dir, "*_B04_10m.jp2"))
  b4_utm <- raster(b4file)
  b4_utm_roi <- crop(b4_utm, roi_utm)
  b4_sinu_roi <- projectRaster(b4_utm_roi, crs=sinu)
  
  b5file <- paste0(s20dir, list.files(s20dir, "*_B05_20m.jp2"))
  b5_utm <- raster(b5file)
  b5_utm_roi <- crop(b5_utm, roi_utm)
  b5_sinu_roi <- projectRaster(b5_utm_roi, crs=sinu)
  
  b6file <- paste0(s20dir, list.files(s20dir, "*_B06_20m.jp2"))
  b6_utm <- raster(b6file)
  b6_utm_roi <- crop(b6_utm, roi_utm)
  b6_sinu_roi <- projectRaster(b6_utm_roi, crs=sinu)
  
  b7file <- paste0(s20dir, list.files(s20dir, "*_B07_20m.jp2"))
  b7_utm <- raster(b7file)
  b7_utm_roi <- crop(b7_utm, roi_utm)
  b7_sinu_roi <- projectRaster(b7_utm_roi, crs=sinu)
  
  b8file <- paste0(s10dir, list.files(s10dir, "*_B08_10m.jp2"))
  b8_utm <- raster(b8file)
  b8_utm_roi <- crop(b8_utm, roi_utm)
  b8_sinu_roi <- projectRaster(b8_utm_roi, crs=sinu)
  
  b9file <- paste0(s60dir, list.files(s60dir, "*_B09_60m.jp2"))
  b9_utm <- raster(b9file)
  b9_utm_roi <- crop(b9_utm, roi_utm)
  b9_sinu_roi <- projectRaster(b9_utm_roi, crs=sinu)
  
  # b10file <- paste0(sdir, list.files(sdir, "*_B10.jp2"))
  # b10_utm <- raster(b10file)
  # b10_utm_roi <- crop(b10_utm, roi_utm)
  # b10_sinu_roi <- projectRaster(b10_utm_roi, crs=sinu)
  
  b11file <- paste0(s20dir, list.files(s20dir, "*_B11_20m.jp2"))
  b11_utm <- raster(b11file)
  b11_utm_roi <- crop(b11_utm, roi_utm)
  b11_sinu_roi <- projectRaster(b11_utm_roi, crs=sinu)

  b12file <- paste0(s20dir, list.files(s20dir, "*_B12_20m.jp2"))
  b12_utm <- raster(b12file)
  b12_utm_roi <- crop(b12_utm, roi_utm)
  b12_sinu_roi <- projectRaster(b12_utm_roi, crs=sinu)
  
  # resample B1,5,6,7,9,11,12 to 10m resolution
  b1_sinu_roi <- resample(b1_sinu_roi, b3_sinu_roi, method="ngb")
  b5_sinu_roi <- resample(b5_sinu_roi, b3_sinu_roi, method="ngb")
  b6_sinu_roi <- resample(b6_sinu_roi, b3_sinu_roi, method="ngb")
  b7_sinu_roi <- resample(b7_sinu_roi, b3_sinu_roi, method="ngb")
  b9_sinu_roi <- resample(b9_sinu_roi, b3_sinu_roi, method="ngb")
  b11_sinu_roi <- resample(b11_sinu_roi, b3_sinu_roi, method="ngb")
  b12_sinu_roi <- resample(b12_sinu_roi, b3_sinu_roi, method="ngb")
  
  # get RGB values
  rgb_sinu_roi <- stack(b4_sinu_roi,b3_sinu_roi,b2_sinu_roi)
  rgb_ll_roi <- projectRaster(rgb_sinu_roi, crs = lonlat)
  rgb_ll_roi2 <- crop(rgb_ll_roi,roi_ll)
  plotRGB(rgb_ll_roi2,r=1,g=2,b=3, stretch="lin")
  
  #get MNDWI (in sinu projection)
  MNDWI1_sinu <- (b3_sinu_roi-b11_sinu_roi)/(b3_sinu_roi+b11_sinu_roi)
  MNDWI2_sinu <- (b3_sinu_roi-b12_sinu_roi)/(b3_sinu_roi+b12_sinu_roi)
  
  MNDWI1_ll <- projectRaster(MNDWI1_sinu, crs = lonlat)
  MNDWI1_ll2 <- crop(MNDWI1_ll,roi_ll)
  MNDWI2_ll <- projectRaster(MNDWI2_sinu, crs = lonlat)
  MNDWI2_ll2 <- crop(MNDWI2_ll,roi_ll)
  breakpoints <- c(-150,0,150)
  colors <- c("#f1f2f2","#21c4c5")
  
  png(file=paste0(wd,'/',"MNDWI_311.png"))
  plot(MNDWI1_ll2,breaks=breakpoints,col=colors)
  dev.off()
  
  png(file=paste0(wd,'/',"MNDWI_312.png"))
  plot(MNDWI2_ll2,breaks=breakpoints,col=colors)
  dev.off()
  
  writeRaster(MNDWI1_ll2, paste0(wd,'/', 'MNDWI_311.tif'), overwrite=newdata)
  writeRaster(MNDWI2_ll2, paste0(wd,'/', 'MNDWI_312.tif'), overwrite=newdata)

  #system("say Finished loading band data!")
}

#load DEM data from GLO-30 or SRTM
if(TRUE){
  #demfile <- list.files(wd, "*.dt2")  # for SRTM data
  demfile <- "glo-30.tif"
  demfile <- paste0(wd, '/', demfile)
  dem_ll <- raster(demfile)
  dem_ll_roi <- crop(dem_ll, roi_ll)
  dem_ll_roi <- resample(dem_ll_roi, rgb_ll_roi, method="ngb")
  dem_utm_roi <- projectRaster(dem_ll_roi, crs=crs(ref_utm))
  dem_sinu_roi <- projectRaster(dem_ll_roi, crs=sinu)
}

#load permanent water from G1WBM
if(TRUE){
  #pwfile <- paste0(wd,'/../floodMapGL_permWB/floodMapGL_permWB.tif')  # for JRC data
  # includes salt marsh, permanent water etc. but leave for now
  # 50, 51 and 99 are permanent water
  pwfile <- paste0(wd, "/g1wbm.tif")
  pw_ll <- raster(pwfile)
  pw_ll_roi <- crop(pw_ll, roi_ll)
  pw_ll_roi <- resample(pw_ll_roi, rgb_ll_roi, method="ngb")
  
  # create classification matrix (leave this for later, might use vals)
  #reclass_df <- c(0, 40, 0,
  #                40, 100, 1,
  #                100, Inf, NA)
  #reclass_m <- matrix(reclass_df,
  #                    ncol = 3,
  #                    byrow = TRUE)
  #pw_ll_roi <- reclassify(pw_ll_roi, reclass_m)
  
  pw_utm_roi <- projectRaster(pw_ll_roi, crs=crs(ref_utm))
  pw_sinu_roi <- projectRaster(pw_ll_roi, crs=sinu, method="ngb")  # preserves values
}

#sample random points (no cloud mask currently)
if(TRUE){
  set.seed(123456)
  xys <- randomPoints(ref_ll_roi, 100)
  #points(xys)
  #extract(QA_ll_roi_cloudMask2, xys, method='simple')  #should be all zero
  
  pts <- SpatialPoints(xys,proj4string=crs(ref_ll_roi))
  id.df <- data.frame(ID=1:length(pts)) 
  id.df$lon<- as.data.frame(xys)$x
  id.df$lat<- as.data.frame(xys)$y
  spdf <- SpatialPointsDataFrame(pts, id.df)
  writeOGR(spdf, dsn = paste0(wd), layer = 'pts100', driver = "ESRI Shapefile" )
}

#get info from the 100 points (in sinu projection)
if(TRUE){
  pts_sinu <- spTransform(pts, sinu)
  #plot(QA_sinu_roi_cloudMask)
  #points(pts_sinu,col='red')
  #extract(QA_sinu_roi_cloudMask,pts_sinu , method='simple')  #should be all zero
  
  #get MNDWI values
  vali <- spdf@data
  vali$MNDWI1 <- extract(MNDWI1_sinu, pts_sinu , method='simple')
  vali$MNDWI2 <- extract(MNDWI2_sinu, pts_sinu , method='simple')
  vali$MNDWI1_0 <- as.numeric(vali$MNDWI1<0)
  vali$MNDWI1_009 <- as.numeric(vali$MNDWI1<0.09)
  vali$MNDWI2_0 <- as.numeric(vali$MNDWI2<0)
  vali$MNDWI2_009 <- as.numeric(vali$MNDWI2<0.09)
  
  #add bands to points
  vali$B1 <- extract(b1_sinu_roi, pts_sinu , method='simple')
  vali$B2 <- extract(b2_sinu_roi, pts_sinu , method='simple')
  vali$B3 <- extract(b3_sinu_roi, pts_sinu , method='simple')
  vali$B4 <- extract(b4_sinu_roi, pts_sinu , method='simple')
  vali$B5 <- extract(b5_sinu_roi, pts_sinu , method='simple')
  vali$B7 <- extract(b7_sinu_roi, pts_sinu , method='simple')
  vali$B8 <- extract(b8_sinu_roi, pts_sinu , method='simple')
  vali$B9 <- extract(b9_sinu_roi, pts_sinu , method='simple')
  vali$B11 <- extract(b11_sinu_roi, pts_sinu , method='simple')
  vali$B12 <- extract(b12_sinu_roi, pts_sinu , method='simple')
  
  # add dem values to points
  vali$elevation <- extract(dem_sinu_roi, pts_sinu , method='simple')
  vali$permwater <- extract(pw_sinu_roi, pts_sinu , method='simple')
  
  write.csv(vali,paste0(wd,'/ptsinfo.csv'),row.names = FALSE)
}

#plot all the data to data.tif in wd
if(TRUE){
  cols1 <- colorRampPalette(c("#f1f2f2", "#21c4c5"))
  cols2 <- colorRampPalette(c("black", "white"))
  
  tiff(file = paste0(wd,'/','data','.tif'), width = 189, height = 240, units = 'mm', res=300) 
  par(oma=c(1,1,1,1),par(mar=c(4,4,2,2)),xpd=T) 
  layout(matrix(c(1,2,3,4,5,6), 3, 2, byrow = TRUE),heights=c(1))
  
  plotRGB(ref_utm, axes=T)
  plot(roi_utm, border="red", add=T)
  title("Sentinel-2 Level 2A UTM")
  plotRGB(ref_ll_roi, axes=T)
  plot(pts,add=TRUE,col='red')
  title("Sentinel-2 ROI")
  
  plot(trim(pw_ll_roi),axes=FALSE,box=FALSE, col=cols1(10))
  title("G1WBM")
  
  plot(trim(dem_ll_roi),axes=FALSE,box=FALSE, col=cols2(100))
  title("GLO-30")
  
  plot(MNDWI1_ll2,axes=FALSE,box=FALSE,breaks=breakpoints,col=colors)
  points(pts,col='red')
  title("MNDWI 1")
  
  plot(MNDWI2_ll2,axes=FALSE,box=FALSE,breaks=breakpoints,col=colors)
  points(pts,col='red')
  title("MNDWI 2")
  
  dev.off()
}

#check projection and values: need to go back to this
if(TRUE){
  lonlat <- '+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0' 
  QA_projected <- projectRaster(QA_sinu, crs = lonlat)
  #plot(QA_projected)
  
  QA_projected_TB <- crop(QA_projected, roi_ll)
  unique(QA_projected_TB)
  plot(QA_projected_TB, main = "Cropped Landsat")
  
  sinu <- "+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +a=6371007.181 +b=6371007.181 +units=m +no_defs"
  roi_sinuProjected <- spTransform(roi_ll, sinu)
  plot(roi_sinuProjected,add=TRUE)
  #crs(QA)
  #+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs 
  
  QA_roi <- crop(QA_sinu, roi_sinuProjected)
  plot(QA_roi, main = "Cropped MODIS")
  #unique(QA)      #value same
  #unique(QA_TB)   #value same 
  
  QA_roi_projected <- projectRaster(QA_roi, crs = lonlat)
  plot(QA_roi_projected, main = "Cropped MODIS")
  #unique(QA_TB_projected)  #values change
  QA_roi_projected2 <- crop(QA_roi_projected, roi_ll)
  plot(QA_roi_projected2, main = "Cropped MODIS")
  #unique(QA_TB_projected2)  #values change
}

# classify points manually
if(newdata){
  par(mfrow=c(1,1))
  # 0: water, 1:land, 2: cloud, 3: uncertain
  classify_points(wd, pts, ref_ll_roi)
}

###get kappa etc - must have classified points manually first
if(TRUE){
  data <- read.csv(paste0(wd,'/ptsinfo_lw.csv'),stringsAsFactors = FALSE)
  # mth = mndwi threshold?
  for (mth in c('MNDWI1_0','MNDWI1_009','MNDWI2_0','MNDWI2_009')){
    
    obsv <- data$lw
    prdt <- data[,mth]
    
    obsv_l_prdt_l <- sum(obsv==1 & prdt==1, na.rm = TRUE)
    obsv_w_prdt_w <- sum(obsv==0 & prdt==0, na.rm = TRUE)
    obsv_l_prdt_w <- sum(obsv==1 & prdt==0, na.rm = TRUE)
    obsv_w_prdt_l <- sum(obsv==0 & prdt==1, na.rm = TRUE)
    
    cm <- data.frame(matrix(nrow=3,ncol=4))
    colnames(cm) <- c('Class','Predicted land','Predicted water','User')
    cm$Class <- c('Actual land','Actual water','Producer')
    
    cm[which(cm$Class=='Actual land'),'Predicted land'] <- obsv_l_prdt_l
    cm[which(cm$Class=='Actual water'),'Predicted water'] <- obsv_w_prdt_w
    cm[which(cm$Class=='Actual land'),'Predicted water']<- obsv_l_prdt_w
    cm[which(cm$Class=='Actual water'),'Predicted land'] <- obsv_w_prdt_l
    
    cm[which(cm$Class=='Actual land'),'User'] <- obsv_l_prdt_l/(obsv_l_prdt_l+obsv_l_prdt_w)
    cm[which(cm$Class=='Actual water'),'User'] <- obsv_w_prdt_w/(obsv_w_prdt_l+obsv_w_prdt_w)
    
    cm[which(cm$Class=='Producer'),'Predicted land'] <- obsv_l_prdt_l/(obsv_l_prdt_l+obsv_w_prdt_l)
    cm[which(cm$Class=='Producer'),'Predicted water'] <- obsv_w_prdt_w/(obsv_l_prdt_w+obsv_w_prdt_w)
    
    cm[which(cm$Class=='Producer'),'User'] <- (obsv_l_prdt_l+obsv_w_prdt_w)/length(obsv)
    
    write.csv(cm,paste0(wd,'/MNDWIconfusionMatrix',mth,'.csv'),row.names = FALSE)
  }
}  
