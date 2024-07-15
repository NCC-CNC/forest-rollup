#
# Author: Dan Wismer
#
# Date: July 11th, 2024
#
# Description: mosaics treed VLCE2, treed cut and treed fire
#
# Inputs:  - Prepped wildfires (02_prep_cut_fire.R)
#          - Prepped cutblocks (02_prep_cut_fire.R)
#          - Prepped VLCE2 Treed LC (01_prep_VLCE2.R)
#          - VLCE2 landcover
#          - Output folder to save prep data
#
# Outputs: - VLCE2 forest land use raster (1, NA)

# Notes:
# if processing VLCE2 2019, mask out 2020 wildfires and cutblocks
#
# Tested on R Versions: 4.4.1
# Processing time:  ~ 2.1 hours :(
#==============================================================================

start_time <- Sys.time()
library(terra)
library(gdalUtilities)

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/NFIS"

# VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2019/CA_forest_VLCE2_2019.tif") # <--- 2019
VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2020/CA_forest_VLCE2_2020.tif")   # <--- 2020
# VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2022/CA_forest_VLCE2_2022.tif") # <--- 2022

# TREED_LC_VLCE2 <- rast(file.path(OUT_PREP, "TREED_LC_VLCE2_2019.tif"))   # <--- 2019
TREED_LC_VLCE2 <- file.path(OUT_PREP, "TREED_LC_VLCE2_2020.tif")   # <--- 2020
# TREED_LC_VLCE2 <- rast(file.path(OUT_PREP, "TREED_LC_VLCE2_2022.tif"))   # <--- 2022

CUT_TREED <- file.path(OUT_PREP, "TREED_CA_Forest_Harvest_1985-2020.tif")    # <--- 2020
FIRE_TREED <- file.path(OUT_PREP, "TREED_CA_Forest_Fire_1985-2020.tif")     # <--- 2020

# Mosaic treed outputs
gdalUtilities::gdalbuildvrt(
  gdalfile = c(CUT_TREED, FIRE_TREED,  TREED_LC_VLCE2),
  output.vrt = file.path(OUT_PREP, "TREED_LU_VLCE2_2020_NO_MASK.vrt"),
  vrtnodata = 255,
  srcnodata = 255
)

gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT_PREP, "TREED_LU_VLCE2_2020_NO_MASK.vrt"),
  dst_dataset = file.path(OUT_PREP, "TREED_LU_VLCE2_2020_NO_MASK.tif"),
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

# Mask out water, rock/rubble and wetland. Fire and Cut overlap these pixels.
terra::mask(
  x = rast(file.path(OUT_PREP, "TREED_LU_VLCE2_2020_NO_MASK.tif")),
  mask = VLCE2,
  maskvalues = c(20, 32, 80),
  filename = file.path(OUT_PREP, "TREED_LU_VLCE2_2020.tif"),
  overwrite = TRUE,
  datatype = "INT1U" # 8 bit unsigned 
)

## End timer
end_time <- Sys.time()
end_time - start_time
