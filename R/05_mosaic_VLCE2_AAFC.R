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

library(gdalUtilities)

# Start timer
start_time <- Sys.time()

# Inputs -----------------------------------------------------------------------

OUT <- "C:/Data/NAT/Habitat/Forest"

# NFIS Land Cover
# VLCE2 <- file.path(OUT, "NFIS/TREED_LC_VLCE2_2019.tif")            # <--- 2019
VLCE2_LC <- file.path(OUT, "Prep/NFIS/TREED_LC_VLCE2_2020.tif")      # <--- 2020
# VLCE2 <- file.path(OUT, "/FIS/TREED_LC_VLCE2_2022.tif")            # <--- 2022

# NFIS Land Use
# VLCE2 <- file.path(OUT, "NFIS/TREED_LU_VLCE2_2019.tif")            # <--- 2019
VLCE2_LU <- file.path(OUT, "Prep/NFIS/TREED_LU_VLCE2_2020.tif")      # <--- 2020
# VLCE2 <- file.path(OUT, "NFIS/TREED_LU_VLCE2_2022.tif")            # <--- 2022

# AAFC Land Cover
AAFC <- file.path(OUT, "Prep/AAFC/AAFC_TREED_2020.tif")              # <--- 2020
#-------------------------------------------------------------------------------

# Mosaic for Land Cover
gdalUtilities::gdalbuildvrt(
  gdalfile = c(VLCE2_LC, AAFC),
  output.vrt = file.path(OUT, "Prep/Forest_LC_30m_2020.vrt"),
  vrtnodata = 255,
  srcnodata = 255
)
# Translate .vrt to .tif
gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT, "Prep/Forest_LC_30m_2020.vrt"),
  dst_dataset = file.path(OUT, "Forest_LC_30m_2020.tif"),
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

# Mosaic for Land Use
gdalUtilities::gdalbuildvrt(
  gdalfile = c(VLCE2_LU, AAFC),
  output.vrt = file.path(OUT, "Prep/Forest_LU_30m_2020.vrt"),
  vrtnodata = 255,
  srcnodata = 255
)
# Translate .vrt to .tif
gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT, "Prep/Forest_LU_30m_2020.vrt"),
  dst_dataset = file.path(OUT, "Forest_LU_30m_2020.tif"),
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

## End timer
end_time <- Sys.time()
end_time - start_time
