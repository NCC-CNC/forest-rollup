library(raster)
library(terra)
library(sf)
library(fasterize)

# Step 1: Prep AOI -------------------------------------------------------------
## Start timer (Run time on my machine: 3.97348 mins)
start_time <- Sys.time()

## Read-in NCC 1km raster grid 
NCC_1KM_IDX <- raster(file.path("data", "grid", "NCC_1KM_IDX.tif"))

## Read-in BC IDX vector grid 
### prepped in ArcPro: 
### select by location, FISHNET with BC Admin boundary (buffered by 15km)
BC_1KM_IDX_SHP <- read_sf(file.path("data", "grid", "BC_1KM_IDX.shp"))

## Create AOI a) vector to raster ----
BC_1KM_IDX <- fasterize(BC_1KM_IDX_SHP, NCC_1KM_IDX) %>%
  writeRaster(file.path("data", "grid", "BC_1KM_IDX.tif"), datatype = "INT1U", 
    overwrite = TRUE)

## Create AOI b) raster to vector ----
BC_1KM_AOI <- terra::as.polygons(
  terra::rast(BC_1KM_IDX), dissolve = TRUE) %>%
  st_as_sf() %>%
  write_sf(file.path("data", "grid", "BC_1KM_AOI.shp"))


# Step 2: Prep LC (subset to BC for testing) -----------------------------------

## Read-in source LC 
CA_forest_VLCE2_2019 <- rast(
  file.path("data", "landcover", "CA_forest_VLCE2_2019.tif"))

# Project vector AOI to Lambert_Conformal_Conic_2SP 
BC_1KM_AOI_LAMBERT <- st_transform(BC_1KM_AOI,  
  crs = terra::crs(CA_forest_VLCE2_2019)) %>%
  vect() # conter to SpatVect

# Crop then mask CA_forest_VLCE2_2019 to AOI 
CA_forest_VLCE2_2019_BC <- terra::crop(CA_forest_VLCE2_2019, BC_1KM_AOI_LAMBERT) 
CA_forest_VLCE2_2019_BC <- terra::mask(CA_forest_VLCE2_2019_BC, BC_1KM_AOI_LAMBERT)
terra::writeRaster(CA_forest_VLCE2_2019_BC,
  file.path("data", "landcover", "CA_forest_VLCE2_2019_BC.tif"),
    overwrite = TRUE, datatype = "INT1U")
  
## Reclassify CA_forest_VLCE2_2019 (treed = 1, else = NoData) 
### 0=NA, 20=water, 31=snow/ice, 32=rock/rubble, 33=exposed/barren
### 40=bryoids, 50=shrubs, 80=wetlands, 81=wteland-treed, 100=herbs
### 210=coniferous, 220=broadleaf, 230=mixedwood
m <- c(0,NA, 20,NA, 31,NA, 32,NA, 33,NA, 40,NA, 50,NA, 80,NA, 81,1, 100,NA, 
       210,1, 220,1, 230,1)
rclmat <- matrix(m, ncol=2, byrow=TRUE)
CA_forest_VLCE2_2019_Treed <- terra::classify(CA_forest_VLCE2_2019_BC, rclmat)

terra::writeRaster(CA_forest_VLCE2_2019_Treed, 
  file.path("data", "landcover", "CA_forest_VLCE2_2019_BC_Treed.tif"),
    overwrite = TRUE, datatype = "INT1U")

## End timer
end_time <- Sys.time()
end_time - start_time
