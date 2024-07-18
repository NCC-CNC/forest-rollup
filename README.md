# Forest Habitat Metric
This repo contains the workflow for constructing forest habitat metric at a 30m and 1km scale.

### Sources
NFIS covers treed pixels in forest dominated ecosystems. AAFC covers the agricultural south.
- [NFIS](https://opendata.nfis.org/mapserver/nfis-change_eng.html) VLCE2 Land Cover (latest update, **2022**)
- [AAFC LUTS](https://open.canada.ca/data/en/dataset/7a098ea9-cc31-4d79-b326-89f6cd1fbb7d) Land Use (latest update, **2020**)

![extent](https://github.com/NCC-CNC/forest-rollup/blob/main/product_extent_figure.jpg) 

### High level methods
Products are reclassified to forest and mosaicked together. The 30m composite is rolled-up to the 1km gird using a pixel count method.
