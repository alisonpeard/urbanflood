#######
# Explore different ml algorithm results
##########
rm(list=ls())
par(mfrow=c(1,1))
library(raster)
library(rgdal)  # readOGR()
library(maps)
library(sp)
library(sf)
library(terra)  # rgdal being retired
library(ISLR) # glm()
library(caret) # rf
library(class) # knn
library(nnet)  # neural nets
source("processing_functions.R")

# choose feature subset
# TODO: add other feature subsets later
subsets <- c("allfeatures", "4band")
subset <- subsets[2]

# load datasets
if(TRUE){
  wd <- paste0("/Users/alisonpeard/Documents/Oxford/DPhil/flood_mapping/urbanflood/")
  outfolder <- paste0(wd, "results")
  df1 <- read.csv(paste0(wd, "data/easthouston_2017/ptsinfo_lw.csv"))[-1]
  df2 <- read.csv(paste0(wd, "data/wuhan_2020/ptsinfo_lw.csv"))[-1]
  df3 <- read.csv(paste0(wd, "data/creoleLA_2020/ptsinfo_lw.csv"))[-1]
  df4 <- read.csv(paste0(wd, "data/dhaka_2020/ptsinfo_lw.csv"))[-1]
  df5 <- read.csv(paste0(wd, "data/kolkata_2020/ptsinfo_lw.csv"))[-1]
  df6 <- read.csv(paste0(wd, "data/murcia_2019/ptsinfo_lw.csv"))[-1]
  
  df1$event_id <- rep(1, nrow(df1))
  df2$event_id <- rep(2, nrow(df2))
  df3$event_id <- rep(3, nrow(df3))
  df4$event_id <- rep(4, nrow(df4))
  df5$event_id <- rep(5, nrow(df5))
  df6$event_id <- rep(6, nrow(df6))
  
  df <- rbind(df1, df2, df3, df4, df5, df6)
  df <- df[which(df$lw <= 1),]
  
  # remove lon, lat, and MNDWI columns
  df$lon <- NULL
  df$lat <- NULL
  df$MNDWI1 <- NULL
  df$MNDWI2 <- NULL
  df$MNDWI1_0 <- NULL
  df$MNDWI2_0 <- NULL
  df$MNDWI1_009 <- NULL
  df$MNDWI2_009 <- NULL
  df$permwater <- NULL  # should only be used to differentiate flooding
  
  # create a flood class (might use later)
  # df$flood <- as.numeric((df$lw==1 & df$permwater==0))
  
  # choose subsets
  if(subset=="4band"){
    df <- df[,c("B2", "B3", "B4", "B8", "elevation", "lw", "event_id")]
  }
}
# train/test split
if(TRUE){
  set.seed(0)
  df <- na.omit(df)
  df$lw <- as.factor(df$lw)
  df.wuhan <- df[which(df$event_id==3),]
  df <- df[-which(df$event_id==3),]
  df$event_id <- NULL
  df.wuhan$event_id <- NULL
  
  n <- nrow(df)
  itrain <- sample(1:n, size=round(.8*n))
  df.train <- df[itrain,]
  df.test <- df[-itrain,]
}
# visually explore features and relationships and save on .png
if(FALSE){
  png(file=paste0(outfolder, subset,"_pairs.png"), width=600, height=600)
  pairs(df, col=df$lw)
  dev.off()

  png(file=paste0(outfolder, subset,"_featurePlot.png"), width=800, height=600)
  x <- df
  x$lw <- NULL
  y <- df$lw
  scales <- list(x=list(relation="free"), y=list(relation="free"))
  featurePlot(x=x, y=y, plot="density", scales=scales, lwd=2,
              auto.key = list(columns = 2, points=T, lines=F), adjust = 1.5)
  dev.off()
}

# TODO: get dynamic threshold/PWI (Bonafilia, 2021)
# TODO: svms
# TODO: deep learning

