library(terra)
library(raster)
library(sp)
library(gdalUtilities)

## Start timer (Run time on my machine: ~4 mins)
start_time <- Sys.time()

AAFC_LUTS_2020_FOLDER <- "C:/Data/National/Landcover/AAFC/LUTS_2020"
BACKFILL_TILES <- c("LU2020_u11", "LU2020_u12", "LU2020_u13", "LU2020_u14", "LU2020_u17", "LU2020_u18", "LU2020_u19")
VLCE2_2019 <- raster("C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/CA_forest_VLCE2_2019.tif")

LUTS_TIFS <- list.files(file.path(AAFC_LUTS_2020_FOLDER, BACKFILL_TILES), 
  pattern='.tif$', full.names = TRUE, recursive = TRUE)

# GDAL WARP Params
### get spatial properties of ncc grid
proj4_string <- sp::proj4string(VLCE2_2019) # projection string
bbox <- raster::bbox(VLCE2_2019) # bounding box
te <- c(bbox[1,1], bbox[2,1], bbox[1,2], bbox[2,2]) # xmin, ymin, xmax, ymax
ts <- c(raster::ncol(VLCE2_2019), raster::nrow(VLCE2_2019)) # columns/rows

counter <- 1
for (LU_TIF in LUTS_TIFS[1]) {

  print(paste0(counter, " of ", length(LUTS_TIFS), ": ", basename(LU_TIF)))
  
  print("... projecting to Lambert")
  # I couldn't figure out a way around this without having edge effects between
  # the two different products come time to extract pixel count to 1km grid. 
  gdalUtilities::gdalwarp(
    srcfile = LU_TIF,
    dstfile = file.path(dirname(LU_TIF), paste0("LAMBERT_",basename(LU_TIF))),
    te = te,
    t_srs = proj4_string,
    ts = ts,
    overwrite = TRUE)
  
  # Read-in projected AAFC LUT
  LU_LAMBERT <- rast(file.path(dirname(LU_TIF), paste0("LAMBERT_",basename(LU_TIF))))
  
  print("... mask to VLCE2_2019")
  LU_LAMBERT_MASK <- terra::mask(LU_LAMBERT, rast(VLCE2_2019), 
    inverse = TRUE, maskvalues = 0)
  
  print("... reclass to forest")
  m <- c(0,NA, 1,NA, 21,NA, 24,1, 28,NA, 22,NA, 29,NA, 25,NA, 31,NA, 
         41,1, 42,1, 43,1, 44,1, 49,1, 47,1, 48,1, 51,NA, 52,NA, 55,NA, 
         56,NA, 61,NA,  62,NA, 71,NA, 81,NA, 84,NA, 88,NA, 82,NA, 89,NA, 
         91,NA, 92,NA, 128,NA)
  rclmat <- matrix(m, ncol=2, byrow=TRUE)
  LU_LAMBERT_TREED <- terra::classify(LU_LAMBERT_MASK, rclmat,
    filename = file.path(dirname(LU_TIF), paste0("TREED_",basename(LU_TIF))),
    overwrite = TRUE, datatype = "INT1U")                                        
  
  # Advance counter
  counter <- counter + 1
  
}

## End timer
end_time <- Sys.time()
end_time - start_time


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


