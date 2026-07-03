# Latitudinal macrofauna diversity along the Mexico-U.S. Atlantic coast

This repository contains the occurrence-based dataset, supplementary analysis files, environmental layers, and R analysis script associated with the manuscript **“Latitudinal variation in benthic invertebrate macrofauna diversity along the Mexico-U.S. Atlantic Coast.”**

The article examines broad-scale latitudinal patterns in shallow-water benthic invertebrate macrofauna diversity along the Mexico-U.S. Atlantic coast. It uses occurrence records, environmental covariates, Random Forest models, holdout validation, and ecoregion-scale comparisons to evaluate spatial variation in observed macrofaunal richness and composition.

The dataset compiles shallow-water benthic invertebrate macrofauna occurrence records along the Mexico-U.S. Atlantic coast, from Quintana Roo, Mexico, to Maine, USA, within the intertidal and shallow subtidal zone from 0 to 20 m depth.

The final analytical dataset includes 136,590 retained occurrence records, comprising 134,853 records from OBIS and 1,737 records from field surveys. The dataset includes 458 species distributed across 11 classes, 39 orders, and 121 families.

The repository also includes supplementary analysis files and 2021 annual Aqua MODIS Level-3 environmental layers used to extract spatial covariates for the study area. The supplementary files document the occurrence-based analytical dataset, site-level richness structure, sampling-effort summaries, environmental data, Random Forest modelling outputs, holdout validation, and ecoregion-scale beta-diversity analyses. The NetCDF environmental layers include chlorophyll-a concentration, particulate organic carbon, and sea surface temperature. Level-3 mapped products contain derived geophysical variables on a regular spatial grid, making them suitable for extracting environmental values at occurrence coordinates.

The data and script support broad-scale analyses of occurrence-based site richness, environmental associations, Random Forest models, holdout validation, and ecoregion-scale beta diversity across seven Marine Ecoregions of the World.

## File contents

```text
data/
  data_OBIS_under25MB.xlsx
    Occurrence-based analytical dataset used for the macrofauna diversity analyses.

  S1.xlsx
    Supplementary analysis file containing occurrence quality-control outputs, species-by-site structure, site occupancy, site-level alpha richness, OBIS sampling effort by site, latitudinal richness summaries, and quality-control summary tables.

  S2.xlsx
    Supplementary analysis file containing site-level environmental data, occurrence-environment tables, Random Forest input data, model tuning outputs, model performance metrics, observed-versus-predicted richness tables, variable-importance outputs, and holdout validation results.

  S3.xlsx
    Supplementary analysis file containing site-to-ecoregion assignments, ecoregion-level incidence matrices, ecoregion presence-absence data, multisite beta-diversity results, pairwise Sørensen dissimilarity, turnover and nestedness components, and ecoregion-level gamma richness.

  AQUA_MODIS.20210101_20211231.L3m.YR.CHL.x_chlor_a.nc
    2021 annual Aqua MODIS Level-3 mapped chlorophyll-a layer.
    Variable: chlor_a.
    Units: mg m^-3.

  AQUA_MODIS.20210101_20211231.L3m.YR.POC.x_poc.nc
    2021 annual Aqua MODIS Level-3 mapped particulate organic carbon layer.
    Variable: poc.
    Units: mg m^-3.

  AQUA_MODIS.20210101_20211231.L3m.YR.SST.x_sst.nc
    2021 annual Aqua MODIS Level-3 mapped sea surface temperature layer.
    Variable: sst.
    Units: degree_C.

scripts/
  analysis_MEPS_macrofauna.R
    R script used to reproduce the data processing and statistical analyses, including occurrence-based richness analyses, environmental associations, Random Forest models, holdout validation, and ecoregion-scale beta-diversity analyses.

README.md
  Repository description and usage notes.

CITATION.cff
  Citation information for this repository.
