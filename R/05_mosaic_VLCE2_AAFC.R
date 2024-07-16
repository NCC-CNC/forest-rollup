#
# Author: Dan Wismer
#
# Date: July 15th, 2024
#
# Description: mosaics prepped NFIS and AAFC products
#
# Inputs:  - Prepped VLCE2
#          - Preped AAFC
#          - Output folder to save prep data
#
# Outputs: - Forest LC and LU, 30m
#
# Tested on R Versions: 4.4.1
# Processing time:  ~ 4 minutes
#==============================================================================

start_time <- Sys.time()
library(gdalUtilities)
library(terra)

# Inputs -----------------------------------------------------------------------

NFIS_YEAR <- 2020 # <---- SET YEAR
NFIS_YEAR <- paste0("_", NFIS_YEAR) 

AAFC_YEAR <- 2020 # <---- SET YEAR
AAFC_YEAR <- paste0("_", AAFC_YEAR) 

OUT <- "C:/Data/NAT/Habitat/Forest"

# NFIS Land Cover
VLCE2_LC <- file.path(OUT, "Prep/NFIS", NFIS_YEAR, "TREED_LC_VLCE2.tif")            

# NFIS Land Use
VLCE2_LU <- file.path(OUT, "Prep/NFIS", NFIS_YEAR, "TREED_LU_VLCE2.tif")  

# AAFC Land Use
AAFC <- file.path(OUT, "Prep/AAFC", AAFC_YEAR, "AAFC_TREED.tif")            
#-------------------------------------------------------------------------------

# Mosaic for Land Cover
gdalUtilities::gdalbuildvrt(
  gdalfile = c(VLCE2_LC, AAFC),
  output.vrt = file.path(OUT, paste0("Prep/Forest_LC_30m", NFIS_YEAR, ".vrt")), 
  vrtnodata = 255,
  srcnodata = 255
)
# Translate .vrt to .tif
gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT, paste0("Prep/Forest_LC_30m", NFIS_YEAR, ".vrt")), 
  dst_dataset = file.path(OUT, paste0("Prep/Forest_LC_30m", NFIS_YEAR, ".tif")),
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

# Need to do this so values are 1-1 when pulled into Pro.
writeRaster(
  x = rast(file.path(OUT, paste0("Prep/Forest_LC_30m", NFIS_YEAR, ".tif"))), 
  filename = file.path(OUT, paste0("Forest_LC_30m", NFIS_YEAR, ".tif")),     
  overwrite = TRUE,
  datatype = "INT1U" # 8 bit unsigned 
)

# Mosaic for Land Use
gdalUtilities::gdalbuildvrt(
  gdalfile = c(VLCE2_LU, AAFC),
  output.vrt = file.path(OUT, paste0("Prep/Forest_LU_30m", NFIS_YEAR, ".vrt")),
  vrtnodata = 255,
  srcnodata = 255
)
# Translate .vrt to .tif
gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT, paste0("Prep/Forest_LU_30m", NFIS_YEAR, ".vrt")), 
  dst_dataset = file.path(OUT, paste0("Prep/Forest_LU_30m", NFIS_YEAR, ".tif")), 
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

# Need to do this so values are 1-1 when pulled into Pro.
writeRaster(
  x = rast(file.path(OUT, paste0("Prep/Forest_LU_30m", NFIS_YEAR, ".tif"))),
  filename = file.path(OUT, paste0("Forest_LU_30m", NFIS_YEAR, ".tif")),
  overwrite = TRUE,
  datatype = "INT1U" # 8 bit unsigned 
)

## End timer
end_time <- Sys.time()
end_time - start_time
