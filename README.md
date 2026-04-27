# Latitudinal macrofauna diversity along the Mexico-U.S. Atlantic coast

This repository contains the data-processing workflow, analysis scripts, and processed tables used for the manuscript:

**Latitudinal variation in benthic macrofauna diversity along the Mexico-U.S. Atlantic Coast**

The repository was created to make the analyses reproducible and to document how open occurrence records, field-survey records, environmental predictors, Random Forest models, and beta-diversity analyses were processed.

Repository: https://github.com/jduarteg182/latitudinal-macrofauna-atlantic-coast

## Manuscript status

This repository accompanies a manuscript under revision for *Marine Ecology Progress Series*. The code and processed files are provided to support transparency and reproducibility during peer review and publication.

## Overview

The study analyzes latitudinal variation in benthic macrofauna diversity along the Mexico-U.S. Atlantic coast. The workflow integrates occurrence records from the Ocean Biodiversity Information System (OBIS), complementary field-survey records from the Mexican Atlantic coast, taxonomic validation against the World Register of Marine Species (WoRMS), satellite-derived environmental predictors, Random Forest regression, partial dependence plots, and beta-diversity analyses among marine ecoregions.

## Data sources

The analyses use the following data sources:

1. **OBIS occurrence records**  
   Occurrence records were obtained from the Ocean Biodiversity Information System for a curated list of shallow-water macrobenthic invertebrate taxa.

2. **Field-survey records**  
   Complementary field surveys along the Atlantic coast of Mexico generated additional occurrence records used to improve coverage in the Mexican tropical sector.

3. **Taxonomic standardization**  
   Scientific names were checked against WoRMS. Accepted names and AphiaIDs were used to harmonize taxonomy across data sources.

4. **Environmental predictors**  
   Environmental variables used in the Random Forest analyses include sea surface temperature, sea surface salinity, chlorophyll, particulate organic carbon, depth, and a sampling-effort proxy derived from the occurrence table.

## Repository structure

The repository is organized as follows:

```text
latitudinal-macrofauna-atlantic-coast/
│
├── README.md
├── LICENSE
├── CITATION.cff
│
├── data/
│   ├── raw/
│   │   └── README.md
│   │
│   └── processed/
│       ├── Supplementary file 1.xlsx
│       ├── Supplementary file 2.xlsx
│       └── Supplementary file 3.xlsx
│
├── scripts/
│   ├── 01_data_filtering_and_taxonomy.R
│   ├── 02_environmental_data_processing.R
│   ├── 03_random_forest_models.R
│   ├── 04_beta_diversity.R
│   └── 05_figures.R
│
└── outputs/
    ├── figures/
    └── tables/
