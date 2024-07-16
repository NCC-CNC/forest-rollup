#
# Author: Dan Wismer
#
# Date: July 9th, 2024
#
# Description: Reclassifies cut and fire to forest (treed)
#
# Inputs:  - wildfires
#          - cutblocks
#          - VLCE2 landcover
#          - Prepped VLCE2 Treed LC (01_prep_VLCE2.R)
#          - Output folder to save prep data
#
# Outputs: - Treed cut and fire rasters (1, NA)
#          - VLCE2 forest land use raster (1, NA)
#
# Notes:
# if processing VLCE2 2019, mask out 2020 wildfires and cutblocks
#
# Tested on R Versions: 4.4.1
# Processing time:  ~ 9 mins
#==============================================================================

start_time <- Sys.time()
library(terra)

# Inputs -----------------------------------------------------------------------

NFIS_YEAR <- 2020 # <---- SET YEAR (options are 1985 - 2020)
RAW_DATA <- "C:/Data/NAT/LC/NFIS" # <--- location of raw data

# Raw wildfires
FIRE <- rast(
  file.path(RAW_DATA, "CA_Forest_Fire_1985-2020","CA_Forest_Fire_1985-2020.tif")
)

# Raw cutblocks
CUT <- rast(
  file.path(RAW_DATA, "CA_Forest_Harvest_1985-2020", "CA_Forest_Harvest_1985-2020.tif")
)

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/NFIS"
#-------------------------------------------------------------------------------

# Reclassify fire to treed
m <- c(-Inf,1984,NA, 1985,NFIS_YEAR,1, NFIS_YEAR+1,Inf,NA) 
rclmat <- matrix(m, ncol=3, byrow=TRUE)
terra::classify(
  x = FIRE, 
  rcl = rclmat, 
  right = NA,
  filename = file.path(OUT_PREP, paste0("_", NFIS_YEAR), "TREED_CA_Forest_Fire.tif"),
  overwrite = TRUE,
  datatype = "INT1U"
)

# Reclassify cut to treed
m <- c(-Inf,1984,NA, 1985,NFIS_YEAR,1, NFIS_YEAR+1,Inf,NA) 
rclmat <- matrix(m, ncol=3, byrow=TRUE)
terra::classify(
  x = CUT, 
  rcl = rclmat, 
  right = NA,
  filename = file.path(OUT_PREP, paste0("_", NFIS_YEAR), "TREED_CA_Forest_Harvest.tif"),
  overwrite = TRUE, 
  datatype = "INT1U"
)

## End timer
end_time <- Sys.time()
end_time - start_time
