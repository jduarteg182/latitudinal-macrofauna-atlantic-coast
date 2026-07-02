############################################################
# analysis_MEPS_macrofauna.R
# Generic step-by-step analysis script for GitHub
# Manuscript: Latitudinal variation in benthic invertebrate
# macrofauna diversity along the Mexico-U.S. Atlantic Coast
#
# Purpose:
#   Reproduce the core data processing and statistical summaries
#   from the repository data file, without local computer paths.
#
# Expected repository structure:
#   data/
#     data_OBIS.xlsx
#   scripts/
#     analysis_MEPS_macrofauna.R
#   outputs/
#     Created automatically by this script
#
# Notes:
#   This script uses relative paths and should run from the
#   repository root directory.
#   If optional variables such as ecoregion, Chl, or POC are absent,
#   the corresponding optional analysis is skipped with a clear message.
############################################################


############################################################
# 1) SETUP
############################################################

options(stringsAsFactors = FALSE)

packages_needed <- c(
  "readxl",
  "dplyr",
  "tidyr",
  "stringr",
  "tibble",
  "randomForest"
)

packages_missing <- packages_needed[
  !vapply(packages_needed, requireNamespace, logical(1), quietly = TRUE)
]

if (length(packages_missing) > 0) {
  install.packages(packages_missing)
}

suppressPackageStartupMessages({
  library(readxl)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(tibble)
  library(randomForest)
})

root_dir <- getwd()
data_dir <- file.path(root_dir, "data")
out_dir  <- file.path(root_dir, "outputs")

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

candidate_data_files <- c(
  file.path(data_dir, "data_OBIS.xlsx"),
  file.path(data_dir, "data_OBIS_under25MB.xlsx"),
  file.path(root_dir, "data_OBIS.xlsx"),
  file.path(root_dir, "data_OBIS_under25MB.xlsx")
)

data_file <- candidate_data_files[file.exists(candidate_data_files)][1]

if (is.na(data_file)) {
  stop(
    "Input file not found. Expected one of:\n- ",
    paste(candidate_data_files, collapse = "\n- "),
    "\n\nPlace the Excel file inside data/ or in the repository root."
  )
}

cat("Input file:\n", data_file, "\n\n")
cat("Output folder:\n", out_dir, "\n\n")


############################################################
# 2) HELPER FUNCTIONS
############################################################

pick_col <- function(df, candidates, required = TRUE) {
  hit <- intersect(candidates, names(df))
  if (length(hit) == 0) {
    if (required) {
      stop(
        "Required column not found. Tried:\n- ",
        paste(candidates, collapse = "\n- "),
        "\nAvailable columns:\n- ",
        paste(names(df), collapse = "\n- ")
      )
    } else {
      return(NA_character_)
    }
  }
  hit[1]
}

safe_num <- function(x) {
  suppressWarnings(as.numeric(x))
}

safe_log <- function(x) {
  log(pmax(safe_num(x), 1e-6))
}

safe_log10 <- function(x) {
  log10(pmax(safe_num(x), 1e-6))
}

calc_oob_metrics <- function(obs, pred) {
  obs  <- safe_num(obs)
  pred <- safe_num(pred)
  keep <- is.finite(obs) & is.finite(pred)
  obs  <- obs[keep]
  pred <- pred[keep]
  sse <- sum((obs - pred)^2)
  sst <- sum((obs - mean(obs))^2)
  data.frame(
    n = length(obs),
    OOB_predictive_R2 = 1 - sse / sst,
    OOB_RMSE = sqrt(mean((obs - pred)^2))
  )
}


############################################################
# 3) READ DATA
############################################################

sheets <- readxl::excel_sheets(data_file)
cat("Sheets found:\n")
print(sheets)
cat("\n")

records_sheet <- if ("records" %in% sheets) "records" else sheets[1]

records_raw <- readxl::read_excel(data_file, sheet = records_sheet) %>%
  as.data.frame()