# logistic regression
if(TRUE){
  glm.fit <- glm(lw~., data=df.train, family="binomial")
  # summary(glm.fit)
  # B8: 0.008767 ***
  # elevation: 0.176934 *
  glm.probs.test <- predict(glm.fit, newdata=df.test, type="response")
  glm.test <- as.factor(ifelse(glm.probs.test > 0.5, 1, 0))
  
  glm.probs.wuhan <- predict(glm.fit, newdata=df.wuhan, type="response")
  glm.wuhan <- as.factor(ifelse(glm.probs.wuhan > 0.5, 1, 0))

  glm.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=glm.test, 
                                mode="everything")
  glm.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=glm.wuhan, 
                                 mode="everything")
  
  glm.params <- round(glm.fit$coefficients, 4)
  string <- ""
  for(i in 1:length(glm.params)){
    string <- paste0(string, " β", i, ": ", glm.params[i])
  }
  glm.params <- string
  glm.test.metrics <- round(c(glm.cm.test$overall[1], glm.cm.test$overall[2], glm.cm.test$byClass[2]), 4)
  glm.wuhan.metrics <- round(c(glm.cm.wuhan$overall[1], glm.cm.wuhan$overall[2], glm.cm.wuhan$byClass[2]), 4)
  # varImp(glm.out) # variable importance
}

# train random forest and save statistics for test and wuhan
if(TRUE){
  set.seed(0)
  x <- df.train
  x$lw <- NULL
  y <- df.train$lw
  
  rf.out <- train(lw~., data=df.train, method='rf') # built-in cv
  # rf.fitted <- predict(rf.out) # corresponding fitted values
  rf.test <- predict(rf.out, df.test)
  rf.wuhan <- predict(rf.out, df.wuhan)

  rf.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=rf.test, 
                  mode="everything")
  rf.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=rf.wuhan, 
                                 mode="everything")
  
  rf.params <- rf.out$bestTune
  string <- ""
  for(i in 1:ncol(rf.params)){
    string <- paste0(string, " param", i, ": ", rf.params[i])
  }
  rf.params <- string
  rf.test.metrics <- round(c(rf.cm.test$overall[1], rf.cm.test$overall[2], rf.cm.test$byClass[2]), 4)
  rf.wuhan.metrics <- round(c(rf.cm.wuhan$overall[1], rf.cm.wuhan$overall[2], rf.cm.wuhan$byClass[2]), 4)
  # varImp(rf.out) # variable importance
}

# train k-nearest neighbours and save statistics for test and wuhan
if(TRUE){
  set.seed(0)
  knn.out <- train(lw~., data=df.train, method='knn') # built-in cv
  # knn.fitted <- predict(knn.out) # corresponding fitted values
  knn.test <- predict(knn.out, df.test)
  knn.wuhan <- predict(knn.out, df.wuhan)
  
  knn.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=knn.test, 
                                mode="everything")
  knn.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=knn.wuhan, 
                                 mode="everything")
  
  knn.params <- knn.out$bestTune
  string <- ""
  for(i in 1:ncol(knn.params)){
    string <- paste0(string, " param", i, ": ", knn.params[i])
  }
  knn.params <- string
  knn.test.metrics <- round(c(knn.cm.test$overall[1], knn.cm.test$overall[2], knn.cm.test$byClass[2]), 4)
  knn.wuhan.metrics <- round(c(knn.cm.wuhan$overall[1], knn.cm.wuhan$overall[2], knn.cm.wuhan$byClass[2]), 4)
  # varImp(knn.out) # variable importance
  
}

# train SVM with linear kernel and save statistics for test and wuhan
if(TRUE){
  set.seed(0)
  svmLinear.out <- train(lw~., data=df.train, method='svmLinear',  preProcess = c("center","scale")) # built-in cv
  # svmLinear.fitted <- predict(svmLinear.out) # corresponding fitted values
  svmLinear.test <- predict(svmLinear.out, df.test)
  svmLinear.wuhan <- predict(svmLinear.out, df.wuhan)
  
  svmLinear.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=svmLinear.test, 
                                 mode="everything")
  svmLinear.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=svmLinear.wuhan, 
                                  mode="everything")
  
  svmLinear.params <- svmLinear.out$bestTune
  string <- ""
  for(i in 1:ncol(svmLinear.params)){
    string <- paste0(string, " param", i, ": ", svmLinear.params[i])
  }
  svmLinear.params <- string
  svmLinear.test.metrics <- round(c(svmLinear.cm.test$overall[1], svmLinear.cm.test$overall[2], svmLinear.cm.test$byClass[2]), 4)
  svmLinear.wuhan.metrics <- round(c(svmLinear.cm.wuhan$overall[1], svmLinear.cm.wuhan$overall[2], svmLinear.cm.wuhan$byClass[2]), 4)
  # varImp(svmLinear.out) # variable importance
  
}

