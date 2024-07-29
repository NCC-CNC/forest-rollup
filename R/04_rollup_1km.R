#
# Author: Dan Wismer
#
# Date: July 17th, 2024
#
# Description: 1km roll-up method
#
# Inputs:  - final forest 30m layer
#          - Output folder 
#
# Outputs: - 1km forest layer
#
# Tested on R Versions: 4.4.1
# Processing time:  ~ 41 minutes
#==============================================================================

start_time <- Sys.time()
library(terra)
library(exactextractr)
library(sf)
library(dplyr)

# Inputs -----------------------------------------------------------------------

YEAR <- 2022 # <---- SET YEAR

OUT <- "C:/Data/NAT/Habitat/Forest"

FOREST_30m <- rast(file.path(OUT, paste0("Forest_LC_30m_", YEAR, ".tif")))

# Read-in national 1km raster and vector grid
NCC_1KM_TIF <- rast("C:/Data/PRZ/GRID1KM/NCC_1KM_IDX.tif")
NCC_1KM_SHP <- read_sf("C:/Data/PRZ/GRID1KM//NCC_1KM_IDX.shp")

#------------------------------------------------------------------------------

# Sum 30m treed pixels that intersect 1km national vector grid
# 30m values are all 1, therefore sum is also getting the pixel count
NCC_1KM_SHP$Forest_Sum <- exact_extract(FOREST_30m, NCC_1KM_SHP, fun = "sum") 

# Convert 30m tree pixel sum to area (ha)
Forest_1km <-  NCC_1KM_SHP %>%
  filter(Forest_Sum > 0) %>%
  mutate(Forest_Ha = ((Forest_Sum * 900) / 10000)) %>% # convert pixel count to area (30m x 30m = 900m2), divide by 10,000 to convert m2 to ha. 
  mutate(Forest_Ha = round(Forest_Ha, 2)) %>% # round to 2 decimal places
  filter(Forest_Ha > 0) # rounding brought some cells to 0

# Polygon to Raster
rasterize(
  x = vect(Forest_1km), 
  y = NCC_1KM_TIF, 
  field = "Forest_Ha",
  filename = file.path(OUT, paste0("Forest_LC_1km_", YEAR, ".tif"))
)

## End timer
end_time <- Sys.time()
end_time - start_time 