cat("Records sheet used:", records_sheet, "\n")
cat("Rows:", nrow(records_raw), "\n")
cat("Columns:", ncol(records_raw), "\n\n")

species_table <- NULL
if ("species" %in% sheets) {
  species_table <- readxl::read_excel(data_file, sheet = "species") %>%
    as.data.frame()
}


############################################################
# 4) STANDARDISE REQUIRED FIELD NAMES FOR ANALYSIS
############################################################

lon_col <- pick_col(records_raw, c(
  "decimalLongitude", "longitude", "Longitude", "lon", "x"
))

lat_col <- pick_col(records_raw, c(
  "decimalLatitude", "latitude", "Latitude", "lat", "y"
))

species_col <- pick_col(records_raw, c(
  "scientificName", "species", "Species", "taxon", "taxon_name"
))

depth_col <- pick_col(records_raw, c(
  "depth", "Depth", "depth_m", "Depth_m", "minimumDepthInMeters"
), required = FALSE)

sst_col <- pick_col(records_raw, c(
  "sst", "SST", "sst_mean", "sea_surface_temperature"
), required = FALSE)

sss_col <- pick_col(records_raw, c(
  "sss", "SSS", "sss_mean", "sea_surface_salinity"
), required = FALSE)

chl_col <- pick_col(records_raw, c(
  "chl", "Chl", "chl_mean", "ch_mean", "chl_log", "ch_log"
), required = FALSE)

poc_col <- pick_col(records_raw, c(
  "poc", "POC", "poc_mean", "poc_log"
), required = FALSE)

ecoregion_col <- pick_col(records_raw, c(
  "ECOREGION_ref", "ecoregion", "Ecoregion", "MEOW", "meow_ecoregion"
), required = FALSE)

records <- records_raw %>%
  transmute(
    longitude = safe_num(.data[[lon_col]]),
    latitude  = safe_num(.data[[lat_col]]),
    species   = as.character(.data[[species_col]]),
    depth     = if (!is.na(depth_col)) safe_num(.data[[depth_col]]) else NA_real_,
    sst       = if (!is.na(sst_col)) safe_num(.data[[sst_col]]) else NA_real_,
    sss       = if (!is.na(sss_col)) safe_num(.data[[sss_col]]) else NA_real_,
    chl       = if (!is.na(chl_col)) safe_num(.data[[chl_col]]) else NA_real_,
    poc       = if (!is.na(poc_col)) safe_num(.data[[poc_col]]) else NA_real_,
    ecoregion = if (!is.na(ecoregion_col)) as.character(.data[[ecoregion_col]]) else NA_character_
  )


############################################################
# 5) BASIC QUALITY CONTROL
############################################################

records_qc <- records %>%
  filter(
    !is.na(species),
    species != "",
    is.finite(longitude),
    is.finite(latitude),
    longitude >= -180,
    longitude <= 180,
    latitude >= -90,
    latitude <= 90
  )

if (!all(is.na(records_qc$depth))) {
  records_qc <- records_qc %>%
    filter(is.na(depth) | (depth >= 0 & depth <= 20))
}

records_qc <- records_qc %>%
  mutate(
    lon_round = round(longitude, 5),
    lat_round = round(latitude, 5),
    site_id = paste(lat_round, lon_round, sep = "_")
  )

qc_summary <- data.frame(
  raw_records = nrow(records_raw),
  retained_records = nrow(records_qc),
  retained_sites = dplyr::n_distinct(records_qc$site_id),
  retained_species = dplyr::n_distinct(records_qc$species)
)

write.csv(
  qc_summary,
  file.path(out_dir, "01_quality_control_summary.csv"),
  row.names = FALSE
)

cat("Quality control summary:\n")
print(qc_summary)
cat("\n")


############################################################
# 6) SITE-LEVEL OCCURRENCE RICHNESS AND OBSERVATION EFFORT
############################################################

