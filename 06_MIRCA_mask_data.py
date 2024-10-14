import os
import numpy as np
import rasterio
import geopandas as gpd
from skimage.transform import resize


root_folder = r'sample_data\remote_sensing_data'
add_path = r'E:\papers\Africa\sorghum'
os.makedirs(add_path, exist_ok=True)


def read_geotiff(filepath):
    with rasterio.open(filepath) as src:
        return src.read(1), src


shp_filepath = r'sample_data\shp\Africa_boundary.shp'
shapefile = gpd.read_file(shp_filepath)


mask_image, dataset = read_geotiff('mirca_sorghum_rain.tif')
mask_image = mask_image.astype(float)
mask_image[mask_image == dataset.nodata] = np.nan

# calculate 5% threshold values
data_vector = mask_image[~np.isnan(mask_image)]
sorted_data = np.sort(data_vector)
index = int(0.05 * len(sorted_data))
max_value_in_top_5_percent = np.max(sorted_data[:index])

mask_image[mask_image < max_value_in_top_5_percent] = 0

transform = dataset.transform
rows, cols = mask_image.shape
lon, lat = np.meshgrid(np.arange(cols), np.arange(rows))
lon, lat = rasterio.transform.xy(transform, lat, lon, offset='center')
lon = np.array(lon)
lat = np.array(lat)


sub_folders = [f for f in os.listdir(root_folder) if os.path.isdir(os.path.join(root_folder, f))]

for sub_folder in sub_folders:
    current_folder = os.path.join(root_folder, sub_folder)
    tif_files = [f for f in os.listdir(current_folder) if f.endswith('.tif')]
    num_files = len(tif_files)
    num_polygons = len(shapefile)
    
    average_values = np.full((num_polygons, num_files), np.nan)

    for i, tif_file in enumerate(tif_files):
        tif_path = os.path.join(current_folder, tif_file)
        target_image, _ = read_geotiff(tif_path)

        target_image_resized = resize(target_image, mask_image.shape, preserve_range=True)
        binary_mask = mask_image > 0
        masked_image = np.where(binary_mask, target_image_resized, np.nan)

        longitude = lon.flatten()
        latitude = lat.flatten()
        value = masked_image.flatten()

        valid_idx = value > 0
        longitude = longitude[valid_idx]
        latitude = latitude[valid_idx]
        value = value[valid_idx]

        for j, polygon in shapefile.iterrows():
            polygon_geom = polygon['geometry']
            bounds = polygon_geom.bounds
            lon_mask = (longitude >= bounds[0]) & (longitude <= bounds[2])
            lat_mask = (latitude >= bounds[1]) & (latitude <= bounds[3])
            valid_points = value[lon_mask & lat_mask]
            valid_points = valid_points[valid_points > 0]
            if len(valid_points) > 0:
                average_values[j, i] = np.nanmean(valid_points)

    # Save data
    output_file = os.path.join(add_path, f"{sub_folder}.csv")
    np.savetxt(output_file, average_values, delimiter=",", header=",".join([str(year) for year in range(2001, 2021)]))
