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
# Processing time:  ~ 2.1 hours :(
#==============================================================================

library(terra)
library(gdalUtilities)

## Start timer (Run time on my machine: ~4 mins)
start_time <- Sys.time()

OUT_PREP <- "C:/Data/NAT/Habitat/Forest/Prep/AAFC"

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
VLCE2 <- rast("C:/Data/NAT/LC/NFIS/CA_forest_VLCE2_2020/CA_forest_VLCE2_2020.tif") # <--- 2020

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
  print(paste0(counter, " of ", length(LUTS_TIFS), ": ", basename(LU_TIF)))
  
  print("... projecting to Lambert")
  # I couldn't figure out a way around this without having edge effects between
  # the two different products come time to extract pixel count to 1km grid. 
  gdalUtilities::gdalwarp(
    srcfile = LU_TIF,
    dstfile = file.path(OUT_PREP, paste0("LAMBERT_",basename(LU_TIF))),
    te = te,
    t_srs = proj4_string,
    ts = ts,
    overwrite = TRUE
  )
  
  # Read-in projected AAFC LUT
  LU_LAMBERT <- rast(file.path(OUT_PREP, paste0("LAMBERT_",basename(LU_TIF))))
  
  print("... mask to VLCE2")
  LU_LAMBERT_MASK <- terra::mask(
    LU_LAMBERT, 
    VLCE2, 
    inverse = TRUE, 
    maskvalues = 0
  )
  
  print("... reclass to forest")
  m <- c(
    0, NA, 
    1, NA, 
    21, NA, 
    24, 1, 
    28, NA, 
    22, NA, 
    29, NA, 
    25, NA, 
    31, NA, 
    41, 1, 
    42, 1, 
    43, 1, 
    44, 1, 
    49, 1, 
    47, 1, 
    48, 1, 
    51, NA, 
    52, NA, 
    55, NA, 
    56, NA, 
    61, NA,  
    62, NA, 
    71, NA, 
    81, NA, 
    84, NA, 
    88, NA, 
    82, NA, 
    89, NA, 
    91, NA, 
    92, NA, 
    128, NA)
  rclmat <- matrix(m, ncol=2, byrow=TRUE)
  LU_LAMBERT_TREED <- terra::classify(
    LU_LAMBERT_MASK, 
    rclmat,
    filename = file.path(OUT_PREP, paste0("TREED_",basename(LU_TIF))),
    overwrite = TRUE, 
    datatype = "INT1U"
  )                                        
  
  # Advance counter
  counter <- counter + 1
}

## End timer
end_time <- Sys.time()
end_time - start_time
