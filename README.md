# Urban Flood
Flood mapping from Sentinel-2 imagery and other Earth observation data. This is parked for now but I will look back it again later. <br> <br>
Data will be available from [here](https://drive.google.com/drive/folders/1PEWk1EoTjsuYFtD8fYGjk1sXEMu_gAaL?usp=sharing) later. <br>
Sentinel-2 Level 2A images will be available from `ee.ImageCollection(projects/urbanflood-340815/assets/)` later.

![pipeline](https://user-images.githubusercontent.com/41169293/153858873-8fccc5ed-bec7-48dd-89a0-63ff2ae00338.png)

## Jobs
- [x] Change processing_functions.R to work for Level 2A data instead
- [ ] Generate Level 2A multiband GeoTIFFs
- [ ] Upload multiband GeoTIFFs to GEE `ee.ImageCollection(projects/urbanflood-340815/assets/)`
- [ ] Make data available on Google Drive
- [x] Reprocess easthouston_2017/
- [ ] Reprocess creoleLA_2020/
- [ ] Reprocess dhaka_2020/
- [ ] Reprocess kolkata_2020/
- [ ] Reprocess murcia_2019/
- [ ] Reprocess wuhan_2020/
- [ ] Re-run ml_pipeline.R with new data

## Scripts
### sen2cor.sh
Just a set of instructions for how to use sen2cor to prcoess Sentinel-2 Level 1C to Level 2A. Not relevant for other machines.

### jp2_tiff.sh
Batch translate JPEG2000 files to GeoTIFF so that they can be uploaded to Google Earth Engine.

### make_multibands.sh (unfinished)
To generate a single multiband image from a set of .tif files of Sentinel-2 Level 2A imagery. This is not currently working, it generates the images but only creates 3-band images instead of the eight, or so, that it should. I've asked about it on Stack Overflow [here](https://stackoverflow.com/questions/71177166/gdal-translate-only-translating-first-three-bands-from-vrt-to-tif) so maybe there will be some advice soon.

### process_data.R
R code to process data, sample points for training and testing and output into a .csv format.

### ml_pipeline.R
R code to train multiple ML models on the datasets and output results.

## Useful tutorials
Tutorials to look at when I come back to this:
1. [Unsupervised flood detection on Sentinel-2 imagery using the Sentinel API](https://medium.com/analytics-vidhya/unsupervised-flood-detection-with-sentinel-2-satellite-imagery-7a254dc2be2e)
2. [Detecting changes in Sentinel-1 imagery on GEE](https://developers.google.com/earth-engine/tutorials/community/detecting-changes-in-sentinel-1-imagery-pt-1)
3. [How to train U-Net on your dataset](https://medium.com/coinmonks/learn-how-to-train-u-net-on-your-dataset-8e3f89fbd623)
