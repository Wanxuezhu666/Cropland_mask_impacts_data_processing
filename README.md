# Main codes for data processing
**Impacts of cropland masks on the explanation of crop yield anomaly in Africa**

This repository stores the main data processing code for the article, including Python and R scripts. We provide a step-by-step explanation of the data processing procedure.

## 1. Merge GLC_FCS30D dataset
The GLC_FCS30D dataset provides global 30 m gridded land cover data from 1985 to 2022 (Zhang et al., 2024, https://essd.copernicus.org/articles/16/1353/2024/). 
It encompasses information on irrigated and rainfed croplands without specific crop type classification, and the original data is 5×5 arc degree.
Therefore, We stitched together the 5x5° data about Africa into a complete dataset for the entire African continent.

1.1 We selected interested pixels identified with irrigated and rainfed cropland using **_01_GLC_select_orro_pixel_sep_year.py_**
1.2 The 5° data were then merged into a complete mosaic of Africa using **_02_Merge_GLC_every_year.py_**

## 2. 
