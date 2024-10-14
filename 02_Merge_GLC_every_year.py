"""
This code is used to merge GLC_FCS30D 5*5° tif to the whole African region
Upated: 2024-Sep-12
By: Wanxue Zhu

"""

from osgeo import gdal
import numpy as np
import os



os.chdir(r"E:\01_Reseach_papers\R1_African_agriculture\GLC_FCS30D\E20\Output") 


# For each 5-arc-degree longitude band, merge data from south to north.

def merge_geotiffs_lon(paths, output_path):
    datasets = [gdal.Open(path) for path in paths]
    data_zero = np.zeros((datasets[0].RasterXSize, datasets[0].RasterYSize))
    data_arrays = [dataset.ReadAsArray() for dataset in datasets[:-1]] + [data_zero]
    
    driver = gdal.GetDriverByName('GTiff')
    output_dataset = driver.Create(
        output_path, datasets[0].RasterXSize, 15 * datasets[0].RasterYSize, 1, gdal.GDT_Byte,
        options=['COMPRESS=DEFLATE', 'PREDICTOR=2', 'ZLEVEL=9']
    )
    for i, data in enumerate(reversed(data_arrays)):
        output_dataset.GetRasterBand(1).WriteArray(data, 0, i * datasets[0].RasterYSize) 
    output_geotransform = list(datasets[0].GetGeoTransform())
    output_geotransform[0] = min(output_geotransform[0], datasets[-1].GetGeoTransform()[0])
    output_geotransform[3] = max(output_geotransform[3], datasets[-1].GetGeoTransform()[3])
    output_dataset.SetGeoTransform(tuple(output_geotransform))
    output_dataset.SetProjection(datasets[0].GetProjection())
    for dataset in datasets:
        dataset = None
    output_dataset = None



# Loop to generate paths and call merge_geotiffs
for i in range(1, 21):
    paths = [
        f'layer_{i}_E20S30.tif', f'layer_{i}_E20S25.tif', f'layer_{i}_E20S20.tif',
        f'layer_{i}_E20S15.tif', f'layer_{i}_E20S10.tif', f'layer_{i}_E20S5.tif',
        f'layer_{i}_E20N0.tif', f'layer_{i}_E20N5.tif', f'layer_{i}_E20N10.tif',
        f'layer_{i}_E20N15.tif', f'layer_{i}_E20N20.tif', f'layer_{i}_E20N25.tif',
        f'layer_{i}_E20N30.tif', f'layer_{i}_E20N35.tif', f'layer_{i}_E20N40.tif'
    ]
    output_path = f'Year_{i + 1999}_E20_S30_N40_new.tif'
    merge_geotiffs_lon(paths, output_path)
    print(i)



# Check the data; it needs to be shifted 5 grids to the east.
import rasterio
from rasterio.transform import Affine


def move_projection(input_filename, output_filename, shift_degrees):
    with rasterio.open(input_filename) as src:
        transform = src.transform
        new_transform = Affine.translation(shift_degrees, 0) * transform
        kwargs = src.meta.copy()
        kwargs.update({
            'transform': new_transform
        })
        with rasterio.open(output_filename, 'w', **kwargs) as dst:
            dst.write(src.read())


for i in range(1, 22):
    input_filename = f"Year_{i}_W10N40.tif"
    output_filename = f"Year_{i}_W10N40_NEW.tif"
    move_projection(input_filename, output_filename, -5)  
    print (i)



#Merge the data from different longitude bands to form a unified dataset for the African continent.


from osgeo import gdal

def merge_geotiffs_lat(paths, output_path):
    datasets = [gdal.Open(path) for path in paths]
    driver = gdal.GetDriverByName('GTiff')
    # Create output dataset
    x_size = datasets[0].RasterXSize
    y_size = datasets[0].RasterYSize
    output_dataset = driver.Create(output_path, len(datasets) * x_size, y_size, 1, gdal.GDT_Byte, 
                                   options=['COMPRESS=DEFLATE', 'PREDICTOR=2', 'ZLEVEL=9'])
    # Write data from each input dataset to the output
    for i, dataset in enumerate(datasets):
        data = dataset.ReadAsArray()
        output_dataset.GetRasterBand(1).WriteArray(data, i * x_size, 0)
    # Adjust geotransform and projection based on the first dataset
    output_geotransform = list(datasets[0].GetGeoTransform())
    output_geotransform[0] = min(output_geotransform[0], datasets[-1].GetGeoTransform()[0])
    output_geotransform[3] = max(output_geotransform[3], datasets[-1].GetGeoTransform()[3])
    output_dataset.SetGeoTransform(tuple(output_geotransform))
    output_dataset.SetProjection(datasets[0].GetProjection())
    # Close datasets
    for dataset in datasets:
        dataset = None
    output_dataset = None



for i in range(1, 21):
    paths = [
        f'Year_{i+1999}_W20_S30_N40.tif', 
        f'Year_{i+1999}_W15_S30_N40.tif', 
        f'Year_{i+1999}_W10_S30_N40.tif',
        f'Year_{i+1999}_W5_S30_N40.tif',
        f'Year_{i+1999}_E0_S30_N40.tif',
        f'Year_{i+1999}_E5_S30_N40.tif',
        f'Year_{i+1999}_E10_S30_N40.tif',
        f'Year_{i+1999}_E15_S30_N40.tif',
        f'Year_{i+1999}_E20_S30_N40.tif',
        f'Year_{i+1999}_E25_S30_N40.tif',
        f'Year_{i+1999}_E30_S30_N40.tif',
        f'Year_{i+1999}_E35_S30_N40.tif',
        f'Year_{i+1999}_E40_S30_N40.tif',
        f'Year_{i+1999}_E45_S30_N40.tif',
        f'Year_{i+1999}_E50_S30_N40.tif'
    ]
    output_path = f'GLC_FCS30D_Year_{i+1999}.tif'
    merge_geotiffs_lat(paths, output_path)
    print(i)




