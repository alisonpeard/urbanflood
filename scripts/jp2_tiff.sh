#!/bin/bash
# user> ./jp2_tiff.sh
#=============================================
# Batch translate JPEG 2000 to GeoTIFF
#=============================================
# done
wdir="/Users/alisonpeard/Documents/Oxford/DPhil/flood_mapping/urbanflood"
dhaka="$wdir/data/dhaka_2020/S2A_MSIL2A_20200605T042711_N9999_R133_T45QZG_20220207T162033.SAFE/GRANULE/L2A_T45QZG_A025870_20200605T042710/IMG_DATA"
easthouston="$wdir/data/easthouston_2017/S2A_MSIL2A_20170901T170521_N9999_R026_T15RTN_20220207T144804.SAFE/GRANULE/L2A_T15RTN_A011463_20170901T170523/IMG_DATA"
kolkata="$wdir/data/kolkata_2020/S2A_MSIL2A_20200529T043711_N9999_R033_T45QXF_20220207T164127.SAFE/GRANULE/L2A_T45QXF_A025770_20200529T043707/IMG_DATA"
murcia="$wdir/data/murcia_2019/S2B_MSIL2A_20190918T105029_N9999_R051_T30SXH_20220207T160002.SAFE/GRANULE/L2A_T30SXH_A013233_20190918T110002/IMG_DATA"
wuhan="$wdir/data/wuhan_2020/S2A_MSIL2A_20200807T025551_N9999_R032_T50RKU_20220207T170127.SAFE/GRANULE/L2A_T50RKU_A026770_20200807T030350/IMG_DATA"
#=============================================
# Main script
#=============================================
indir=$wuhan
outdir="$wdir/data/s2l2a_tiffs"
echo "${indir}"
ls "${indir}"

echo "translate 10m res images."
for f in "${indir}/R10m/"*.jp2; do
  searchstr="0m/"
  newf="${f#*$searchstr}"
  #f="${f#*$searchstr}"
  gdal_translate "$f" "${outdir}/${newf%.*}.tif"
done
echo "translate 20m res images."
for f in "${indir}/R20m/"*.jp2; do
  searchstr="0m/"
  newf="${f#*$searchstr}"
  #f="${f#*$searchstr}"
  gdal_translate "$f" "${outdir}/${newf%.*}.tif"
done
echo "translate 60m res images."
for f in "${indir}/R60m/"*.jp2; do
  searchstr="0m/"
  newf="${f#*$searchstr}"
  #f="${f#*$searchstr}"
  gdal_translate "$f" "${outdir}/${newf%.*}.tif"
done

# after doing cookies etc. upload to GEE using geeup
# geeup upload --source <wdir>/data/s2l2a_tiffs --dest users/alisonpeard/sentinel2_l2a -m /Users/alisonpeard/Documents/Oxford/DPhil/flood_mapping/urban_flood/week_3/data/s2l2a_tiffs/metadata.csv -u alison.peard@gmail.com
