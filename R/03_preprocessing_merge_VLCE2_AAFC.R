library(terra)

# Start timer (Run time on my machine: ~2.3 hours)
start_time <- Sys.time()

# Read-in rasters
TREED_LC <- rast("C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/TREED_LC_VLCE2_2020.tif")
TREED_LU <- rast("C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/TREED_LU_VLCE2_2019.tif")
LU2020_u11 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u11/TREED_LU2020_u11_v4_2022_02.tif")
LU2020_u12 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u12/TREED_LU2020_u12_v4_2022_02.tif")
LU2020_u13 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u13/TREED_LU2020_u13_v4_2022_02.tif")
LU2020_u14 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u14/TREED_LU2020_u14_v4_2022_02.tif")
LU2020_u17 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u17/TREED_LU2020_u17_v4_2022_02.tif")
LU2020_u18 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u18/TREED_LU2020_u18_v4_2022_02.tif")
LU2020_u19 <- rast("C:/Data/National/Landcover/AAFC/LUTS_2020/LU2020_u19/TREED_LU2020_u19_v4_2022_02.tif")
OUTPUT_LC <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LC_COMPOSITE_30M.tif"
OUTPUT_LU <- "C:/Data/National/Landcover/NFIS/CA_forest_VLCE2_2019/FOREST_LU_COMPOSITE_30M.tif"

# Forest cover ---- 
rlist <- list(TREED_LC, LU2020_u11, LU2020_u12, LU2020_u13, LU2020_u14,
              LU2020_u17, LU2020_u18, LU2020_u19)

rsrc <- sprc(rlist) 

# Mosaic to new raster 
FOREST_LC_COMPOSITE_30M <- terra::mosaic(rsrc)

writeRaster(FOREST_LC_COMPOSITE_30M,
            filename = OUTPUT_LC,
            overwrite = TRUE, datatype = "INT1U") 


# Forest use ---- 
rlist <- list(TREED_LU, LU2020_u11, LU2020_u12, LU2020_u13, LU2020_u14,
  LU2020_u17, LU2020_u18, LU2020_u19)

rsrc <- sprc(rlist) 

# Mosaic to new raster 
FOREST_LU_COMPOSITE_30M <- terra::mosaic(rsrc)

writeRaster(FOREST_LU_COMPOSITE_30M,
  filename = OUTPUT_LU,
  overwrite = TRUE, datatype = "INT1U") 

## End timer
end_time <- Sys.time()
end_time - start_time