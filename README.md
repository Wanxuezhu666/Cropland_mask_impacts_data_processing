# Main codes for data processing
**Impacts of cropland masks on the explanation of crop yield anomaly in Africa**

This repository stores the main data processing code for the article, including Python and R scripts. We provide a step-by-step explanation of the data processing procedure.   
Updated: 2024-Oct-14

## 1. Merge GLC_FCS30D dataset
The GLC_FCS30D dataset provides global 30 m gridded land cover data from 1985 to 2022 (Zhang et al., 2024, https://essd.copernicus.org/articles/16/1353/2024/). 
It encompasses information on irrigated and rainfed croplands without specific crop type classification, and the original data is 5×5 arc degree.
Therefore, We stitched together the 5x5° data about Africa into a complete dataset for the entire African continent.

- We selected interested pixels identified with irrigated and rainfed cropland using **_01_GLC_select_orro_pixel_sep_year.py_**
- The 5° data were then merged into a complete mosaic of Africa using **_02_Merge_GLC_every_year.py_**

## 2. Extraction of crop relative yield anomalies from 2000 to 2020   
We downloaded national-level annual yield data for maize, millet, and sorghum from FAOSTAT (https://www.fao.org/faostat/en/#data/QCL).     
Relevant data were extracted from this dataset using **_03_Processing_FAOSTAT.py_**

The crop relative yield anomalies were extracted using **_04_Extract_yield_anomaly.py_**    
$RYA_i = AY_i/EY_i - 1$     
Where RYA is crop relative yield anomaly; $AY_i$ and $EY_i$ are reported actual yield and expected yield of crops in the year i, respectively.

## 3. Preprocess and download remote sensing and reanalyzed products from the GEE platform
The following datasets were used in this study using the Google Earth Engine Platform using **_05_GEE_extraction.js_**
- African administration boundary is from the LSIB 2017 data: https://developers.google.com/earth-engine/datasets/catalog/USDOS_LSIB_SIMPLE_2017 (last accessed 12 March 2024);
- MODIS LST data: https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD11A2 (last accessed 12 March 2024);
- MODIS ET data: https://developers.google.com/earth-engine/datasets/catalog/MODIS_061_MOD16A2 (last accessed 12 March 2024);
- GPM v6 data: https://developers.google.com/earth-engine/datasets/catalog/NASA_GPM_L3_IMERG_MONTHLY_V06 (last accessed 12 March 2024);
- ERA5-Land data: https://developers.google.com/earth-engine/datasets/catalog/ECMWF_ERA5_LAND_MONTHLY_AGGR  (last accessed 12 March 2024);   



