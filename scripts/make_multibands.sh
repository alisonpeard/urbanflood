#!/bin/bash
# user> ./make_multibands.sh
#=============================================
# Batch translate JPEG 2000 to GeoTIFF
# https://www.tucson.ars.ag.gov/notebooks/uploading_data_2_gee.html
#=============================================
wdir="/Users/alisonpeard/Documents/Oxford/DPhil/flood_mapping/urbanflood"
creoleLA="$wdir/data/s2l2a_tiffs/T15RVP"
dhaka="$wdir/data/s2l2a_tiffs/T45QZG"
easthouston="$wdir/data/s2l2a_tiffs/T15RTN"
kolkata="$wdir/data/s2l2a_tiffs/T45QXF"
murcia="$wdir/data/s2l2a_tiffs/T30SXH"
wuhan="$wdir/data/s2l2a_tiffs/T50RKU"
#=============================================
# Main script
#=============================================
read -p 'ROI: ' roi
indir=${!roi}
outdir="$wdir/data/s2l2a_tiffs"
ls ${indir}*"_B"*_10m*.tif > "$outdir/btif_${roi}.txt"
gdalbuildvrt -separate -overwrite -input_file_list "$outdir/btif_${roi}.txt" "$outdir/S2L2A_${roi}.vrt"
gdal_translate -strict -ot uint16 "$outdir/S2L2A_${roi}.vrt" "$outdir/S2L2A_${roi}_10m_mb.tif"

ls ${indir}*"_B"*_20m*.tif > "$outdir/btif_${roi}.txt"
gdalbuildvrt -separate -overwrite -input_file_list "$outdir/btif_${roi}.txt" "$outdir/S2L2A_${roi}.vrt"
gdal_translate -strict -ot uint16 "$outdir/S2L2A_${roi}.vrt" "$outdir/S2L2A_${roi}_20m_mb.tif"

ls ${indir}*"_B"*_60m*.tif > "$outdir/btif_${roi}.txt"
gdalbuildvrt -separate -overwrite -input_file_list "$outdir/btif_${roi}.txt" "$outdir/S2L2A_${roi}.vrt"
gdal_translate -strict -ot uint16 "$outdir/S2L2A_${roi}.vrt" "$outdir/S2L2A_${roi}_60m_mb.tif"
