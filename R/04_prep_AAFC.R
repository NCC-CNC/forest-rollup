#
# Author: Dan Wismer
#
# Date: July 11th, 2024
#
# Description: prep AAFC LUT to forest.
#
# Inputs:  - Folder to AAFC LUT .tifs
#          - List of tile names to backfill
#          - VLCE2 landcover
#          - Output folder to save prep data
#
# Outputs: - AFFC Treed forest  raster (1, NA)
#
# Notes: AAFC LUT classes
## 21: Settlement
## 22: High Reflectance Settlement
## 24: Settlement Forest
## 25: Roads
## 28: Vegetated Settlement
## 29: Very High Reflectance Settlement
## 31: Water
## 41: Forest
## 42: Forest Wetland
## 43: Forest Regenerating after Harvest <20 years
## 44: Forest Wetland Regenerating after Harvest <20 years
## 47: Forest Regenerating after Harvest 20-29 years
## 48: Forest Wetland Regenerating after Harvest 20-29 years
## 49: Forest Regenerating after Fire <20 years
## 51: Cropland
## 52: Annual Cropland
## 55: Land Converted to Cropland
## 56: Land Converted to Annual Cropland
## 61: Grassland Managed
## 62: Grassland Unmanaged
## 71: Wetland
## 81: Newly-Detected Settlement <10 years
## 82: Newly-Detected Very High Reflectance Settlement <10 years
## 84: Newly-Detected Settlement Forest <10 years
## 88: Newly-Detected Vegetated Settlement <10 years
## 89: Newly-Detected Very High Reflectance Settlement <10 years
## 91: Other Land
## 92: Snow and ice

# Tested on R Versions: 4.4.1
# Processing time:  ~ 15.5 mins
#==============================================================================

library(terra)
library(gdalUtilities)

## Start timer (Run time on my machine: ~4 mins)
start_time <- Sys.time()

# Inputs -----------------------------------------------------------------------

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/AAFC"

VLCE2  <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2020/CA_forest_VLCE2_2020.tif") 
#-------------------------------------------------------------------------------

AAFC_LUTS <- "C:/Data/NAT/LC/AAFC/LUTS_2020" # <---- 2020
BACKFILL_TILES <- c(
  "LU2020_u11", 
  "LU2020_u12", 
  "LU2020_u13", 
  "LU2020_u14", 
  "LU2020_u17", 
  "LU2020_u18", 
  "LU2020_u19"
)

LUTS_TIFS <- list.files(
  file.path(AAFC_LUTS, BACKFILL_TILES), 
  pattern='.tif$', 
  full.names = TRUE, 
  recursive = TRUE
)

## get spatial properties for gdal warp
proj4_string <- as.character(terra::crs(VLCE2), "proj4") # projection string
bbox <- terra::ext(VLCE2) # bounding box
te <- c(bbox[1], bbox[3], bbox[2], bbox[4]) # xmin, ymin, xmax, ymax
ts <- c(terra::ncol(VLCE2), terra::nrow(VLCE2)) # columns/rows

counter <- 1
for (LU_TIF in LUTS_TIFS) {
  print(paste0(basename(LU_TIF), " (", counter, "/", length(LUTS_TIFS), ")"))
  
  print("... Reclass to forest")
  m <- c(
    0, NA, 1, NA, 21, NA, 22, NA, 
    24, 1, # Settlement Forest ?
    25, NA, 28, NA,  29, NA,  31, NA, 
    41, 1, # Forest
    42, 1, # Forest Wetland
    43, 1, # Forest Regenerating after Harvest <20 years
    44, 1, # Forest Wetland Regenerating after Harvest <20 years
    47, 1, # Forest Regenerating after Harvest 20-29 years
    48, 1, # Forest Wetland Regenerating after Harvest 20-29 years
    49, 1, # Forest Regenerating after Fire <20 years
    51, NA, 52, NA, 55, NA, 56, NA, 61, NA,  62, NA, 71, NA, 81, NA, 
    84, NA, # Newly-Detected Settlement Forest <10 years ? 
    88, NA, 82, NA, 89, NA, 91, NA, 92, NA, 
    128, NA
  )
  rclmat <- matrix(m, ncol=2, byrow=TRUE)
  terra::classify(
    x = rast(LU_TIF), 
    rcl = rclmat,
    filename = file.path(OUT_PREP, paste0("FOREST_",basename(LU_TIF))),
    overwrite = TRUE, 
    datatype = "INT1U"
  )                                        
  
  print("... project to Lambert_Conformal_Conic_2SP and algin")
  gdalUtilities::gdalwarp(
    srcfile = file.path(OUT_PREP, paste0("FOREST_",basename(LU_TIF))),
    dstfile = file.path(OUT_PREP, paste0("LAMBERT_FOREST_",basename(LU_TIF))),
    t_srs = proj4_string, # Lambert_Conformal_Conic_2SP
    dstnodata = "255", # no data
    ot = "Byte", # data type
    r = "near", # resample method
    tr = c(30, 30), # set resolution,
    co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256"), # compression and tiling
    overwrite = TRUE,
    te = te, # xmin, ymin, xmax, ymax
    ts = ts # column /rows
  )  
  
  # Advance counter
  counter <- counter + 1
}

# Merge AAFC LAMBERT_FOREST_
print("... Mosaic treed rasters")
treed_tifs <- list.files(OUT_PREP, pattern = "^LAMBERT.*\\.tif$", full.names = TRUE)

# build virtual raster
gdalUtilities::gdalbuildvrt(
  gdalfile = treed_tifs, 
  output.vrt = file.path(OUT_PREP, "AAFC_VRT.vrt"),
  vrtnodata = 255,
  srcnodata = 255
)

# translate virtual raster to tif
gdalUtilities::gdal_translate(
  src_dataset = file.path(OUT_PREP, "AAFC_VRT.vrt"),
  dst_dataset = file.path(OUT_PREP, "AAFC_VRT.tif"),
  of = "GTiff",
  a_nodata = "255", # no data
  ot = "Byte", # data type
  co = c("COMPRESS=LZW", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256") # compression and tiling
)

# Mask to VLCE2
terra::mask(
  x = rast(file.path(OUT_PREP, "AAFC_VRT.tif")),
  mask = VLCE2,
  inverse = TRUE,
  maskvalues = 0,
  filename = file.path(OUT_PREP, "AAFC_TREED_2020.tif"),
  overwrite = TRUE,
  datatype = "INT1U" # 8 bit unsigned 
)

## End timer
end_time <- Sys.time()
end_time - start_time
