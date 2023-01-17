library(terra)
library(exactextractr)
library(sf)
library(dplyr)
library(fasterize)
library(raster)

# Start timer (Run time on my machine: ~4 hours)
start_time <- Sys.time()
LC_INPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LC_COMPOSITE_30M.tif"
LC_OUTPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LC_COMPOSITE_1KM.tif"
LU_INPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LU_COMPOSITE_30M.tif"
LU_OUTPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LU_COMPOSITE_1KM.tif"

# Read-in national 1km raster grid
NCC_1KM_GRID <- raster("C:/Data/Boundaries/NCC_1KM_IDX.tif")

# Read-in 30m treed pixels (source)
LC_TREED_30m <- rast(LC_INPUT)
LU_TREED_30m <- rast(LU_INPUT)

# Project national 1km vector grid to Lambert_Conformal_Conic_2SP
NCC_1KM_IDX_LAMBERT <-  read_sf("C:/Data/Boundaries/NCC_1KM_IDX.shp") %>%
  st_transform(crs = terra::crs(LU_TREED_30m)) %>%
  st_make_valid()
# Calculate vector grid area
NCC_1KM_IDX_LAMBERT$AREA_m2 <- st_area(NCC_1KM_IDX_LAMBERT) # ~95 ha cell area, each cell has slightly different area

# Sum 30m treed pixels that intersect 1km national vector grid
# LC ----
NCC_1KM_IDX_LAMBERT$LC_TREE_COUNT <- exact_extract(LC_TREED_30m, NCC_1KM_IDX_LAMBERT, fun = "sum")
# LU ----
NCC_1KM_IDX_LAMBERT$LU_TREE_COUNT <- exact_extract(LU_TREED_30m, NCC_1KM_IDX_LAMBERT, fun = "sum")

# Convert 30m tree pixel sum to proportion
# LC ----
NCC_1KM_IDX_ALBERS_LC_TREED <-  NCC_1KM_IDX_LAMBERT %>%
  filter(LC_TREE_COUNT > 0) %>%
  mutate(LC_TREE_m2 = LC_TREE_COUNT * 900) %>%
  mutate(LC_TREE_PCT = as.numeric(round(((LC_TREE_m2 / AREA_m2) * 100),1))) %>%
  mutate(LC_TREE_PCT = if_else(LC_TREE_PCT > 100, 100, LC_TREE_PCT)) %>%
  st_transform(crs = st_crs(NCC_1KM_GRID)) # back to Canada_Albers_WGS_1984

# LU ----
NCC_1KM_IDX_ALBERS_LU_TREED <-  NCC_1KM_IDX_LAMBERT %>%
  filter(LU_TREE_COUNT > 0) %>%
  mutate(LU_TREE_m2 = LU_TREE_COUNT * 900) %>%
  mutate(LU_TREE_PCT = as.numeric(round(((LU_TREE_m2 / AREA_m2) * 100),1))) %>%
  mutate(LU_TREE_PCT = if_else(LU_TREE_PCT > 100, 100, LU_TREE_PCT)) %>%
  st_transform(crs = st_crs(NCC_1KM_GRID)) # back to Canada_Albers_WGS_1984

# Polygon to Raster
# LC ----
LC_FOREST_1KM <- fasterize(NCC_1KM_IDX_ALBERS_LC_TREED, NCC_1KM_GRID, field = "LC_TREE_PCT") 
writeRaster(rast(LC_FOREST_1KM), LC_OUTPUT, overwrite = TRUE, datatype="FLT4S")

# LU ----
LU_FOREST_1KM <- fasterize(NCC_1KM_IDX_ALBERS_LU_TREED, NCC_1KM_GRID, field = "LU_TREE_PCT") 
writeRaster(rast(LU_FOREST_1KM), LU_OUTPUT, overwrite = TRUE, datatype="FLT4S")

## End timer
end_time <- Sys.time()
end_time - start_time 
