"""
This code is used to extract GLC_FCS30D pixels with values of:
Rainfed cropland - 10
Irrigated cropland - 20
Upated: 2024-Sep-12
By: Wanxue Zhu

"""

import os
import numpy as np
from osgeo import gdal
from osgeo import gdal_array
from osgeo import osr


os.chdir("E:\\01_Reseach_papers\\R1_African_agriculture\\GLC_FCS30D\\E0") 


def save_selected_values(input_file, output_directory, selected_values):
    dataset = gdal.Open(input_file, gdal.GA_ReadOnly)
    if dataset is None:
        print("Failed to open", input_file)
        return
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)
    for i in range(1, dataset.RasterCount - 1):#Delete data in 2021-2023
        band = dataset.GetRasterBand(i)
        output_filename = os.path.join(output_directory, f'layer_{i}_E0N35.tif')#-------------------change the name of the tif
        data = band.ReadAsArray()
        output_data = np.where(data == 10, 1, np.where(data == 20, 2, np.nan))
        driver = gdal.GetDriverByName('GTiff')
        output_dataset = driver.Create(output_filename, dataset.RasterXSize, dataset.RasterYSize, 1, gdal.GDT_Byte, options=['COMPRESS=LZW'])
        output_dataset.SetGeoTransform(dataset.GetGeoTransform())
        output_dataset.SetProjection(dataset.GetProjection())
        output_band = output_dataset.GetRasterBand(1)
        output_band.WriteArray(output_data)
        output_band.SetNoDataValue(np.nan)
        output_band = None
        output_dataset = None
        print(i)


input_file = 'GLC_FCS30D_20002022_E0N35_Annual.tif'
# Process each 5*5 arc degree GLC_FCS30 data one by one,
# Change the name of the tif, all outputs are saved in the output_directory

output_directory = 'Output2'

# Save pixels with value of 10 and 20，others are set as None
selected_values = [10, 20]
save_selected_values(input_file, output_directory, selected_values)

"""
For the output, layer_1 means it is the data for the year 2000;
Similarly, layer_2 is data for the year 2001
....
layer_21 is data for the year 2020

"""
