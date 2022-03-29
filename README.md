# Urban Flood
Flood mapping from Earth observation (EO) data. This is parked for now but I will look back it again later. <br> <br>
Data will be available from [here](https://drive.google.com/drive/folders/1PEWk1EoTjsuYFtD8fYGjk1sXEMu_gAaL?usp=sharing) and `ee.ImageCollection(projects/floodmapping-2022/assets/examples)` later.

## Jobs
- [x] Sentinel-1 flood mapping using omnibus test statistics
- [ ] Urban Sentinel-1 flood mapping as in [Chini (2019)](https://doi.org/10.3390/rs11020107)
- [ ] Validation data

# SAR Scripts
## mortcanty_tutorial.py
Contains functions from [this Tutorial](https://developers.google.com/earth-engine/tutorials/community/detecting-changes-in-sentinel-1-imagery-pt-1) to detect changes in Sentinel-1 imagery.

## Idai Floodmaps.ipynb
Notebook based on [this Tutorial](https://developers.google.com/earth-engine/tutorials/community/detecting-changes-in-sentinel-1-imagery-pt-1) replicating the floodmaps from Cyclone Idai and overlaying them with 2000 mangrove extent maps from Giri (2011). Exports images to Google Earth Engine Project `ee.ImageCollection(projects/floodmapping-2022/assets/examples)` and Google Drive root directory. Also saves final folium map locally as a .html file.

## R Scripts
### sen2cor.sh
Just a set of instructions for how to use sen2cor to process Sentinel-2 Level 1C to Level 2A. Not relevant for other machines.

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
4. [Keras in Python](https://www.datacamp.com/community/tutorials/convolutional-neural-networks-python)
5. [CNNs for visual recognition](https://cs231n.github.io/convolutional-networks/)
6. [Sen1Floods11 flood maps for DL](https://github.com/cloudtostreet/Sen1Floods11.git)
