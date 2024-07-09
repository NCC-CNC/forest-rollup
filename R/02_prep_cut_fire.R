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
# Tested on R Versions: 4.3.0
# Processing time:  ~ 19 mins
#==============================================================================

start_time <- Sys.time()
library(terra)

FIRE <- rast("C:/Data/NAT/LC/NFIS/CA_Forest_Fire_1985-2020/CA_Forest_Fire_1985-2020.tif")
CUT <- rast("C:/Data/NAT/LC/NFIS/CA_Forest_Harvest_1985-2020/CA_Forest_Harvest_1985-2020.tif")

# TREED_LC_VLCE2 <- file.path(OUT_PREP, "TREED_LC_VLCE2_2019.tif")   # <--- 2019
TREED_LC_VLCE2 <- file.path(OUT_PREP, "TREED_LC_VLCE2_2020.tif")     # <--- 2020
# TREED_LC_VLCE2 <- file.path(OUT_PREP, "TREED_LC_VLCE2_2022.tif")   # <--- 2022


# VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2019/CA_forest_VLCE2_2019.tif") # <--- 2019
VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2020/CA_forest_VLCE2_2020.tif")   # <--- 2020
# VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2022/CA_forest_VLCE2_2022.tif") # <--- 2022

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep"


# Reclassify fire to treed
m <- c(-1,1984,NA, 1985,2020,1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
fire_treed <- terra::classify(FIRE, rclmat, right=NA)
terra::writeRaster(
  fire_treed, 
  file.path(OUT_PREP, "TREED_CA_Forest_Fire_1985-2020.tif"),
  overwrite = TRUE, 
  datatype = "INT1U"
)

# Reclassify cut to treed
m <- c(-1,1984,NA, 1985,2020,1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
cut_treed <- terra::classify(CUT, rclmat, right=NA)
terra::writeRaster(
  cut_treed, 
  file.path(OUT_PREP, "TREED_CA_Forest_Harvest_1985-2020.tif"),
  overwrite = TRUE, 
  datatype = "INT1U"
)

# Mosaic tree outputs
treed_VLCE2_cut_fire <- terra::mosaic(TREED_LC_VLCE2, cut_treed, fire_treed)

# Mask out water, rock/rubble and wetland. Fire and Cut overlap these pixels.
treed_VLCE2_cut_fire_mask <- terra::mask(treed_VLCE2_cut_fire, VLCE2, maskvalues = c(20, 32, 80))
terra::writeRaster(
  treed_VLCE2_cut_fire_mask,
  file.path(OUT_PREP, "TREED_LU_VLCE2_2019.tif"), # <--- UPDATE YEAR
  overwrite = TRUE, datatype = "INT1U"
)

## End timer
end_time <- Sys.time()
end_time - start_time