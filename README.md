# rollup

## Methods for rolling-up 30m landcover data to 1km national grid forest metric.
The goal is to create a final 1km roll-up product that best reflects the 30m source data.

1. `00_preprocessing.R` preps AOI and subsets land cover to BC for testing
2. `01_pixel_count.R` counts the # of 30m pixels that interscet the AOI 1km vector grid and converts that to a proportion value

<b>Note</b>: 
1. It is best to avoid re-projecting and resmapling rasters as the source pixel configuration changes.
2. The national 1km vector grid projection is `Canada_Albers_WGS_1984` and each grid cell is exactly 100 ha
3. When projecting the national 1km vector grid, re-calcuate area and use that new area to convert count to proportion. For example, re-projecting to `Lambert_Conformal_Conic_2SP` (CRS of CA_forest_VLCE2_2019.tif)
changed the cell area to ~95 ha, where each cell has slightly different area.

