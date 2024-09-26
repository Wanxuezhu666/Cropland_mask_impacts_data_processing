# Main codes for data processing
**Impacts of cropland masks on the explanation of crop yield anomaly in Africa**

This repository stores the main data processing code for the article, including Python and R scripts. We provide a step-by-step explanation of the data processing procedure.

## 01. Merge GLC_FCS30D dataset
The GLC_FCS30D dataset provides global 30 m gridded land cover data from 1985 to 2022 (Zhang et al., 2024, https://essd.copernicus.org/articles/16/1353/2024/). 
It encompasses information on irrigated and rainfed croplands without specific crop type classification, and the original data is 5×5 arc degree.
Therefore, We stitched together the 5x5° data about Africa into a complete dataset for the entire African continent.
