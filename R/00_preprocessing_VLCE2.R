library(terra)

# Start timer (Run time on my machine: ~36 mins)
start_time <- Sys.time()

# Read-in rasters
VLCE2_2019 <- rast("C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/CA_forest_VLCE2_2019.tif")
FIRE <- rast("C:/Data/National/Landcover/NFIS/CA_Forest_Fire_1985-2020/CA_Forest_Fire_1985-2020.tif")
CUT <- rast("C:/Data/National/Landcover/NFIS/CA_Forest_Harvest_1985-2020/CA_Forest_Harvest_1985-2020.tif")

# Reclassify VLCE2 2019  ----
## 0 = NA 
## 20 = water
## 31 = snow/ice 
## 32 = rock/rubble 
## 33 = exposed/barren
## 40 = bryoids
## 50 = shrubs
## 80 = wetlands
## 81 = wetland-treed
## 100 = herbs
## 210 = coniferous
## 202 = broad leaf
## 230 = mixed wood
m <- c(0,NA, 20,NA, 31,NA, 32,NA, 33,NA, 40,NA, 50,NA, 
       80,NA, 81,1, 100,NA, 210,1, 220,1, 230,1)
rclmat <- matrix(m, ncol=2, byrow=TRUE)
VLCE2_2019_TREED <- terra::classify(VLCE2_2019, rclmat)
terra::writeRaster(VLCE2_2019_TREED, 
  "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/TREED_CA_forest_VLCE2_2019.tif",
  overwrite = TRUE, datatype = "INT1U")

# Reclassify fire to treed
m <- c(-1,1984,NA, 1985,2020,1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
FIRE_TREED <- terra::classify(FIRE, rclmat, right=NA)
terra::writeRaster(FIRE_TREED, 
  "C:/Data/National/Landcover/NFIS/CA_Forest_Fire_1985-2020/TREED_CA_Forest_Fire_1985-2020.tif",
  overwrite = TRUE, datatype = "INT1U")

# Reclassify cut to treed
m <- c(-1,1984,NA, 1985,2020,1)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
CUT_TREED <- terra::classify(CUT, rclmat, right=NA)
terra::writeRaster(CUT_TREED, 
  "C:/Data/National/Landcover/NFIS/CA_Forest_Harvest_1985-2020/TREED_CA_Forest_Harvest_1985-2020.tif",
  overwrite = TRUE, datatype = "INT1U")

# Mosaic Tree outputs
TREED_CUT_FIRE <- terra::mosaic(VLCE2_2019_TREED, CUT_TREED, FIRE_TREED)
terra::writeRaster(TREED_CUT_FIRE, 
  "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/CA_forest_VLCE2_2019_Tree_Cut_Fire.tif",
  overwrite = TRUE, datatype = "INT1U")

## End timer
end_time <- Sys.time()
end_time - start_time


