# 1KM Forest Rollup

## Methods for rolling-up 30m landcover data to 1km national grid forest metric.
We recommend combining forest classes from the VCLE2 2019 Land Cover map with the CA Forest Fires (1985-2020) and CA Forest Harvest (1985-2020) datasets, and then further augmenting that with forest classes from AAFC’s LUTS 2020 map in non-forested ecoregions in the south.

This in-house forest composite follows the definition of forest established by the Food and Agriculture Organization (FAO) of the United Nations and used in State of Canada Forest Annual Report 2022 by NRCan (page 28), which considers wildfire and clearcut as forest.

### Source data includes:
1. CFS VLCE2 2019 Landcover
2. CFS CA Forest Fires (1985 - 2020)
3. CFS CA FOREST Harvest (1985 - 2020)
2. 2020 AAFC LUTS, used for the agricultural south 

### Methods
1. `preprocessing.R` scripts prep source layers into a 30m composite
2. `pixel_count_rollup.R` counts the # of 30m pixels that interscet the NCC vector grid and converts that to a proportion value



