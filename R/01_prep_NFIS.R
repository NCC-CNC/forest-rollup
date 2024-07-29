#
# Author: Dan Wismer
#
# Date: July 26th, 2024
#
# Description: Reclassifies VLCE2 Land cover to forest (treed) and project from
#              Lambert_Conformal_Conic_2SP to Canada_Albers_WGS_1984
#
# Inputs:  - VLCE2 raster
#          - Output folder to save prep data
#
# Outputs: - Treed raster (1, NA)
#
# Notes:
# VLCE2 Classes 
#  0 = NA 
# 20 = water
# 31 = snow/ice 
# 32 = rock/rubble 
# 33 = exposed/barren
# 40 = bryoids
# 50 = shrubs
# 80 = wetlands
# 81 = wetland-treed
# 100 = herbs
# 210 = coniferous
# 202 = broad leaf
# 230 = mixed wood
#
#
# Tested on R Versions: 4.4.1
# Processing time:  ~ 14 mins 
#==============================================================================

start_time <- Sys.time()
library(terra)
library(gdalUtilities)

# Inputs -----------------------------------------------------------------------

NFIS_YEAR <- 2022 # <---- SET YEAR
NFIS_YEAR <- paste0("_", NFIS_YEAR) 
NFIS_SOURCE <- file.path("C:/Data/NAT/LC/NFIS", paste0("CA_forest_VLCE2",NFIS_YEAR), paste0("CA_forest_VLCE2",NFIS_YEAR, ".tif")) 
PROJECTION <- rast("C:/Data/PRZ/GRID1KM/NCC_1KM_IDX.tif") # needs this to get projection string

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/NFIS" 
#-------------------------------------------------------------------------------

## get spatial properties for gdal warp
proj4_string <- as.character(terra::crs(PROJECTION), "proj4") # projection string

# Project from Lambert_Conformal_Conic_2SP to Canada_Albers_WGS_1984
# Had to project before reclass, becuase I need this layer to mask AAFC
gdalUtilities::gdalwarp(
  srcfile = NFIS_SOURCE,
  dstfile = file.path(OUT_PREP, NFIS_YEAR, "NFIS_ALBERS.tif"),
  t_srs = proj4_string, # Canada_Albers_WGS_1984
  dstnodata = "255", # no data
  ot = "Byte", # data type
  r = "near", # resample method
  tr = c(30, 30), # set resolution,
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256"), # compression and tiling
  overwrite = TRUE
)  


# Reclassify VLCE2 to treed  
m <- c(
  0,   NA, 
  20,  NA, 
  31,  NA, 
  32,  NA, 
  33,  NA, 
  40,  NA, 
  50,  NA, 
  80,  NA, 
  81,  1,   # Wetland-treed
  100, NA,
  210, 1,  # Coniferous
  220, 1,  # Broad leaf
  230, 1   # Mixed wood
)
rclmat <- matrix(m, ncol = 2, byrow = TRUE)

terra::classify(
  x = rast(file.path(OUT_PREP, NFIS_YEAR, "NFIS_ALBERS.tif")), 
  rcl = rclmat,
  filename = file.path(OUT_PREP, NFIS_YEAR, "NFIS_TREED.tif"), 
  overwrite = TRUE, 
  datatype = "INT1U", # 8 bit unsigned
  NAflag = 255
)

## End timer
end_time <- Sys.time()
end_time - start_time
