# Latitudinal macrofauna diversity along the Mexico-U.S. Atlantic coast

This repository contains the data and supporting files associated with the manuscript:

**Latitudinal variation in benthic invertebrate macrofauna diversity along the Mexico-U.S. Atlantic Coast**

The dataset compiles occurrence records of shallow-water benthic invertebrate macrofauna along the Mexico-U.S. Atlantic coast, from Quintana Roo, Mexico, to Maine, USA, within the intertidal and shallow subtidal zone from 0 to 20 m depth.

## Dataset overview

The final analytical dataset includes 136,590 retained occurrence records, comprising 134,853 records from OBIS and 1,737 records from field surveys. The dataset includes 458 species distributed across 11 classes, 39 orders, and 121 families.

Occurrence records were used to evaluate site-level occurrence-based richness, ecoregion-scale composition, and beta diversity across seven Marine Ecoregions of the World along the study domain.

## Environmental data

Environmental predictors include sea surface temperature, chlorophyll concentration, particulate organic carbon, sea surface salinity, and depth.

Sea surface temperature, chlorophyll concentration, and particulate organic carbon were extracted from 2021 annual Level 3 Aqua MODIS products at 4 km spatial resolution. These layers were used as a recent spatial environmental baseline and should not be interpreted as year-specific environmental reconstructions for each historical occurrence record.

Depth and sea surface salinity were obtained from record metadata, following the structure used in the analytical dataset.

## Repository contents

```text
data/
  Data tables used in the analyses.

scripts/
  R scripts used to generate the analyses.

README.md
  Repository description and usage notes.

CITATION.cff
  Citation information for this repository.
