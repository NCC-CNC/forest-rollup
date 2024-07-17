#
# Author: Dan Wismer
#
# Date: July 17th, 2024
#
# Description: 1km roll-up method
#
# Inputs:  - final forest 30m layers
#          - Output folder 
#
# Outputs: - 1km forest layers
#
# Tested on R Versions: 4.4.1
# Processing time:  ~ 4 minutes
#==============================================================================

start_time <- Sys.time()
library(terra)
library(exactextractr)
library(sf)
library(dplyr)

# Inputs -----------------------------------------------------------------------

YEAR <- 2022 # <---- SET YEAR

OUT <- "C:/Data/NAT/Habitat/Forest"

FOREST_LC <- rast(file.path(OUT, paste0("Forest_LC_30m_", YEAR, ".tif")))
FOREST_LU <- rast(file.path(OUT, paste0("Forest_LU_30m_", YEAR, ".tif")))

# Read-in national 1km raster and vector grid
NCC_1KM_TIF <- rast("C:/Data/PRZ/GRID1KM/NCC_1KM_IDX.tif")
NCC_1KM_SHP <- read_sf("C:/Data/PRZ/GRID1KM//NCC_1KM_IDX.shp")

#------------------------------------------------------------------------------

# Project national 1km vector grid to Lambert_Conformal_Conic_2SP
lambert_1km <-  NCC_1KM_SHP %>% st_transform(crs = terra::crs(FOREST_LC))

# Calculate vector grid area
lambert_1km$Area_m2 <- st_area(lambert_1km) # ~95 ha cell area, each cell has slightly different area

# Sum 30m treed pixels that intersect 1km national vector grid
# 30m values are all 1, therefore sum is also getting the pixel count
# LC 
lambert_1km$LC_sum <- exact_extract(FOREST_LC, lambert_1km, fun = "sum") 
# LU 
# lambert_1km$LU_sum <- exact_extract(FOREST_LU, lambert_1km, fun = "sum")

# Convert 30m tree pixel sum to proportion
# LC 
lc_albers <-  lambert_1km %>%
  filter(LC_sum > 0) %>%
  mutate(LC_m2 = LC_sum * 900) %>% # convert pixel count to area (30m x 30m = 900m2)
  mutate(LC_pct = as.numeric(round(((LC_m2 / Area_m2) * 100),1))) %>% # pixel area / Lambert_Conformal_Conic_2SP cell area
  mutate(LC_pct = if_else(LC_pct > 100, 100, LC_pct)) %>% # truncate
  st_transform(crs = st_crs(NCC_1KM_TIF)) # back to Canada_Albers_WGS_1984

# LU 
# lu_albers <- lambert_1km %>%
#   filter(LU_sum > 0) %>%
#   mutate(LU_m2 = LU_sum * 900) %>% # convert pixel count to area (30m x 30m = 900m2)
#   mutate(LU_pct = as.numeric(round(((LU_m2 / Area_m2) * 100),1))) %>% # pixel area / Lambert_Conformal_Conic_2SP cell area
#   mutate(LU_pct = if_else(LU_pct > 100, 100, LU_pct)) %>% # truncate
#   st_transform(crs = st_crs(NCC_1KM_TIF)) # back to Canada_Albers_WGS_1984

# Polygon to Raster
# LC 
rasterize(
  x = vect(lc_albers), 
  y = NCC_1KM_TIF, 
  field = "LC_pct",
  filename = file.path(OUT, paste0("Forest_LC_1km_", YEAR, ".tif"))
)

# # LU 
# rasterize(
#   x = vect(lu_albers), 
#   y = NCC_1KM_TIF, 
#   field = "LC_pct",
#   filename = file.path(OUT, paste0("Forest_LU_1km_", YEAR, ".tif"))
# )

## End timer
end_time <- Sys.time()
end_time - start_time 
