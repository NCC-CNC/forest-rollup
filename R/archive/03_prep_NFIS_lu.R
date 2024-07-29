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
# Processing time:  ~ 8.5 minutes
#==============================================================================

start_time <- Sys.time()
library(terra)
library(gdalUtilities)

# Inputs -----------------------------------------------------------------------

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/NFIS"

NFIS_YEAR <- 2022 # <---- SET YEAR
NFIS_YEAR <- paste0("_", NFIS_YEAR)

CUT_FIRE_YEAR <- 2020 # <---- SET YEAR (options, 2019 and 2020)
CUT_FIRE_YEAR <- paste0("_", CUT_FIRE_YEAR) 

RAW_DATA <- "C:/Data/NAT/LC/NFIS" # <--- location of raw data

# Read-in NFIS VCLE2 Land Cover
VLCE2 <- rast(
  file.path(
    RAW_DATA, 
    paste0("CA_forest_VLCE2", NFIS_YEAR), 
    paste0("CA_forest_VLCE2", NFIS_YEAR, ".tif")
  )
)

TREED_LC_VLCE2 <- file.path(OUT_PREP, NFIS_YEAR, "TREED_LC_VLCE2.tif")         

CUT_TREED <- file.path(OUT_PREP, CUT_FIRE_YEAR, "TREED_CA_Forest_Harvest.tif")       

FIRE_TREED <- file.path(OUT_PREP, CUT_FIRE_YEAR, "TREED_CA_Forest_Fire.tif")     
#-------------------------------------------------------------------------------

# Mosaic to create Forest Land Use
gdalUtilities::gdalbuildvrt(
  gdalfile = c(CUT_TREED, FIRE_TREED, TREED_LC_VLCE2),
  output.vrt = file.path(OUT_PREP, NFIS_YEAR, "TREED_LU_VLCE2_NO_MASK.vrt"), 
  vrtnodata = 255,
  srcnodata = 255
)
# Translate .vrt to .tif
gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT_PREP, NFIS_YEAR, "TREED_LU_VLCE2_NO_MASK.vrt"), 
  dst_dataset = file.path(OUT_PREP, NFIS_YEAR, "TREED_LU_VLCE2_NO_MASK.tif"), 
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

# Mask out water, rock/rubble and wetland; 
# Fire and Cut overlap these pixels.
terra::mask(
  x = rast(file.path(OUT_PREP, NFIS_YEAR, "TREED_LU_VLCE2_NO_MASK.tif")), 
  mask = VLCE2,
  maskvalues = c(20, 32, 80),
  filename = file.path(OUT_PREP, NFIS_YEAR, "TREED_LU_VLCE2.tif"),
  overwrite = TRUE,
  datatype = "INT1U" # 8 bit unsigned 
)

## End timer
end_time <- Sys.time()
end_time - start_time
