library(terra)
library(exactextractr)
library(sf)
library(dplyr)
library(fasterize)
library(raster)

# Start timer (Run time on my machine: ~20 mins)
start_time <- Sys.time() 

# Read-in national 1km raster grid
NCC_1KM_GRID <- raster( 
  file.path("data", "grid", "NCC_1KM_IDX.tif"))

# Read-in national 1km vector grid (BC_1KM_IDX)
NCC_1KM_IDX <- read_sf(
  file.path("data", "grid", "BC_1KM_IDX.shp")) %>%
  st_make_valid()
# Calculate vector grid area
NCC_1KM_IDX$AREA_m2 <- st_area(NCC_1KM_IDX) # 100 ha cell area

# Read-in 30m treed pixels (source)
TREED_30m <- rast(
  file.path("data", "landcover", "CA_forest_VLCE2_2019_BC_Treed.tif"))

# Project national 1km vector grid to Lambert_Conformal_Conic_2SP
NCC_1KM_IDX_LAMBERT <-  NCC_1KM_IDX %>%
  st_transform(crs = terra::crs(TREED_30m)) %>%
  st_make_valid()
# Calculate vector grid area
NCC_1KM_IDX_LAMBERT$AREA_m2 <- st_area(NCC_1KM_IDX_LAMBERT) # ~95 ha cell area, each cell has slightly different area

# Sum 30m treed pixels that intersect 1km national vector grid
NCC_1KM_IDX_LAMBERT$TREE_COUNT <- exact_extract(TREED_30m, NCC_1KM_IDX_LAMBERT,
 fun = "sum")

# Convert 30m tree pixel sum to proportion
NCC_1KM_IDX_LAMBERT_TREED <-  NCC_1KM_IDX_LAMBERT %>%
  filter(TREE_COUNT > 0) %>%
  mutate(TREE_m2 = TREE_COUNT * 900) %>%
  mutate(TREE_PCT = as.numeric(round(((TREE_m2 / AREA_m2) * 100),1))) %>%
  mutate(TREE_PCT = if_else(TREE_PCT > 100, 100, TREE_PCT)) %>%
  st_transform(crs = st_crs(NCC_1KM_IDX))

# Polygon to Raster
FOREST_1KM <- fasterize(
  NCC_1KM_IDX_LAMBERT_TREED, NCC_1KM_GRID, field = "TREE_PCT") 
writeRaster(FOREST_1KM, 
  file.path("data", "output", "FORST_1KM.tif"), overwrite = TRUE)

## End timer
end_time <- Sys.time()
end_time - start_time 
