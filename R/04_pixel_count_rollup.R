library(terra)
library(exactextractr)
library(sf)
library(dplyr)
library(fasterize)
library(raster)

# Start timer (Run time on my machine: ~4 hours)
start_time <- Sys.time() 
INPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/COMPSITE_VLCE2_2019_WF_CB_AAFC_LUTS_2020.tif"
OUTPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LU_COMPOSITE_1KM.tif"

# Read-in national 1km raster grid
NCC_1KM_GRID <- raster("C:/Data/Boundaries/NCC_1KM_IDX.tif")

# Read-in 30m treed pixels (source)
TREED_30m <- rast(INPUT)

# Project national 1km vector grid to Lambert_Conformal_Conic_2SP
NCC_1KM_IDX_LAMBERT <-  read_sf("C:/Data/Boundaries/NCC_1KM_IDX.shp") %>%
  st_transform(crs = terra::crs(TREED_30m)) %>%
  st_make_valid()
# Calculate vector grid area
NCC_1KM_IDX_LAMBERT$AREA_m2 <- st_area(NCC_1KM_IDX_LAMBERT) # ~95 ha cell area, each cell has slightly different area

# Sum 30m treed pixels that intersect 1km national vector grid
NCC_1KM_IDX_LAMBERT$TREE_COUNT <- exact_extract(TREED_30m, NCC_1KM_IDX_LAMBERT, fun = "sum")

# Convert 30m tree pixel sum to proportion
NCC_1KM_IDX_ALBERS_TREED <-  NCC_1KM_IDX_LAMBERT %>%
  filter(TREE_COUNT > 0) %>%
  mutate(TREE_m2 = TREE_COUNT * 900) %>%
  mutate(TREE_PCT = as.numeric(round(((TREE_m2 / AREA_m2) * 100),1))) %>%
  mutate(TREE_PCT = if_else(TREE_PCT > 100, 100, TREE_PCT)) %>%
  st_transform(crs = st_crs(NCC_1KM_GRID)) # back to Canada_Albers_WGS_1984

# Polygon to Raster
FOREST_1KM <- fasterize(NCC_1KM_IDX_ALBERS_TREED, NCC_1KM_GRID, field = "TREE_PCT") 
writeRaster(rast(FOREST_1KM), OUTPUT, overwrite = TRUE, datatype="FLT4S")

## End timer
end_time <- Sys.time()
end_time - start_time 
