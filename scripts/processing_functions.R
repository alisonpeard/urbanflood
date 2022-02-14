####
# functions to use with data processing script
###
cloudmask_landsat8 <- function(QA_sinu_roi, lonlat, roi_ll, masknum){
    QA_table <- as.data.frame(unique(QA_sinu_roi))
    colnames(QA_table) <- 'decimal' 
    QA_table$binary <- NA
    QA_table$cloud <- NA
    for (row in 1:nrow(QA_table)){
      #row <- 330
      QA_table[row,'binary'] <- paste(rev(as.integer(intToBits(unique(QA_table[row,'decimal']))[1:16])),collapse="")
      QA_table[row,'cloud'] <- paste(rev(as.integer(intToBits(unique(QA_table[row,'decimal']))[3])),collapse="")
      QA_table[row,'cloudShadow'] <- paste(rev(as.integer(intToBits(unique(QA_table[row,'decimal']))[4])),collapse="")
    }
    QA_table$cloudMask <- 0
    QA_table$cloudMask[which(QA_table$cloud=='1')] <- 1  
    QA_table$cloudShadowMask <- 0
    QA_table$cloudShadowMask[which(QA_table$cloudShadow=='1')] <- 1
    QA_table$ccsMask <- as.numeric((QA_table$cloudMask+QA_table$cloudShadowMask)>0)
    cloudMaskMatrix <- QA_table[,c('decimal','ccsMask')]
    
    ##derived two cloud masks 
    if(masknum==1){
      ###mask 1: get rid of clouds from the sinu data and then project to ll (preserve most pixels)
      QA_sinu_roi_cloudMask <- reclassify(QA_sinu_roi, cloudMaskMatrix)
      QA_sinu_roi_cloudMask_clear <- QA_sinu_roi_cloudMask
      QA_sinu_roi_cloudMask_clear[QA_sinu_roi_cloudMask==1] <- NA
      QA_sinu_roi_cloudMask_clear_ll <- projectRaster(QA_sinu_roi_cloudMask_clear, crs = lonlat)
      QA_sinu_roi_cloudMask_clear_ll2 <- crop(QA_sinu_roi_cloudMask_clear_ll,roi_ll)
      return(QA_sinu_roi_cloudMask_clear_ll2)
    } else if(masknum==2){
      ###mask 2: project to ll and get rid of clouds (make sure the boundary of random points within the roi_ll and are not cloud in roi_sinu)
      QA_sinu_roi_cloudMask <- reclassify(QA_sinu_roi, cloudMaskMatrix)
      QA_ll_roi_cloudMask <- projectRaster(QA_sinu_roi_cloudMask, crs = lonlat)
      QA_ll_roi_cloudMask2 <- crop(QA_ll_roi_cloudMask,roi_ll)
      QA_ll_roi_cloudMask2_clear <- QA_ll_roi_cloudMask2
      QA_ll_roi_cloudMask2_clear[QA_ll_roi_cloudMask2_clear>0] <- NA
      return(QA_ll_roi_cloudMask2_clear)
    } else{
      stop("please enter a mask number in {1, 2}")
    }
    
}

classify_points <- function(wd, pts, ref_ll_roi){
  # 0: water, 1:land, 2: cloud, 3: uncertain
  # note: changed wd for week 3 work
  data <- read.csv(paste0(wd,'/ptsinfo.csv'))
  data$lw <- NA
  
  # loop through the points
  coords <- coordinates(pts)
  for(row in 1:nrow(coords)){  
    x <- coords[row,"x"]
    y <- coords[row,"y"]
    zf <- 1
    point = extent(x-0.01,x+0.01,y-0.01,y+0.01)
    plotRGB(ref_ll_roi,ext=point,axes=TRUE)
    symbols(x=x, y=y, circles=0.005, add=T, inches=F, fg="red")
    input = readline(paste0(row,". Input 1 (land), 0 (water) or z (zoom in more): "))
    if(input=="z"){
      point = extent(x-0.005,x+0.005,y-0.005,y+0.005)
      plotRGB(ref_ll_roi,ext=point,axes=TRUE)
      symbols(x=x, y=y, circles=0.0025, add=T, inches=F, fg="red")
      input = readline("   Input 1 (land), 0 (water): ")
      if(input=="z"){
        point = extent(x-0.0025,x+0.0025,y-0.0025,y+0.0025)
        plotRGB(ref_ll_roi,ext=point,axes=TRUE)
        symbols(x=x, y=y, circles=0.00125, add=T, inches=F, fg="red")
        input = readline("   Input 1 (land) or 0 (water): ")
      }
    }
    data[row,"lw"] <- input
  }
  write.csv(data, paste0(wd,'/ptsinfo_lw.csv'), row.names = FALSE)
}