# train SVM with radial basis function kernel and save statistics for test and wuhan
if(TRUE){
  set.seed(0)
  svmRadial.out <- train(lw~., data=df.train, method='svmRadial',  preProcess = c("center","scale")) # built-in cv
  # svmRadial.fitted <- predict(svmRadial.out) # corresponding fitted values
  svmRadial.test <- predict(svmRadial.out, df.test)
  svmRadial.wuhan <- predict(svmRadial.out, df.wuhan)
  
  svmRadial.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=svmRadial.test, 
                                       mode="everything")
  svmRadial.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=svmRadial.wuhan, 
                                        mode="everything")
  
  svmRadial.params <- svmRadial.out$bestTune
  string <- ""
  for(i in 1:ncol(svmRadial.params)){
    string <- paste0(string, " param", i, ": ", svmRadial.params[i])
  }
  svmRadial.params <- string
  svmRadial.test.metrics <- round(c(svmRadial.cm.test$overall[1], svmRadial.cm.test$overall[2], svmRadial.cm.test$byClass[2]), 4)
  svmRadial.wuhan.metrics <- round(c(svmRadial.cm.wuhan$overall[1], svmRadial.cm.wuhan$overall[2], svmRadial.cm.wuhan$byClass[2]), 4)
  # varImp(svmRadial.out) # variable importance
  
}

# train SVM with polynomial kernel and save statistics for test and wuhan
if(TRUE){
  set.seed(0)
  svmPoly.out <- train(lw~., data=df.train, method='svmPoly',  preProcess = c("center","scale")) # built-in cv
  # svmPoly.fitted <- predict(svmPoly.out) # corresponding fitted values
  svmPoly.test <- predict(svmPoly.out, df.test)
  svmPoly.wuhan <- predict(svmPoly.out, df.wuhan)
  
  svmPoly.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=svmPoly.test, 
                                       mode="everything")
  svmPoly.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=svmPoly.wuhan, 
                                        mode="everything")
  
  svmPoly.params <- svmPoly.out$bestTune
  string <- ""
  for(i in 1:ncol(svmPoly.params)){
    string <- paste0(string, " param", i, ": ", svmPoly.params[i])
  }
  svmPoly.params <- string
  svmPoly.test.metrics <- round(c(svmPoly.cm.test$overall[1], svmPoly.cm.test$overall[2], svmPoly.cm.test$byClass[2]), 4)
  svmPoly.wuhan.metrics <- round(c(svmPoly.cm.wuhan$overall[1], svmPoly.cm.wuhan$overall[2], svmPoly.cm.wuhan$byClass[2]), 4)
  # varImp(svmPoly.out) # variable importance
}

# train single layer neural net and save statistics for test and wuhan
if(TRUE){
  # normalise the data first
  normalise <- function(dat, mins, maxs){
    dat <- as.data.frame(scale(dat, center=mins, scale=maxs-mins))
    return(dat)
  }
  ndf <- na.omit(df)
  ndf$lw <- NULL
  ndf.wuhan <- na.omit(df.wuhan)
  ndf.wuhan$lw <- NULL
  mins = apply(ndf,2,min)
  maxs = apply(ndf,2,max)
  
  ndf = normalise(ndf, mins, maxs)
  ndf.wuhan = normalise(ndf.wuhan, mins, maxs)
  ndf$lw <- as.factor(na.omit(df)$lw)
  ndf.wuhan$lw <- as.factor(na.omit(df.wuhan)$lw)
  
  ndf.train <- ndf[itrain,]
  ndf.test <- ndf[-itrain,]
  x.train = ndf.train
  x.train$lw = NULL
  y.train = ndf.train$lw
  x.test = ndf.test
  x.test$lw = NULL
  y.test = ndf.test$lw
  
  set.seed(0)
  nnet.out <- train(lw~., data=ndf.train, method='nnet') # built-in cv
  # nnet.fitted <- predict(nnet.out) # corresponding fitted values
  nnet.test <- predict(nnet.out, ndf.test)
  nnet.wuhan <- predict(nnet.out, ndf.wuhan)
  
  nnet.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=nnet.test, 
                                 mode="everything")
  nnet.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=nnet.wuhan, 
                                  mode="everything")
  
  nnet.params <- nnet.out$bestTune
  string <- ""
  for(i in 1:ncol(nnet.params)){
    string <- paste0(string, " param", i, ": ", nnet.params[i])
  }
  nnet.params <- string
  nnet.test.metrics <- round(c(nnet.cm.test$overall[1], nnet.cm.test$overall[2], nnet.cm.test$byClass[2]), 4)
  nnet.wuhan.metrics <- round(c(nnet.cm.wuhan$overall[1], nnet.cm.wuhan$overall[2], nnet.cm.wuhan$byClass[2]), 4)
  # varImp(nnet.out) # variable importance
  
}

