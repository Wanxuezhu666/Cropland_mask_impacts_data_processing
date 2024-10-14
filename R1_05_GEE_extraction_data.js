

var countries = ee.FeatureCollection("USDOS/LSIB_SIMPLE/2017"),
    geometry = 
    /* color: #0000ff */
    /* shown: false */
    ee.Geometry.Polygon(
        [[[-20, 30],
          [-20, -30],
          [50, -30],
          [50, 30]]]),
    ERA5_Land_month = ee.ImageCollection("ECMWF/ERA5_LAND/MONTHLY_AGGR"),
    imageCollection = ee.ImageCollection("NASA/GPM_L3/IMERG_V06");

var region_Boundary = countries.filterBounds(geometry);

Map.addLayer(region_Boundary, {}, 'Africa Boundary');// Show Africa in the map

// We used GPM precipitation data as an example

var GPM_region = ee.ImageCollection('NASA/GPM_L3/IMERG_MONTHLY_V06')
    .filterDate('2020-01-01', '2020-12-31')  
    .select('precipitation') 
    .map(function(image) {
        return image.clip(region_Boundary); // clip the data using the African boundary
    });


var totalPrecipitation = GPM_region.reduce(ee.Reducer.sum());
var medianPrecipitation = GPM_region.reduce(ee.Reducer.median());
var top5PercentPrecipitation = GPM_region.reduce(ee.Reducer.percentile([95]));
var stdPrecipitation = GPM_region.reduce(ee.Reducer.stdDev());
var meanPrecipitation = GPM_region.reduce(ee.Reducer.mean());
var cvPrecipitation = stdPrecipitation.divide(meanPrecipitation).multiply(100);


// Export data as GeoTIFF
Export.image.toDrive({
  image: totalPrecipitation,
  description: 'GPM_total_precipitation_2010',
  folder:"GEE_product_GPM",
  scale: 10000
  region: region_Boundary.geometry().bounds(), 
  fileFormat: 'GeoTIFF', 
  maxPixels: 1e13 
});



