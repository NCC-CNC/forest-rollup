library(terra)

# Start timer (Run time on my machine: ~2.3 hours)
start_time <- Sys.time()

# Read-in rasters
VLCE2_2019 <- rast("C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/CA_forest_VLCE2_2019_Tree_Cut_Fire.tif")
LU2020_u11 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u11/TREED_LU2020_u11_v4_2022_02.tif")
LU2020_u12 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u12/TREED_LU2020_u12_v4_2022_02.tif")
LU2020_u13 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u13/TREED_LU2020_u13_v4_2022_02.tif")
LU2020_u14 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u14/TREED_LU2020_u14_v4_2022_02.tif")
LU2020_u17 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u17/TREED_LU2020_u17_v4_2022_02.tif")
LU2020_u18 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u18/TREED_LU2020_u18_v4_2022_02.tif")
LU2020_u19 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u19/TREED_LU2020_u19_v4_2022_02.tif")
OUTPUT <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/COMPSITE_VLCE2_2019_WF_CB_AAFC_LUTS_2020.tif"

rlist <- list(VLCE2_2019, LU2020_u11, LU2020_u12, LU2020_u13, LU2020_u14,
  LU2020_u17, LU2020_u18, LU2020_u19)

rsrc <- sprc(rlist) 

# Mosaic to new raster 
COMPSITE_VLCE2_2019_AAFC_LUTS_2020 <- terra::mosaic(rsrc)

writeRaster(COMPSITE_VLCE2_2019_AAFC_LUTS_2020,
  filename = OUTPUT,
  overwrite = TRUE, datatype = "INT1U") 

## End timer
end_time <- Sys.time()
end_time - start_time