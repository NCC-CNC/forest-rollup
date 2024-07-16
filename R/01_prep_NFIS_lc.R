#
# Author: Dan Wismer
#
# Date: July 9th, 2024
#
# Description: Reclassifies VLCE2 Land cover to forest (treed)
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
# Processing time:  ~ 5 mins 
#==============================================================================

start_time <- Sys.time()
library(terra)

# Inputs -----------------------------------------------------------------------

NFIS_YEAR <- 2022 # <---- SET YEAR
NFIS_YEAR <- paste0("_", NFIS_YEAR) 
RAW_DATA <- "C:/Data/NAT/LC/NFIS" # <--- location of raw data

# Read-in NFIS VCLE2 Land Cover
VLCE2 <- rast(
  file.path(
    RAW_DATA, 
    paste0("CA_forest_VLCE2", NFIS_YEAR), 
    paste0("CA_forest_VLCE2", NFIS_YEAR, ".tif")
  )
)
  
OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/NFIS" 
#-------------------------------------------------------------------------------

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
  x = VLCE2, 
  rcl = rclmat,
  filename = file.path(OUT_PREP, NFIS_YEAR, "TREED_LC_VLCE2.tif"), 
  overwrite = TRUE, 
  datatype = "INT1U" # 8 bit unsigned 
)

## End timer
end_time <- Sys.time()
end_time - start_time