site_richness <- records_qc %>%
  group_by(site_id) %>%
  summarise(
    latitude = mean(latitude, na.rm = TRUE),
    longitude = mean(longitude, na.rm = TRUE),
    richness_site = n_distinct(species),
    n_records = n(),
    log_effort = log(n_records),
    depth = if (all(is.na(depth))) NA_real_ else mean(depth, na.rm = TRUE),
    sst = if (all(is.na(sst))) NA_real_ else mean(sst, na.rm = TRUE),
    sss = if (all(is.na(sss))) NA_real_ else mean(sss, na.rm = TRUE),
    chl = if (all(is.na(chl))) NA_real_ else mean(chl, na.rm = TRUE),
    poc = if (all(is.na(poc))) NA_real_ else mean(poc, na.rm = TRUE),
    ecoregion = if (all(is.na(ecoregion))) NA_character_ else dplyr::first(na.omit(ecoregion)),
    .groups = "drop"
  )

write.csv(
  site_richness,
  file.path(out_dir, "02_site_level_richness_and_effort.csv"),
  row.names = FALSE
)

species_occupancy <- records_qc %>%
  distinct(site_id, species) %>%
  count(species, name = "occupied_sites") %>%
  arrange(desc(occupied_sites), species)

write.csv(
  species_occupancy,
  file.path(out_dir, "03_species_occupancy.csv"),
  row.names = FALSE
)


############################################################
# 7) LATITUDINAL RICHNESS DIAGNOSTICS
############################################################

lat_cor <- data.frame(
  pearson_r = stats::cor(
    site_richness$latitude,
    site_richness$richness_site,
    method = "pearson",
    use = "complete.obs"
  ),
  spearman_rho = stats::cor(
    site_richness$latitude,
    site_richness$richness_site,
    method = "spearman",
    use = "complete.obs"
  ),
  n_sites = nrow(site_richness)
)

write.csv(
  lat_cor,
  file.path(out_dir, "04_latitude_richness_correlations.csv"),
  row.names = FALSE
)

latitudinal_bands <- site_richness %>%
  mutate(lat_band_0.5 = floor(latitude * 2) / 2) %>%
  group_by(lat_band_0.5) %>%
  summarise(
    n_sites = n(),
    mean_site_richness = mean(richness_site, na.rm = TRUE),
    gamma_richness = n_distinct(records_qc$species[records_qc$site_id %in% site_id]),
    .groups = "drop"
  )

write.csv(
  latitudinal_bands,
  file.path(out_dir, "05_latitudinal_band_summaries.csv"),
  row.names = FALSE
)


############################################################
# 8) RANDOM FOREST MODELS
############################################################

model_data <- site_richness %>%
  mutate(
    chl_log = ifelse(is.finite(chl), safe_log10(chl), NA_real_),
    poc_log = ifelse(is.finite(poc), safe_log10(poc), NA_real_)
  )

candidate_predictors <- c("sst", "sss", "depth", "chl_log", "poc_log")

available_environmental_predictors <- candidate_predictors[
  vapply(model_data[candidate_predictors], function(z) any(is.finite(z)), logical(1))
]