# 3-layer multilayer perceptron
if(TRUE){
  set.seed(0)
  trainCtrl = trainControl(method = 'cv', 
                           number = 10, 
                           classProbs=FALSE)
  if(FALSE){
    mlp.grid = expand.grid(layer1 = seq(6,12,by=1),
                                 layer2 = seq(3,5,by=1),
                                 layer3 = seq(3,5,by=1))
    # The final values used for the model were
    # layer1 = 6, layer2 = 3 and layer3 = 3.
  } else {
    mlp.grid = expand.grid(layer1 = 6,
                                 layer2 = 2,
                                 layer3 = 3)
  }
  
  mlp.out = train(lw~., data=ndf.train, method='mlpML',
                           trControl=trainCtrl, 
                           tuneGrid=mlp.grid)
  mlp.test = predict(mlp.out, newdata=ndf.test)
  mlp.wuhan <- predict(mlp.out, ndf.wuhan)
  
  mlp.cm.test <- confusionMatrix(reference=as.factor(df.test$lw), data=mlp.test, 
                                  mode="everything")
  mlp.cm.wuhan <- confusionMatrix(reference=as.factor(df.wuhan$lw), data=mlp.wuhan, 
                                   mode="everything")
  
  mlp.params <- mlp.out$bestTune
  string <- ""
  for(i in 1:ncol(mlp.params)){
    string <- paste0(string, " param", i, ": ", mlp.params[i])
  }
  mlp.params <- string
  mlp.test.metrics <- round(c(mlp.cm.test$overall[1], mlp.cm.test$overall[2], mlp.cm.test$byClass[2]), 4)
  mlp.wuhan.metrics <- round(c(mlp.cm.wuhan$overall[1], mlp.cm.wuhan$overall[2], mlp.cm.wuhan$byClass[2]), 4)
  # varImp(mlp.out) # variable importance
}

# output results to a csv
if(TRUE){
  results <- data.frame(matrix(nrow=0, ncol=8))
  colnames(results) <- c("algorithm", "parameters", "test_OA", "test_kappa", "test_precision",
                         "wuhan_OA", "wuhan_kappa", "wuhan_precision")
  
  results[1,]<-c("glm", glm.params, glm.test.metrics[1], glm.test.metrics[2],
                 glm.test.metrics[3], glm.wuhan.metrics[1], glm.wuhan.metrics[2], glm.wuhan.metrics[3])
  results[2,]<-c("rf", rf.params, rf.test.metrics[1], rf.test.metrics[2],
                 rf.test.metrics[3], rf.wuhan.metrics[1], rf.wuhan.metrics[2], rf.wuhan.metrics[3])
  results[3,]<-c("knn", knn.params, knn.test.metrics[1], knn.test.metrics[2],
                 knn.test.metrics[3], knn.wuhan.metrics[1], knn.wuhan.metrics[2], knn.wuhan.metrics[3])
  results[4,]<-c("svmLinear", svmLinear.params, svmLinear.test.metrics[1], svmLinear.test.metrics[2],
                 svmLinear.test.metrics[3], svmLinear.wuhan.metrics[1], svmLinear.wuhan.metrics[2], svmLinear.wuhan.metrics[3])
  results[5,]<-c("svmRadial", svmRadial.params, svmRadial.test.metrics[1], svmRadial.test.metrics[2],
                 svmRadial.test.metrics[3], svmRadial.wuhan.metrics[1], svmRadial.wuhan.metrics[2], svmRadial.wuhan.metrics[3])
  results[6,]<-c("svmPoly", svmPoly.params, svmPoly.test.metrics[1], svmPoly.test.metrics[2],
                 svmPoly.test.metrics[3], svmPoly.wuhan.metrics[1], svmPoly.wuhan.metrics[2], svmPoly.wuhan.metrics[3])
  results[7,]<-c("nnet", nnet.params, nnet.test.metrics[1], nnet.test.metrics[2],
                 nnet.test.metrics[3], nnet.wuhan.metrics[1], nnet.wuhan.metrics[2], nnet.wuhan.metrics[3])
  results[8,]<-c("mlp", mlp.params, mlp.test.metrics[1], mlp.test.metrics[2],
                 mlp.test.metrics[3], mlp.wuhan.metrics[1], mlp.wuhan.metrics[2], mlp.wuhan.metrics[3])
  
  write.csv(results, paste0(outfolder, subset,"_results.csv"), row.names=FALSE)
}