if (length(available_environmental_predictors) >= 1) {
  rf_data <- model_data %>%
    select(richness_site, log_effort, all_of(available_environmental_predictors)) %>%
    drop_na()
  
  if (nrow(rf_data) >= 50) {
    
    set.seed(123)
    
    formula_with_effort <- stats::as.formula(
      paste("richness_site ~", paste(c(available_environmental_predictors, "log_effort"), collapse = " + "))
    )
    
    formula_environment_only <- stats::as.formula(
      paste("richness_site ~", paste(available_environmental_predictors, collapse = " + "))
    )
    
    rf_with_effort <- randomForest::randomForest(
      formula_with_effort,
      data = rf_data,
      ntree = 1500,
      importance = TRUE
    )
    
    rf_environment_only <- randomForest::randomForest(
      formula_environment_only,
      data = rf_data,
      ntree = 1500,
      importance = TRUE
    )
    
    pred_with_effort <- data.frame(
      richness_obs = rf_data$richness_site,
      richness_pred = rf_with_effort$predicted
    )
    
    pred_environment_only <- data.frame(
      richness_obs = rf_data$richness_site,
      richness_pred = rf_environment_only$predicted
    )
    
    metrics_with_effort <- calc_oob_metrics(
      pred_with_effort$richness_obs,
      pred_with_effort$richness_pred
    ) %>%
      mutate(model = "environment_plus_observation_effort")
    
    metrics_environment_only <- calc_oob_metrics(
      pred_environment_only$richness_obs,
      pred_environment_only$richness_pred
    ) %>%
      mutate(model = "environment_only")
    
    rf_metrics <- bind_rows(metrics_with_effort, metrics_environment_only) %>%
      select(model, everything())
    
    write.csv(
      rf_metrics,
      file.path(out_dir, "06_random_forest_oob_metrics.csv"),
      row.names = FALSE
    )
    
    write.csv(
      randomForest::importance(rf_with_effort) %>%
        as.data.frame() %>%
        rownames_to_column("variable"),
      file.path(out_dir, "07_random_forest_importance_with_effort.csv"),
      row.names = FALSE
    )
    
    write.csv(
      pred_with_effort,
      file.path(out_dir, "08_random_forest_predictions_with_effort.csv"),
      row.names = FALSE
    )
    
    write.csv(
      pred_environment_only,
      file.path(out_dir, "09_random_forest_predictions_environment_only.csv"),
      row.names = FALSE
    )
    
  } else {
    message("Random Forest skipped: fewer than 50 complete site-level rows.")
  }
  
} else {
  message("Random Forest skipped: no environmental predictors available in the dataset.")
}


############################################################
# 9) ECOREGION-SCALE BETA DIVERSITY, OPTIONAL
############################################################

if (!all(is.na(records_qc$ecoregion))) {
  
  if (!requireNamespace("betapart", quietly = TRUE)) {
    install.packages("betapart")
  }
  
  library(betapart)
  
  ecoregion_species <- records_qc %>%
    filter(!is.na(ecoregion), ecoregion != "") %>%
    distinct(ecoregion, species) %>%
    mutate(presence = 1) %>%
    tidyr::pivot_wider(
      names_from = species,
      values_from = presence,
      values_fill = 0
    )
  
  eco_names <- ecoregion_species$ecoregion
  eco_matrix <- ecoregion_species %>%
    select(-ecoregion) %>%
    as.matrix()
  
  rownames(eco_matrix) <- eco_names
  storage.mode(eco_matrix) <- "numeric"
  
  beta_multi <- betapart::beta.multi(
    eco_matrix,
    index.family = "sorensen"
  )
  
  beta_pair <- betapart::beta.pair(
    eco_matrix,
    index.family = "sorensen"
  )
  
  beta_multi_table <- data.frame(
    beta_SOR = beta_multi$beta.SOR,
    beta_SIM = beta_multi$beta.SIM,
    beta_SNE = beta_multi$beta.SNE
  )
  
  write.csv(
    beta_multi_table,
    file.path(out_dir, "10_beta_diversity_multisite.csv"),
    row.names = FALSE
  )
  
  write.csv(
    as.matrix(beta_pair$beta.sor),
    file.path(out_dir, "11_beta_pairwise_sorensen.csv")
  )
  
  write.csv(
    as.matrix(beta_pair$beta.sim),
    file.path(out_dir, "12_beta_pairwise_turnover.csv")
  )
  
  write.csv(
    as.matrix(beta_pair$beta.sne),
    file.path(out_dir, "13_beta_pairwise_nestedness.csv")
  )
  
} else {
  message("Beta diversity skipped: no ecoregion column detected in the dataset.")
}


############################################################
# 10) SESSION INFORMATION
############################################################

sink(file.path(out_dir, "14_session_info.txt"))
print(sessionInfo())
sink()

cat("\nAnalysis complete. Output files were saved in:\n", out_dir, "\n")
