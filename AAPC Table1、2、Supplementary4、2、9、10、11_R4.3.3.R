# =============================================================================
# Reproducibility Script B:
# Tables only, revised Table 1
#
# Final table outputs:
#   Table_1_Global_ASIR_ASMR_ASYR_AAPC_1990_2021_long.csv
#   Table_1_Global_ASIR_ASMR_ASYR_AAPC_1990_2021_wide.csv
#   Supplementary_Table_2_Global_LowSDI_LowMiddleSDI_Under5_ASIR_ASMR_ASYR_APC_1990_2021_long.csv
#   Supplementary_Table_2_Global_LowSDI_LowMiddleSDI_Under5_ASIR_ASMR_ASYR_APC_1990_2021_wide.csv
#   Supplementary_Table_4_Country_ASIR_ASMR_ASYR_AAPC_1990_2021_long.csv
#   Supplementary_Table_4_Country_ASIR_ASMR_ASYR_AAPC_1990_2021_wide.csv
#   Supplementary_Table_9_Global_Regions_Under5_Meningitis_Impairment_Prevalence_AAPC_1990_2021_long.csv
#   Supplementary_Table_9_Global_Regions_Under5_Meningitis_Impairment_Prevalence_AAPC_1990_2021_wide.csv
#   Supplementary_Table_10_Global_5SDI_Etiology_Age_ASYR_APC_2017_2021_long.csv
#   Supplementary_Table_10_Global_5SDI_Etiology_Age_ASYR_APC_2017_2021_wide.csv
#   Supplementary_Table_11_Global_5SDI_Age_Impairment_Prevalence_APC_2017_2021_long.csv
#   Supplementary_Table_11_Global_5SDI_Age_Impairment_Prevalence_APC_2017_2021_wide.csv
#   Table_2_Global_Etiology_Meningitis_ASYR_AAPC_2017_2021.csv
#   Table_2_Global_Etiology_Meningitis_ASYR_AAPC_2017_2021.rds
#
# Raw Joinpoint component outputs:
#   All GBDage_aapc() results are also exported under:
#     02_table_output/00_joinpoint_raw_components/
#
#   For every fitted result object, the following components are written:
#     result[["AAPC"]]
#     result[["AAPC_Range"]]
#     result[["APC"]]
#     result[["data"]]
#
# R version: 3.3.3 compatible
# =============================================================================
#
# Revised Table 1 definition:
#
# Table 1 contains:
#   1. Global rows for 8 age groups:
#      <5; <28 days; 0-6 days; 7-27 days; 1 to 5 months;
#      6 to 11 months; 12 to 23 months; 2 to 4 years
#
#   2. SDI and GBD region rows for under-five total only:
#      High SDI; High-middle SDI; Middle SDI; Low-middle SDI; Low SDI;
#      High-income Asia Pacific; High-income North America; Western Europe;
#      Australasia; Andean Latin America; Tropical Latin America;
#      Central Latin America; Southern Latin America; Caribbean;
#      Central Europe; Eastern Europe; Central Asia;
#      North Africa and Middle East; South Asia; Southeast Asia; East Asia;
#      Oceania; Western Sub-Saharan Africa; Eastern Sub-Saharan Africa;
#      Central Sub-Saharan Africa; Southern Sub-Saharan Africa
#
# For each row, the script fits Joinpoint models for ASIR, ASMR and ASYR
# during 1990-2021, then extracts AAPC, 95% CI and P value.
#
# Supplementary Table 2 definition:
#
#   Supplementary Table 2 uses the same Joinpoint results already fitted for
#   revised Table 1. It does not run additional Joinpoint models. It reads
#   result[["APC"]] for Global, Low SDI and Low-middle SDI, under-five total
#   only, for ASIR, ASMR and ASYR during 1990-2021.
#
# Supplementary Table 9 definition:
#
#   Supplementary Table 9 estimates AAPC of prevalence of impairments attributed
#   to meningitis among children under 5 years during 1990-2021.
#   It requires an additional complete Joinpoint analysis because the modeled
#   time series are Location x Impairment.
#
#   Global includes 17 impairment categories:
#     Epilepsy; Hearing loss; Mild hearing loss; Moderate hearing loss;
#     Moderately severe hearing loss; Severe hearing loss; Profound hearing loss;
#     Complete hearing loss; Developmental intellectual disability;
#     Borderline intellectual disability; Mild intellectual disability;
#     Moderate intellectual disability; Severe intellectual disability;
#     Blindness and vision loss; Moderate vision loss; Severe vision loss;
#     Blindness.
#
#   SDI and GBD regions include 4 aggregate impairment categories:
#     Epilepsy; Hearing loss; Developmental intellectual disability;
#     Blindness and vision loss.
#

# Supplementary Table 10 definition:
#
#   Supplementary Table 10 estimates 2017-2021 APC/AAPC-range of
#   etiology-specific ASYR of meningitis among children under 5 years, globally
#   and across 5 SDI regions, stratified by age group.
#
#   It requires one additional complete Joinpoint analysis because the modeled
#   time series are Location x Etiology x Age.
#
#   Locations:
#     Global; High SDI; High-middle SDI; Middle SDI; Low-middle SDI; Low SDI.
#
#   Etiologies:
#     Escherichia coli; Group B streptococcus; Haemophilus influenzae;
#     Klebsiella pneumoniae; Listeria monocytogenes; Neisseria meningitidis;
#     Other bacterial pathogen; Staphylococcus aureus; Streptococcus pneumoniae;
#     Viral etiologies of meningitis.
#
#   Age groups:
#     <5; <28 days; 0-6 days; 7-27 days; 1 to 5 months; 6 to 11 months;
#     12 to 23 months; 2 to 4 years.
#

# Supplementary Table 11 definition:
#
#   Supplementary Table 11 estimates 2017-2021 APC/AAPC-range of prevalence of
#   meningitis-related functional impairments among children under 5 years,
#   globally and across five SDI regions, stratified by age group.
#
#   It requires one additional complete Joinpoint analysis because the modeled
#   time series are Location x Age x Impairment.
#
#   Locations:
#     Global; High SDI; High-middle SDI; Middle SDI; Low-middle SDI; Low SDI.
#
#   Age groups:
#     <5; <28 days; 0-6 days; 7-27 days; 1 to 5 months; 6 to 11 months;
#     12 to 23 months; 2 to 4 years.
#
#   Impairments:
#     Hearing loss; Epilepsy; Blindness and vision loss;
#     Developmental intellectual disability.
#
# Raw Joinpoint reproducibility rule:
#
#   Every GBDage_aapc() result is exported with:
#     write.csv(result[["AAPC"]],       "<prefix>_AAPC.csv")
#     write.csv(result[["AAPC_Range"]], "<prefix>_AAPC_Range.csv")
#     write.csv(result[["APC"]],        "<prefix>_APC.csv")
#     write.csv(result[["data"]],       "<prefix>_data.csv")
#
#   Table 2 now runs both:
#     1. A full 1990-2021 model with AAPCrange = NULL
#     2. A 2017-2021 range model with AAPCrange = c(2017, 2021)
#
#   The final Table 2 uses the 2017-2021 AAPC_Range output, while the full
#   AAPCrange = NULL result is also exported for reviewer verification.
# =============================================================================

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. Packages
# -----------------------------------------------------------------------------

required_packages <- c("easyGBDR")

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Please install the following R package(s) before running this script: ",
    paste(missing_packages, collapse = ", "),
    call. = FALSE
  )
}

suppressPackageStartupMessages(library(easyGBDR))

if ("GBD_edition" %in% ls("package:easyGBDR")) {
  GBD_edition(edition = 2021)
}

# -----------------------------------------------------------------------------
# 2. Project paths and reviewer-facing raw-data folder names
# -----------------------------------------------------------------------------
#
# This single table-only script expects six reviewer-facing raw-data folders under:
#
#   D:/Meningitis_Joinpoint_Reproducibility/01_raw_GBD_data/
#
# Folder A, for revised Table 1:
#
#   Table1_Global_5SDI_21GBDRegions_BothSex_AgeSpecific_Incidence_Deaths_YLD_Rate_1990_2021
#
# Required GBD Results selections for revised Table 1:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Locations:   Global; 5 SDI groups; 21 GBD regions
#   Sex:         Both
#   Metric:      Rate
#   Measures:    Incidence; Deaths; YLDs (Years Lived with Disability)
#   Years:       Every individual year from 1990 through 2021
#   Ages:        <5 / 0 to 4 / Under 5 years;
#                Neonatal / <28 days;
#                Early Neonatal / 0-6 days;
#                Late Neonatal / 7-27 days;
#                1 to 5 months; 6 to 11 months;
#                12 to 23 months; 2 to 4 years
#
# The script uses all 8 age groups for Global, but only the <5 age group
# for SDI and GBD region rows.
#
# Folder B, for Supplementary Table 4:
#
#   SuppTable4_204Countries_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021
#
# Folder C, for Table 2:
#
#   Table2_Global_BothSex_Under5_Neonatal_Etiology_YLD_Rate_1990_2021
#
# Folder D, for Supplementary Table 9:
#
#   SuppTable9_Global_5SDI_21GBDRegions_BothSex_Under5_Impairment_Prevalence_RatePreferred_NumberAllowed_1990_2021
#
# Folder E, for Supplementary Table 10:
#
#   SuppTable10_Global_5SDI_BothSex_AgeSpecific_Etiology_YLD_Rate_1990_2021
#
# Folder F, for Supplementary Table 11:
#
#   SuppTable11_Global_5SDI_BothSex_AgeSpecific_Impairment_Prevalence_RatePreferred_NumberAllowed_1990_2021
#
# Required GBD Results selections for Supplementary Table 9:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Locations:   Global; 5 SDI groups; 21 GBD regions
#   Sex:         Both
#   Age:         <5 / 0 to 4 / Under 5 years
#   Measure:     Prevalence
#   Metric:      Preferably Rate. The script can also use Number if Rate is absent.
#   Years:       Every individual year from 1990 through 2021
#   Impairment:  Use the impairments listed in the Supplementary Table 9 definition.
#
# Required GBD Results selections for Supplementary Table 10:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Locations:   Global; 5 SDI groups
#   Sex:         Both
#   Metric:      Rate
#   Measure:     YLDs (Years Lived with Disability)
#   Years:       Every individual year from 1990 through 2021
#   Etiology:    Use the 10 etiologies listed in the Supplementary Table 10 definition.
#   Ages:        <5 / 0 to 4 / Under 5 years;
#                Neonatal / <28 days;
#                Early Neonatal / 0-6 days;
#                Late Neonatal / 7-27 days;
#                1 to 5 months; 6 to 11 months;
#                12 to 23 months; 2 to 4 years
#
# Required GBD Results selections for Supplementary Table 11:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Locations:   Global; 5 SDI groups
#   Sex:         Both
#   Measure:     Prevalence
#   Metric:      Preferably Rate. The script can also use Number if Rate is absent.
#   Years:       Every individual year from 1990 through 2021
#   Impairment:  Hearing loss; Epilepsy; Blindness and vision loss;
#                Developmental intellectual disability
#   Ages:        <5 / 0 to 4 / Under 5 years;
#                Neonatal / <28 days;
#                Early Neonatal / 0-6 days;
#                Late Neonatal / 7-27 days;
#                1 to 5 months; 6 to 11 months;
#                12 to 23 months; 2 to 4 years
#
# This script writes the requested final table files plus raw Joinpoint component CSVs into TABLE_OUTPUT_DIR.
#
# Important reviewer note:
#   The folder names below are intentionally descriptive and reviewer-facing.
#   They are not required to match IHME's default downloaded ZIP/CSV names.
#   After downloading each GBD Results dataset, place the CSV file(s) into the
#   corresponding folder name shown below. This makes the reproducibility package
#   self-explanatory for reviewers and editors.

PROJECT_DIR <- "D:/Meningitis_Joinpoint_Reproducibility"

RAW_DATA_ROOT <- file.path(PROJECT_DIR, "01_raw_GBD_data")

# The following folder names are intentionally reviewer-facing and descriptive.
# They encode the table number, location level, sex, age level, measure/metric,
# stratification variable and year range.

TABLE1_RAW_DATA_FOLDER_NAME <- paste0(
  "Table1_Global_5SDI_21GBDRegions_BothSex_",
  "AgeSpecific_Incidence_Deaths_YLD_Rate_1990_2021"
)

SUPP4_RAW_DATA_FOLDER_NAME <- paste0(
  "SuppTable4_204Countries_BothSex_",
  "Under5_Incidence_Deaths_YLD_Rate_1990_2021"
)

TABLE2_RAW_DATA_FOLDER_NAME <- paste0(
  "Table2_Global_BothSex_",
  "Under5_Neonatal_Etiology_YLD_Rate_1990_2021"
)

SUPP9_RAW_DATA_FOLDER_NAME <- paste0(
  "SuppTable9_Global_5SDI_21GBDRegions_BothSex_",
  "Under5_Impairment_Prevalence_RatePreferred_NumberAllowed_1990_2021"
)

SUPP10_RAW_DATA_FOLDER_NAME <- paste0(
  "SuppTable10_Global_5SDI_BothSex_",
  "AgeSpecific_Etiology_YLD_Rate_1990_2021"
)

SUPP11_RAW_DATA_FOLDER_NAME <- paste0(
  "SuppTable11_Global_5SDI_BothSex_",
  "AgeSpecific_Impairment_Prevalence_RatePreferred_NumberAllowed_1990_2021"
)

TABLE1_INPUT_FOLDER <- file.path(RAW_DATA_ROOT, TABLE1_RAW_DATA_FOLDER_NAME)
SUPP4_INPUT_FOLDER  <- file.path(RAW_DATA_ROOT, SUPP4_RAW_DATA_FOLDER_NAME)
TABLE2_INPUT_FOLDER <- file.path(RAW_DATA_ROOT, TABLE2_RAW_DATA_FOLDER_NAME)
SUPP9_INPUT_FOLDER  <- file.path(RAW_DATA_ROOT, SUPP9_RAW_DATA_FOLDER_NAME)
SUPP10_INPUT_FOLDER <- file.path(RAW_DATA_ROOT, SUPP10_RAW_DATA_FOLDER_NAME)
SUPP11_INPUT_FOLDER <- file.path(RAW_DATA_ROOT, SUPP11_RAW_DATA_FOLDER_NAME)

TABLE_OUTPUT_DIR <- file.path(PROJECT_DIR, "02_table_output")

# Print a concise raw-data download manifest at the start of the workflow.
# This is for reviewers: it tells them exactly which GBD Results downloads
# should be placed in which folder.
print_raw_data_download_manifest <- function() {
  manifest <- data.frame(
    Analysis = c(
      "Table 1 and Supplementary Table 2",
      "Supplementary Table 4",
      "Table 2",
      "Supplementary Table 9",
      "Supplementary Table 10",
      "Supplementary Table 11"
    ),
    Raw_data_folder = c(
      TABLE1_RAW_DATA_FOLDER_NAME,
      SUPP4_RAW_DATA_FOLDER_NAME,
      TABLE2_RAW_DATA_FOLDER_NAME,
      SUPP9_RAW_DATA_FOLDER_NAME,
      SUPP10_RAW_DATA_FOLDER_NAME,
      SUPP11_RAW_DATA_FOLDER_NAME
    ),
    Locations = c(
      "Global; 5 SDI groups; 21 GBD regions",
      "204 countries/territories",
      "Global",
      "Global; 5 SDI groups; 21 GBD regions",
      "Global; 5 SDI groups",
      "Global; 5 SDI groups"
    ),
    Age_groups = c(
      "Age-specific: <5, <28 days, 0-6 days, 7-27 days, 1-5 months, 6-11 months, 12-23 months, 2-4 years",
      "Under 5 only",
      "Under 5 and neonatal",
      "Under 5 only",
      "Age-specific: <5, <28 days, 0-6 days, 7-27 days, 1-5 months, 6-11 months, 12-23 months, 2-4 years",
      "Age-specific: <5, <28 days, 0-6 days, 7-27 days, 1-5 months, 6-11 months, 12-23 months, 2-4 years"
    ),
    GBD_measure_metric = c(
      "Incidence Rate; Deaths Rate; YLDs Rate",
      "Incidence Rate; Deaths Rate; YLDs Rate",
      "YLDs Rate",
      "Prevalence Rate preferred; Number allowed if Rate absent",
      "YLDs Rate",
      "Prevalence Rate preferred; Number allowed if Rate absent"
    ),
    Stratification = c(
      "Location and age",
      "Country",
      "Etiology and age",
      "Impairment",
      "Etiology and age",
      "Impairment and age"
    ),
    Years = rep("1990-2021, every individual year", 6),
    stringsAsFactors = FALSE
  )

  cat("\n=================================================================\n")
  cat("Reviewer-facing raw GBD data download manifest\n")
  cat("Place downloaded IHME GBD 2021 CSV file(s) into these folders:\n")
  cat("Raw data root: ", normalizePath(RAW_DATA_ROOT, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("=================================================================\n")
  print(manifest, row.names = FALSE)
  cat("=================================================================\n\n")

  invisible(manifest)
}

# -----------------------------------------------------------------------------
# 3. Common GBD and Joinpoint settings
# -----------------------------------------------------------------------------

LOCATION_NAME <- "Global"
SEX_NAME      <- "Both"
CAUSE_NAME    <- "Meningitis"
METRIC_NAME   <- "Rate"

START_YEAR <- 1990
END_YEAR   <- 2021

MODEL_TYPE        <- "ln"
N_JOINPOINTS      <- 5
CALCULATE_CI      <- TRUE
CONSTANT_VARIANCE <- TRUE
ROUND_DIGITS      <- 5

# Table 2 reports recent AAPC from 2017 to 2021.
TABLE2_AAPC_RANGE_START <- 2017
TABLE2_AAPC_RANGE_END   <- 2021

# If TRUE, Supplementary Table 4 stops unless exactly 204 countries/territories
# are inferred after excluding aggregate GBD locations.
STOP_IF_COUNTRY_COUNT_NOT_204 <- TRUE

# -----------------------------------------------------------------------------
# 4. Helper functions
# -----------------------------------------------------------------------------

create_folder <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  return(path)
}

sanitize_file_part <- function(x) {
  x <- as.character(x)
  x <- gsub("[^A-Za-z0-9]+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  if (nchar(x) == 0) {
    x <- "unnamed"
  }
  return(x)
}

coerce_joinpoint_component_to_data_frame <- function(x, component_name, analysis_prefix) {
  if (is.null(x)) {
    return(
      data.frame(
        note = paste0(
          "Component result[['",
          component_name,
          "']] was NULL or was not returned for ",
          analysis_prefix,
          "."
        ),
        stringsAsFactors = FALSE
      )
    )
  }

  if (is.data.frame(x)) {
    return(x)
  }

  out <- tryCatch(
    as.data.frame(x, stringsAsFactors = FALSE),
    error = function(e) {
      data.frame(
        note = paste0(
          "Component result[['",
          component_name,
          "']] could not be coerced to a data.frame for ",
          analysis_prefix,
          "."
        ),
        error_message = conditionMessage(e),
        stringsAsFactors = FALSE
      )
    }
  )

  return(out)
}

joinpoint_raw_component_file <- function(output_dir, analysis_prefix, component_name) {
  component_output_dir <- create_folder(
    file.path(output_dir, "00_joinpoint_raw_components")
  )

  return(
    file.path(
      component_output_dir,
      paste0(sanitize_file_part(analysis_prefix), "_", component_name, ".csv")
    )
  )
}

assert_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      "Required data column(s) are missing: ",
      paste(missing_columns, collapse = ", "),
      "\nAvailable columns: ",
      paste(names(data), collapse = " | "),
      call. = FALSE
    )
  }
}

assert_values_exist <- function(data, column_name, expected_values) {
  available_values <- unique(as.character(data[[column_name]]))
  absent_values <- setdiff(expected_values, available_values)

  if (length(absent_values) > 0) {
    stop(
      "The following required ", column_name, " value(s) were not found: ",
      paste(absent_values, collapse = ", "),
      "\nAvailable ", column_name, " values are:\n",
      paste(available_values, collapse = " | "),
      call. = FALSE
    )
  }
}

resolve_age_label <- function(available_ages, candidates, description) {
  matched <- candidates[candidates %in% available_ages]

  if (length(matched) == 0) {
    stop(
      "Cannot find ", description, ".\n",
      "Expected one of: ", paste(candidates, collapse = " | "),
      "\nAvailable age values are:\n",
      paste(available_ages, collapse = " | "),
      call. = FALSE
    )
  }

  return(matched[1])
}

clean_column_name <- function(x) {
  tolower(gsub("[^a-z0-9]", "", x))
}

find_column <- function(data, candidates, required = TRUE) {
  cleaned_names <- clean_column_name(names(data))
  cleaned_candidates <- clean_column_name(candidates)

  matched_index <- match(cleaned_candidates, cleaned_names)
  matched_index <- matched_index[!is.na(matched_index)]

  if (length(matched_index) > 0) {
    return(names(data)[matched_index[1]])
  }

  if (required) {
    stop(
      "Cannot find required column. Candidate names were: ",
      paste(candidates, collapse = ", "),
      "\nAvailable names were:\n",
      paste(names(data), collapse = " | "),
      call. = FALSE
    )
  }

  return(NA)
}

format_number <- function(x, digits = 2) {
  x <- as.numeric(x)
  out <- sprintf(paste0("%.", digits, "f"), x)
  out <- sub("0+$", "", out)
  out <- sub("\\.$", "", out)
  return(out)
}

format_p_value <- function(x) {
  x <- as.numeric(x)

  out <- ifelse(
    is.na(x),
    NA,
    ifelse(x < 0.001, "<0.001", sprintf("%.3f", x))
  )

  return(out)
}

make_aapc_ci_text <- function(aapc, lower, upper) {
  paste0(
    format_number(aapc, 2),
    " (",
    format_number(lower, 2),
    ", ",
    format_number(upper, 2),
    ")"
  )
}

read_gbd_folder <- function(input_folder, required_columns) {
  if (!dir.exists(input_folder)) {
    stop(
      "Input folder does not exist:\n",
      input_folder,
      "\n\nPlease create this folder and place the downloaded IHME GBD 2021 CSV file(s) inside it.",
      call. = FALSE
    )
  }

  data <- GBDread(
    folder = TRUE,
    foldername = input_folder
  )

  assert_columns(data, required_columns)

  character_columns <- intersect(
    c(
      "location", "sex", "age", "cause", "measure", "metric", "rei",
      "sequela", "sequela_name", "impairment", "impairment_name",
      "health_state", "health_state_name"
    ),
    names(data)
  )

  for (current_column in character_columns) {
    data[[current_column]] <- as.character(data[[current_column]])
  }

  if ("year" %in% names(data)) {
    data$year <- as.numeric(as.character(data$year))
  }

  if ("val" %in% names(data)) {
    data$val <- as.numeric(as.character(data$val))
  }

  return(data)
}

check_total_meningitis_rows <- function(data, context_name) {
  if ("rei" %in% names(data)) {
    non_empty_rei <- unique(as.character(data$rei))
    non_empty_rei <- non_empty_rei[
      !is.na(non_empty_rei) &
        non_empty_rei != "" &
        non_empty_rei != "NA" &
        non_empty_rei != "No risk" &
        non_empty_rei != "Total" &
        non_empty_rei != "All causes" &
        non_empty_rei != "All etiologies"
    ]

    if (length(non_empty_rei) > 0) {
      stop(
        context_name,
        " appears to contain etiology-specific rows in the 'rei' column. ",
        "Please use total meningitis estimates for this table.",
        call. = FALSE
      )
    }
  }
}

validate_joinpoint_result <- function(
  joinpoint_result,
  analysis_label,
  require_aapc_range = FALSE
) {
  required_result_names <- c("AAPC", "APC", "data")

  if (require_aapc_range) {
    required_result_names <- c(required_result_names, "AAPC_Range")
  }

  missing_result_names <- required_result_names[
    !required_result_names %in% names(joinpoint_result)
  ]

  if (length(missing_result_names) > 0) {
    stop(
      "Joinpoint result is incomplete for: ",
      analysis_label,
      "\nMissing component(s): ",
      paste(missing_result_names, collapse = ", "),
      "\nExpected core outputs include result[['AAPC']], result[['APC']], ",
      "and result[['data']]. result[['AAPC_Range']] is exported for every model when returned.",
      call. = FALSE
    )
  }

  for (current_name in required_result_names) {
    current_object <- joinpoint_result[[current_name]]

    if (is.null(current_object)) {
      stop(
        "Joinpoint result component result[['",
        current_name,
        "']] is NULL for: ",
        analysis_label,
        call. = FALSE
      )
    }

    if (is.data.frame(current_object) && nrow(current_object) == 0) {
      stop(
        "Joinpoint result component result[['",
        current_name,
        "']] has zero rows for: ",
        analysis_label,
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

# -----------------------------------------------------------------------------
# 5. Revised Table 1:
#    Global 8 age groups + SDI/GBD region under-five rows, 1990-2021
# -----------------------------------------------------------------------------

make_table1_outputs <- function(table1_input_folder, output_dir) {
  required_columns <- c(
    "location", "sex", "age", "cause", "measure",
    "metric", "year", "val"
  )

  gbd_data <- read_gbd_folder(table1_input_folder, required_columns)

  table1_region_location_order <- c(
    "High SDI",
    "High-middle SDI",
    "Middle SDI",
    "Low-middle SDI",
    "Low SDI",
    "High-income Asia Pacific",
    "High-income North America",
    "Western Europe",
    "Australasia",
    "Andean Latin America",
    "Tropical Latin America",
    "Central Latin America",
    "Southern Latin America",
    "Caribbean",
    "Central Europe",
    "Eastern Europe",
    "Central Asia",
    "North Africa and Middle East",
    "South Asia",
    "Southeast Asia",
    "East Asia",
    "Oceania",
    "Western Sub-Saharan Africa",
    "Eastern Sub-Saharan Africa",
    "Central Sub-Saharan Africa",
    "Southern Sub-Saharan Africa"
  )

  table1_location_order <- c(LOCATION_NAME, table1_region_location_order)

  assert_values_exist(gbd_data, "location", table1_location_order)
  assert_values_exist(gbd_data, "sex", SEX_NAME)
  assert_values_exist(gbd_data, "cause", CAUSE_NAME)
  assert_values_exist(gbd_data, "metric", METRIC_NAME)

  measure_specs <- list(
    list(indicator = "ASIR", measure_name = "Incidence"),
    list(indicator = "ASMR", measure_name = "Deaths"),
    list(indicator = "ASYR", measure_name = "YLDs (Years Lived with Disability)")
  )

  requested_measures <- vapply(
    measure_specs,
    function(x) x$measure_name,
    character(1)
  )

  assert_values_exist(gbd_data, "measure", requested_measures)

  available_ages <- unique(gbd_data$age)

  age_under5 <- resolve_age_label(
    available_ages,
    c("<5", "< 5", "<5 years", "Under 5", "Under 5 years",
      "0 to 4", "0 to 4 years", "0-4 years"),
    "under-five total age group"
  )

  age_neonatal <- resolve_age_label(
    available_ages,
    c("Neonatal", "Neonatal period", "<28 days", "< 28 days",
      "0 to 27 days", "0-27 days", "0 to 28 days"),
    "neonatal total age group"
  )

  age_early_neonatal <- resolve_age_label(
    available_ages,
    c("Early Neonatal", "Early neonatal", "0 to 6 days", "0-6 days", "0 to 6"),
    "early neonatal age group"
  )

  age_late_neonatal <- resolve_age_label(
    available_ages,
    c("Late Neonatal", "Late neonatal", "7 to 27 days", "7-27 days", "7 to 27"),
    "late neonatal age group"
  )

  age_1_to_5_months <- resolve_age_label(
    available_ages,
    c("1 to 5 months", "1-5 months"),
    "1 to 5 months age group"
  )

  age_6_to_11_months <- resolve_age_label(
    available_ages,
    c("6 to 11 months", "6-11 months"),
    "6 to 11 months age group"
  )

  age_12_to_23_months <- resolve_age_label(
    available_ages,
    c("12 to 23 months", "12-23 months"),
    "12 to 23 months age group"
  )

  age_2_to_4_years <- resolve_age_label(
    available_ages,
    c("2 to 4", "2 to 4 years", "2-4 years"),
    "2 to 4 years age group"
  )

  # Global rows: all 8 requested age groups.
  table1_global_age_order <- c(
    age_under5,
    age_neonatal,
    age_early_neonatal,
    age_late_neonatal,
    age_1_to_5_months,
    age_6_to_11_months,
    age_12_to_23_months,
    age_2_to_4_years
  )

  # Regional rows: under-five total only.
  table1_region_age_order <- age_under5

  age_display <- c(
    "<5",
    "<28 days",
    "0-6 days",
    "7-27 days",
    "1 to 5 months",
    "6 to 11 months",
    "12 to 23 months",
    "2 to 4 years"
  )

  names(age_display) <- table1_global_age_order
  age_output_order <- age_display

  # Supplementary Table 2 rows: Global, Low SDI and Low-middle SDI, under-five only.
  supp2_location_order <- c(
    LOCATION_NAME,
    "Low SDI",
    "Low-middle SDI"
  )

  extract_year_bounds_from_text <- function(time_values) {
    start_years <- rep(NA_real_, length(time_values))
    end_years <- rep(NA_real_, length(time_values))

    for (i in seq_along(time_values)) {
      current_text <- as.character(time_values[i])
      year_matches <- regmatches(
        current_text,
        gregexpr("[0-9]{4}", current_text)
      )[[1]]

      if (length(year_matches) >= 2) {
        start_years[i] <- as.numeric(year_matches[1])
        end_years[i] <- as.numeric(year_matches[length(year_matches)])
      } else if (length(year_matches) == 1) {
        start_years[i] <- as.numeric(year_matches[1])
        end_years[i] <- as.numeric(year_matches[1])
      }
    }

    return(
      data.frame(
        Start_year = start_years,
        End_year = end_years,
        stringsAsFactors = FALSE
      )
    )
  }

  find_time_column <- function(data, excluded_columns) {
    candidate_columns <- setdiff(names(data), excluded_columns)

    for (current_column in candidate_columns) {
      current_values <- as.character(data[[current_column]])
      if (any(grepl("[0-9]{4}", current_values))) {
        return(current_column)
      }
    }

    return(NA)
  }

  extract_supp2_apc <- function(joinpoint_result, indicator, measure_name) {
    apc_table <- joinpoint_result[["APC"]]

    if (is.null(apc_table)) {
      stop(
        "APC table was not found in the Joinpoint result for ",
        indicator,
        ".",
        call. = FALSE
      )
    }

    location_col <- find_column(
      apc_table,
      c("location", "Location", "location_name")
    )

    age_col <- find_column(
      apc_table,
      c("age", "Age", "age_name")
    )

    apc_col <- find_column(
      apc_table,
      c("APC", "apc")
    )

    lower_col <- find_column(
      apc_table,
      c(
        "lower", "lower_CI", "Lower_CI", "APC_lower",
        "APC_LCI", "LCI", "lci", "APC_95CI_lower"
      )
    )

    upper_col <- find_column(
      apc_table,
      c(
        "upper", "upper_CI", "Upper_CI", "APC_upper",
        "APC_UCI", "UCI", "uci", "APC_95CI_upper"
      )
    )

    p_col <- find_column(
      apc_table,
      c(
        "P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"
      ),
      required = FALSE
    )

    start_col <- find_column(
      apc_table,
      c(
        "start", "Start", "startyear", "Startyear", "StartYear",
        "start_year", "Start_year", "year_start", "Year_start",
        "from", "From", "begin", "Begin"
      ),
      required = FALSE
    )

    end_col <- find_column(
      apc_table,
      c(
        "end", "End", "endyear", "Endyear", "EndYear",
        "end_year", "End_year", "year_end", "Year_end",
        "to", "To", "finish", "Finish"
      ),
      required = FALSE
    )

    time_col <- find_column(
      apc_table,
      c(
        "Time", "time", "Period", "period", "Years", "years",
        "Year", "year", "APC_period", "apc_period", "trend_period",
        "Trend_period", "range", "Range"
      ),
      required = FALSE
    )

    if (is.na(time_col)) {
      time_col <- find_time_column(
        apc_table,
        excluded_columns = c(
          location_col, age_col, apc_col, lower_col, upper_col, p_col,
          start_col, end_col
        )
      )
    }

    if (!is.na(start_col) && !is.na(end_col)) {
      start_year <- as.numeric(as.character(apc_table[[start_col]]))
      end_year <- as.numeric(as.character(apc_table[[end_col]]))
      time_text <- paste(start_year, end_year, sep = " to ")
    } else if (!is.na(time_col)) {
      time_text <- as.character(apc_table[[time_col]])
      year_bounds <- extract_year_bounds_from_text(time_text)
      start_year <- year_bounds$Start_year
      end_year <- year_bounds$End_year
    } else {
      stop(
        "Cannot identify APC segment time columns in result[['APC']] for ",
        indicator,
        ". Please inspect the column names of result[['APC']].",
        call. = FALSE
      )
    }

    out <- data.frame(
      Location = as.character(apc_table[[location_col]]),
      Age_raw = as.character(apc_table[[age_col]]),
      Indicator = indicator,
      Measure = measure_name,
      Time = time_text,
      Start_year = start_year,
      End_year = end_year,
      APC = as.numeric(as.character(apc_table[[apc_col]])),
      Lower = as.numeric(as.character(apc_table[[lower_col]])),
      Upper = as.numeric(as.character(apc_table[[upper_col]])),
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(apc_table[[p_col]]))
    } else {
      out$P_value <- NA
    }

    out <- out[
      out$Location %in% supp2_location_order &
        out$Age_raw == table1_region_age_order,
      ,
      drop = FALSE
    ]

    out$Age <- "<5"
    out$P_value_formatted <- format_p_value(out$P_value)
    out$APC_95CI <- make_aapc_ci_text(out$APC, out$Lower, out$Upper)

    out$Location <- factor(
      out$Location,
      levels = supp2_location_order,
      ordered = TRUE
    )

    out$Indicator <- factor(
      out$Indicator,
      levels = c("ASIR", "ASMR", "ASYR"),
      ordered = TRUE
    )

    out <- out[
      order(
        out$Location,
        out$Indicator,
        out$Start_year,
        out$End_year,
        out$Time
      ),
      ,
      drop = FALSE
    ]

    out$Location <- as.character(out$Location)
    out$Indicator <- as.character(out$Indicator)

    if (nrow(out) > 0) {
      series_key <- paste(
        out$Location,
        out$Age,
        out$Indicator,
        sep = "___"
      )

      out$Segment <- ave(
        seq_len(nrow(out)),
        series_key,
        FUN = seq_along
      )
    } else {
      out$Segment <- integer(0)
    }

    out <- out[
      ,
      c(
        "Location", "Age", "Indicator", "Measure",
        "Segment", "Time", "Start_year", "End_year",
        "P_value", "P_value_formatted",
        "APC", "Lower", "Upper", "APC_95CI"
      ),
      drop = FALSE
    ]

    return(out)
  }


  filter_table1_input_data <- function(data, measure_name) {
    common_selection <- (
      as.character(data$sex) == SEX_NAME &
        as.character(data$cause) == CAUSE_NAME &
        as.character(data$metric) == METRIC_NAME &
        as.character(data$measure) == measure_name &
        as.numeric(data$year) >= START_YEAR &
        as.numeric(data$year) <= END_YEAR
    )

    global_selection <- (
      as.character(data$location) == LOCATION_NAME &
        as.character(data$age) %in% table1_global_age_order
    )

    region_selection <- (
      as.character(data$location) %in% table1_region_location_order &
        as.character(data$age) == table1_region_age_order
    )

    selected <- data[
      common_selection & (global_selection | region_selection),
      ,
      drop = FALSE
    ]

    if (nrow(selected) == 0) {
      stop(
        "No data remained after filtering revised Table 1 data for measure: ",
        measure_name,
        call. = FALSE
      )
    }

    check_total_meningitis_rows(selected, "Revised Table 1 input dataset")

    selected$location <- factor(
      as.character(selected$location),
      levels = table1_location_order,
      ordered = TRUE
    )

    selected$age <- factor(
      as.character(selected$age),
      levels = table1_global_age_order,
      ordered = TRUE
    )

    selected <- selected[
      order(selected$location, selected$age, as.numeric(selected$year)),
      ,
      drop = FALSE
    ]

    rownames(selected) <- NULL
    return(selected)
  }

  check_table1_joinpoint_input <- function(data, measure_name) {
    data$val <- as.numeric(as.character(data$val))

    if (any(is.na(data$val)) || any(!is.finite(data$val))) {
      stop(
        "Column 'val' contains missing or non-finite values for revised Table 1 measure: ",
        measure_name,
        call. = FALSE
      )
    }

    if (any(data$val <= 0)) {
      stop(
        "Zero or negative rate values were found for revised Table 1 measure: ",
        measure_name,
        ". The log-linear Joinpoint model requires strictly positive values.",
        call. = FALSE
      )
    }

    required_years <- seq(START_YEAR, END_YEAR)

    time_series_key <- paste(
      as.character(data$location),
      as.character(data$age),
      sep = "___"
    )

    duplicate_key <- paste(time_series_key, data$year, sep = "___")

    if (anyDuplicated(duplicate_key) > 0) {
      stop(
        "Duplicate location-age-year observations were found for revised Table 1 measure: ",
        measure_name,
        call. = FALSE
      )
    }

    years_by_series <- split(as.numeric(data$year), time_series_key)

    incomplete_series <- names(years_by_series)[
      vapply(
        years_by_series,
        function(years) {
          !identical(sort(unique(years)), required_years)
        },
        logical(1)
      )
    ]

    if (length(incomplete_series) > 0) {
      stop(
        "The following revised Table 1 time series do not contain every year from ",
        START_YEAR, " through ", END_YEAR, " for measure ", measure_name, ":\n",
        paste(incomplete_series, collapse = "\n"),
        call. = FALSE
      )
    }

    invisible(TRUE)
  }

  extract_table1_aapc <- function(joinpoint_result, indicator, measure_name) {
    aapc_table <- joinpoint_result[["AAPC"]]

    if (is.null(aapc_table)) {
      stop("AAPC table was not found in the Joinpoint result for ", indicator, ".", call. = FALSE)
    }

    location_col <- find_column(aapc_table, c("location", "Location", "location_name"))
    age_col      <- find_column(aapc_table, c("age", "Age", "age_name"))
    aapc_col     <- find_column(aapc_table, c("AAPC", "aapc"))
    lower_col    <- find_column(
      aapc_table,
      c("lower", "lower_CI", "Lower_CI", "AAPC_lower",
        "AAPC_LCI", "LCI", "lci", "AAPC_95CI_lower")
    )
    upper_col    <- find_column(
      aapc_table,
      c("upper", "upper_CI", "Upper_CI", "AAPC_upper",
        "AAPC_UCI", "UCI", "uci", "AAPC_95CI_upper")
    )
    p_col        <- find_column(
      aapc_table,
      c("P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"),
      required = FALSE
    )

    out <- data.frame(
      Location = as.character(aapc_table[[location_col]]),
      Age_raw = as.character(aapc_table[[age_col]]),
      Indicator = indicator,
      Measure = measure_name,
      Time = paste0(START_YEAR, "-", END_YEAR),
      AAPC = as.numeric(as.character(aapc_table[[aapc_col]])),
      Lower = as.numeric(as.character(aapc_table[[lower_col]])),
      Upper = as.numeric(as.character(aapc_table[[upper_col]])),
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(aapc_table[[p_col]]))
    } else {
      out$P_value <- NA
    }

    keep_global <- (
      out$Location == LOCATION_NAME &
        out$Age_raw %in% table1_global_age_order
    )

    keep_region <- (
      out$Location %in% table1_region_location_order &
        out$Age_raw == table1_region_age_order
    )

    out <- out[keep_global | keep_region, , drop = FALSE]

    out$Age <- age_display[out$Age_raw]
    out$Age[is.na(out$Age) & out$Age_raw == table1_region_age_order] <- "<5"

    out$P_value_formatted <- format_p_value(out$P_value)
    out$AAPC_95CI <- make_aapc_ci_text(out$AAPC, out$Lower, out$Upper)

    out$Location <- factor(
      out$Location,
      levels = table1_location_order,
      ordered = TRUE
    )

    out$Age <- factor(
      out$Age,
      levels = age_output_order,
      ordered = TRUE
    )

    out <- out[order(out$Location, out$Age), , drop = FALSE]
    out$Location <- as.character(out$Location)
    out$Age <- as.character(out$Age)

    out <- out[
      ,
      c(
        "Location", "Age", "Indicator", "Measure", "Time",
        "P_value", "P_value_formatted",
        "AAPC", "Lower", "Upper", "AAPC_95CI"
      ),
      drop = FALSE
    ]

    return(out)
  }

  table1_long_results <- list()
  supp2_long_results <- list()

  for (i in seq_along(measure_specs)) {
    current_spec <- measure_specs[[i]]

    cat("\n=================================================================\n")
    cat("Extracting revised Table 1 AAPC for ", current_spec$indicator, "\n", sep = "")
    cat("Measure: ", current_spec$measure_name, "\n", sep = "")
    cat("=================================================================\n")

    table1_input <- filter_table1_input_data(gbd_data, current_spec$measure_name)
    check_table1_joinpoint_input(table1_input, current_spec$measure_name)

    # This model includes separate location-age time series:
    #   Global x 8 ages
    #   26 SDI/GBD-region locations x under-five total age
    analysis_label_table1 <- paste(
      "Table 1 and Supplementary Table 2",
      current_spec$indicator,
      current_spec$measure_name,
      sep = " - "
    )

    component_prefix_table1 <- paste(
      "Table1_SupplementaryTable2",
      current_spec$indicator,
      sep = "_"
    )

    cat("\nRunning complete Joinpoint core step for: ", analysis_label_table1, "\n", sep = "")

    result_table1_current <- GBDage_aapc(
      data = table1_input,
      startyear = START_YEAR,
      endyear = END_YEAR,
      model = MODEL_TYPE,
      joinpoints = N_JOINPOINTS,
      rei_included = FALSE,
      CI = CALCULATE_CI,
      digits = ROUND_DIGITS,
      sep = " to ",
      constant_variance = CONSTANT_VARIANCE,
      AAPCrange = NULL
    )

    validate_joinpoint_result(
      joinpoint_result = result_table1_current,
      analysis_label = analysis_label_table1,
      require_aapc_range = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_table1_current[["AAPC"]],
        "AAPC",
        component_prefix_table1
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_table1, "AAPC"),
      row.names = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_table1_current[["AAPC_Range"]],
        "AAPC_Range",
        component_prefix_table1
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_table1, "AAPC_Range"),
      row.names = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_table1_current[["APC"]],
        "APC",
        component_prefix_table1
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_table1, "APC"),
      row.names = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_table1_current[["data"]],
        "data",
        component_prefix_table1
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_table1, "data"),
      row.names = FALSE
    )

    table1_joinpoint <- result_table1_current

    table1_long_results[[current_spec$indicator]] <- extract_table1_aapc(
      joinpoint_result = table1_joinpoint,
      indicator = current_spec$indicator,
      measure_name = current_spec$measure_name
    )

    # Supplementary Table 2 reads APC directly from the Table 1 Joinpoint result.
    # No additional Joinpoint analysis is performed here.
    supp2_long_results[[current_spec$indicator]] <- extract_supp2_apc(
      joinpoint_result = table1_joinpoint,
      indicator = current_spec$indicator,
      measure_name = current_spec$measure_name
    )
  }

  table1_long <- do.call(rbind, table1_long_results)
  rownames(table1_long) <- NULL

  table1_long$Location <- factor(
    table1_long$Location,
    levels = table1_location_order,
    ordered = TRUE
  )

  table1_long$Age <- factor(
    table1_long$Age,
    levels = age_output_order,
    ordered = TRUE
  )

  table1_long$Indicator <- factor(
    table1_long$Indicator,
    levels = c("ASIR", "ASMR", "ASYR"),
    ordered = TRUE
  )

  table1_long <- table1_long[
    order(table1_long$Location, table1_long$Age, table1_long$Indicator),
    ,
    drop = FALSE
  ]

  table1_long$Location <- as.character(table1_long$Location)
  table1_long$Age <- as.character(table1_long$Age)
  table1_long$Indicator <- as.character(table1_long$Indicator)

  table1_long_file <- file.path(
    output_dir,
    "Table_1_Global_ASIR_ASMR_ASYR_AAPC_1990_2021_long.csv"
  )

  write.csv(table1_long, file = table1_long_file, row.names = FALSE)

  table1_wide <- unique(table1_long[, c("Location", "Age", "Time"), drop = FALSE])

  for (current_indicator in c("ASIR", "ASMR", "ASYR")) {
    current_rows <- table1_long[
      table1_long$Indicator == current_indicator,
      c("Location", "Age", "Time", "P_value_formatted", "AAPC_95CI"),
      drop = FALSE
    ]

    names(current_rows)[names(current_rows) == "P_value_formatted"] <-
      paste0(current_indicator, "_P_value")

    names(current_rows)[names(current_rows) == "AAPC_95CI"] <-
      paste0(current_indicator, "_AAPC_95CI")

    table1_wide <- merge(
      table1_wide,
      current_rows,
      by = c("Location", "Age", "Time"),
      all.x = TRUE
    )
  }

  table1_wide$Location <- factor(
    table1_wide$Location,
    levels = table1_location_order,
    ordered = TRUE
  )

  table1_wide$Age <- factor(
    table1_wide$Age,
    levels = age_output_order,
    ordered = TRUE
  )

  table1_wide <- table1_wide[
    order(table1_wide$Location, table1_wide$Age),
    ,
    drop = FALSE
  ]

  table1_wide$Location <- as.character(table1_wide$Location)
  table1_wide$Age <- as.character(table1_wide$Age)

  table1_wide_file <- file.path(
    output_dir,
    "Table_1_Global_ASIR_ASMR_ASYR_AAPC_1990_2021_wide.csv"
  )

  write.csv(table1_wide, file = table1_wide_file, row.names = FALSE)

  # ---------------------------------------------------------------------------
  # Supplementary Table 2:
  # APC of ASIR, ASMR and ASYR among children under 5 years in
  # Global, Low SDI and Low-middle SDI, 1990-2021.
  # This uses result[["APC"]] from the Table 1 Joinpoint objects above.
  # ---------------------------------------------------------------------------

  supp2_long <- do.call(rbind, supp2_long_results)
  rownames(supp2_long) <- NULL

  supp2_long$Location <- factor(
    supp2_long$Location,
    levels = supp2_location_order,
    ordered = TRUE
  )

  supp2_long$Indicator <- factor(
    supp2_long$Indicator,
    levels = c("ASIR", "ASMR", "ASYR"),
    ordered = TRUE
  )

  supp2_long <- supp2_long[
    order(
      supp2_long$Location,
      supp2_long$Indicator,
      supp2_long$Start_year,
      supp2_long$End_year,
      supp2_long$Time
    ),
    ,
    drop = FALSE
  ]

  supp2_long$Location <- as.character(supp2_long$Location)
  supp2_long$Indicator <- as.character(supp2_long$Indicator)

  supp2_long_file <- file.path(
    output_dir,
    "Supplementary_Table_2_Global_LowSDI_LowMiddleSDI_Under5_ASIR_ASMR_ASYR_APC_1990_2021_long.csv"
  )

  write.csv(supp2_long, file = supp2_long_file, row.names = FALSE)

  supp2_wide <- unique(
    supp2_long[
      ,
      c("Location", "Age", "Time", "Start_year", "End_year"),
      drop = FALSE
    ]
  )

  for (current_indicator in c("ASIR", "ASMR", "ASYR")) {
    current_rows <- supp2_long[
      supp2_long$Indicator == current_indicator,
      c(
        "Location", "Age", "Time", "Start_year", "End_year",
        "P_value_formatted", "APC_95CI"
      ),
      drop = FALSE
    ]

    names(current_rows)[names(current_rows) == "P_value_formatted"] <-
      paste0(current_indicator, "_P_value")

    names(current_rows)[names(current_rows) == "APC_95CI"] <-
      paste0(current_indicator, "_APC_95CI")

    supp2_wide <- merge(
      supp2_wide,
      current_rows,
      by = c("Location", "Age", "Time", "Start_year", "End_year"),
      all = TRUE
    )
  }

  supp2_wide$Location <- factor(
    supp2_wide$Location,
    levels = supp2_location_order,
    ordered = TRUE
  )

  supp2_wide <- supp2_wide[
    order(
      supp2_wide$Location,
      supp2_wide$Start_year,
      supp2_wide$End_year,
      supp2_wide$Time
    ),
    ,
    drop = FALSE
  ]

  supp2_wide$Location <- as.character(supp2_wide$Location)

  supp2_wide_file <- file.path(
    output_dir,
    "Supplementary_Table_2_Global_LowSDI_LowMiddleSDI_Under5_ASIR_ASMR_ASYR_APC_1990_2021_wide.csv"
  )

  write.csv(supp2_wide, file = supp2_wide_file, row.names = FALSE)


  cat("Saved revised Table 1 and Supplementary Table 2 files:\n")
  cat("  ", normalizePath(table1_long_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(table1_wide_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp2_long_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp2_wide_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
}

# -----------------------------------------------------------------------------
# 6. Supplementary Table 4: country-level under-five ASIR, ASMR and ASYR
# -----------------------------------------------------------------------------

make_supp4_outputs <- function(supp4_input_folder, output_dir) {
  required_columns <- c(
    "location", "sex", "age", "cause", "measure",
    "metric", "year", "val"
  )

  gbd_data <- read_gbd_folder(supp4_input_folder, required_columns)

  assert_values_exist(gbd_data, "sex", SEX_NAME)
  assert_values_exist(gbd_data, "cause", CAUSE_NAME)
  assert_values_exist(gbd_data, "metric", METRIC_NAME)

  measure_specs <- list(
    list(indicator = "ASIR", measure_name = "Incidence"),
    list(indicator = "ASMR", measure_name = "Deaths"),
    list(indicator = "ASYR", measure_name = "YLDs (Years Lived with Disability)")
  )

  requested_measures <- vapply(
    measure_specs,
    function(x) x$measure_name,
    character(1)
  )

  assert_values_exist(gbd_data, "measure", requested_measures)

  under5_age_label <- resolve_age_label(
    unique(gbd_data$age),
    c("<5", "< 5", "<5 years", "Under 5", "Under 5 years",
      "0 to 4", "0 to 4 years", "0-4 years"),
    "under-five total age group for Supplementary Table 4"
  )

  aggregate_locations <- c(
    "Global",
    "High SDI",
    "High-middle SDI",
    "Middle SDI",
    "Low-middle SDI",
    "Low SDI",
    "High-income Asia Pacific",
    "High-income North America",
    "Western Europe",
    "Central Europe",
    "Eastern Europe",
    "Australasia",
    "East Asia",
    "Southeast Asia",
    "South Asia",
    "Central Asia",
    "North Africa and Middle East",
    "Oceania",
    "Andean Latin America",
    "Central Latin America",
    "Tropical Latin America",
    "Southern Latin America",
    "Caribbean",
    "Central Sub-Saharan Africa",
    "Eastern Sub-Saharan Africa",
    "Southern Sub-Saharan Africa",
    "Western Sub-Saharan Africa"
  )

  country_location_order <- sort(
    setdiff(unique(gbd_data$location), aggregate_locations)
  )

  country_count <- length(country_location_order)

  if (STOP_IF_COUNTRY_COUNT_NOT_204 && country_count != 204) {
    stop(
      "The script inferred ",
      country_count,
      " country/territory locations, but 204 were expected. ",
      "Please check the downloaded location selection and the aggregate-location exclusion list.",
      call. = FALSE
    )
  }

  filter_supp4_input_data <- function(data, measure_name) {
    selected <- data[
      as.character(data$location) %in% country_location_order &
        as.character(data$sex) == SEX_NAME &
        as.character(data$cause) == CAUSE_NAME &
        as.character(data$metric) == METRIC_NAME &
        as.character(data$measure) == measure_name &
        as.character(data$age) == under5_age_label &
        as.numeric(data$year) >= START_YEAR &
        as.numeric(data$year) <= END_YEAR,
      ,
      drop = FALSE
    ]

    if (nrow(selected) == 0) {
      stop(
        "No data remained after filtering Supplementary Table 4 data for measure: ",
        measure_name,
        call. = FALSE
      )
    }

    check_total_meningitis_rows(selected, "Supplementary Table 4 input dataset")

    selected$location <- factor(
      as.character(selected$location),
      levels = country_location_order,
      ordered = TRUE
    )

    selected <- selected[
      order(selected$location, as.numeric(selected$year)),
      ,
      drop = FALSE
    ]

    rownames(selected) <- NULL
    return(selected)
  }

  check_supp4_joinpoint_input <- function(data, measure_name) {
    data$val <- as.numeric(as.character(data$val))

    if (any(is.na(data$val)) || any(!is.finite(data$val))) {
      stop(
        "Column 'val' contains missing or non-finite values for Supplementary Table 4 measure: ",
        measure_name,
        call. = FALSE
      )
    }

    if (any(data$val <= 0)) {
      stop(
        "Zero or negative rate values were found for Supplementary Table 4 measure: ",
        measure_name,
        ". The log-linear Joinpoint model requires strictly positive values.",
        call. = FALSE
      )
    }

    required_years <- seq(START_YEAR, END_YEAR)

    duplicate_key <- paste(
      as.character(data$location),
      as.numeric(data$year),
      sep = "___"
    )

    if (anyDuplicated(duplicate_key) > 0) {
      stop(
        "Duplicate location-year observations were found for Supplementary Table 4 measure: ",
        measure_name,
        call. = FALSE
      )
    }

    years_by_location <- split(as.numeric(data$year), as.character(data$location))

    incomplete_locations <- names(years_by_location)[
      vapply(
        years_by_location,
        function(years) {
          !identical(sort(unique(years)), required_years)
        },
        logical(1)
      )
    ]

    if (length(incomplete_locations) > 0) {
      stop(
        "Some country/territory time series do not contain every year from ",
        START_YEAR, " through ", END_YEAR, " for measure ", measure_name, ".\n",
        paste(incomplete_locations, collapse = "\n"),
        call. = FALSE
      )
    }

    invisible(TRUE)
  }

  extract_supp4_aapc <- function(joinpoint_result, indicator, measure_name) {
    aapc_table <- joinpoint_result[["AAPC"]]

    if (is.null(aapc_table)) {
      stop("AAPC table was not found in the Joinpoint result for ", indicator, ".", call. = FALSE)
    }

    location_col <- find_column(aapc_table, c("location", "Location", "location_name"))
    aapc_col     <- find_column(aapc_table, c("AAPC", "aapc"))
    lower_col    <- find_column(
      aapc_table,
      c("lower", "lower_CI", "Lower_CI", "AAPC_lower",
        "AAPC_LCI", "LCI", "lci", "AAPC_95CI_lower")
    )
    upper_col    <- find_column(
      aapc_table,
      c("upper", "upper_CI", "Upper_CI", "AAPC_upper",
        "AAPC_UCI", "UCI", "uci", "AAPC_95CI_upper")
    )
    p_col        <- find_column(
      aapc_table,
      c("P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"),
      required = FALSE
    )

    out <- data.frame(
      Location = as.character(aapc_table[[location_col]]),
      Indicator = indicator,
      Measure = measure_name,
      Time = paste0(START_YEAR, "-", END_YEAR),
      AAPC = as.numeric(as.character(aapc_table[[aapc_col]])),
      Lower = as.numeric(as.character(aapc_table[[lower_col]])),
      Upper = as.numeric(as.character(aapc_table[[upper_col]])),
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(aapc_table[[p_col]]))
    } else {
      out$P_value <- NA
    }

    out <- out[out$Location %in% country_location_order, , drop = FALSE]
    out$P_value_formatted <- format_p_value(out$P_value)
    out$AAPC_95CI <- make_aapc_ci_text(out$AAPC, out$Lower, out$Upper)

    out$Location <- factor(out$Location, levels = country_location_order, ordered = TRUE)
    out <- out[order(out$Location), , drop = FALSE]
    out$Location <- as.character(out$Location)

    out <- out[
      ,
      c(
        "Location", "Indicator", "Measure", "Time",
        "P_value", "P_value_formatted",
        "AAPC", "Lower", "Upper", "AAPC_95CI"
      ),
      drop = FALSE
    ]

    return(out)
  }

  supp4_long_results <- list()

  for (i in seq_along(measure_specs)) {
    current_spec <- measure_specs[[i]]

    cat("\n=================================================================\n")
    cat("Extracting Supplementary Table 4 AAPC for ", current_spec$indicator, "\n", sep = "")
    cat("Measure: ", current_spec$measure_name, "\n", sep = "")
    cat("=================================================================\n")

    supp4_input <- filter_supp4_input_data(gbd_data, current_spec$measure_name)
    check_supp4_joinpoint_input(supp4_input, current_spec$measure_name)

    analysis_label_supp4 <- paste(
      "Supplementary Table 4",
      current_spec$indicator,
      current_spec$measure_name,
      sep = " - "
    )

    component_prefix_supp4 <- paste(
      "SupplementaryTable4",
      current_spec$indicator,
      sep = "_"
    )

    cat("\nRunning complete Joinpoint core step for: ", analysis_label_supp4, "\n", sep = "")

    result_supp4_current <- GBDage_aapc(
      data = supp4_input,
      startyear = START_YEAR,
      endyear = END_YEAR,
      model = MODEL_TYPE,
      joinpoints = N_JOINPOINTS,
      rei_included = FALSE,
      CI = CALCULATE_CI,
      digits = ROUND_DIGITS,
      sep = " to ",
      constant_variance = CONSTANT_VARIANCE,
      AAPCrange = NULL
    )

    validate_joinpoint_result(
      joinpoint_result = result_supp4_current,
      analysis_label = analysis_label_supp4,
      require_aapc_range = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_supp4_current[["AAPC"]],
        "AAPC",
        component_prefix_supp4
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_supp4, "AAPC"),
      row.names = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_supp4_current[["AAPC_Range"]],
        "AAPC_Range",
        component_prefix_supp4
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_supp4, "AAPC_Range"),
      row.names = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_supp4_current[["APC"]],
        "APC",
        component_prefix_supp4
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_supp4, "APC"),
      row.names = FALSE
    )

    write.csv(
      coerce_joinpoint_component_to_data_frame(
        result_supp4_current[["data"]],
        "data",
        component_prefix_supp4
      ),
      file = joinpoint_raw_component_file(output_dir, component_prefix_supp4, "data"),
      row.names = FALSE
    )

    supp4_joinpoint <- result_supp4_current

    supp4_long_results[[current_spec$indicator]] <- extract_supp4_aapc(
      joinpoint_result = supp4_joinpoint,
      indicator = current_spec$indicator,
      measure_name = current_spec$measure_name
    )
  }

  supp4_long <- do.call(rbind, supp4_long_results)
  rownames(supp4_long) <- NULL

  supp4_long_file <- file.path(
    output_dir,
    "Supplementary_Table_4_Country_ASIR_ASMR_ASYR_AAPC_1990_2021_long.csv"
  )

  write.csv(supp4_long, file = supp4_long_file, row.names = FALSE)

  supp4_wide <- unique(supp4_long[, c("Location", "Time"), drop = FALSE])

  for (current_indicator in c("ASIR", "ASMR", "ASYR")) {
    current_rows <- supp4_long[
      supp4_long$Indicator == current_indicator,
      c("Location", "Time", "P_value_formatted", "AAPC_95CI"),
      drop = FALSE
    ]

    names(current_rows)[names(current_rows) == "P_value_formatted"] <-
      paste0(current_indicator, "_P_value")

    names(current_rows)[names(current_rows) == "AAPC_95CI"] <-
      paste0(current_indicator, "_AAPC_95CI")

    supp4_wide <- merge(
      supp4_wide,
      current_rows,
      by = c("Location", "Time"),
      all.x = TRUE
    )
  }

  supp4_wide$Location <- factor(
    supp4_wide$Location,
    levels = country_location_order,
    ordered = TRUE
  )

  supp4_wide <- supp4_wide[order(supp4_wide$Location), , drop = FALSE]
  supp4_wide$Location <- as.character(supp4_wide$Location)

  supp4_wide_file <- file.path(
    output_dir,
    "Supplementary_Table_4_Country_ASIR_ASMR_ASYR_AAPC_1990_2021_wide.csv"
  )

  write.csv(supp4_wide, file = supp4_wide_file, row.names = FALSE)

  cat("Saved Supplementary Table 4 files:\n")
  cat("  ", normalizePath(supp4_long_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp4_wide_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
}


# -----------------------------------------------------------------------------
# 7. Supplementary Table 9:
#    AAPC of prevalence of impairments attributed to meningitis among children
#    under 5 years, globally and regionally, 1990-2021
# -----------------------------------------------------------------------------

make_supp9_outputs <- function(supp9_input_folder, output_dir) {
  required_columns <- c(
    "location", "sex", "age", "measure",
    "metric", "year", "val"
  )

  gbd_data <- read_gbd_folder(supp9_input_folder, required_columns)

  # If the impairment/sequela file does not include a cause column, create one
  # for compatibility with easyGBDR::GBDage_aapc().
  if (!("cause" %in% names(gbd_data))) {
    gbd_data$cause <- CAUSE_NAME
  }

  supp9_region_location_order <- c(
    "High SDI",
    "High-middle SDI",
    "Middle SDI",
    "Low-middle SDI",
    "Low SDI",
    "High-income Asia Pacific",
    "High-income North America",
    "Western Europe",
    "Australasia",
    "Andean Latin America",
    "Tropical Latin America",
    "Central Latin America",
    "Southern Latin America",
    "Caribbean",
    "Central Europe",
    "Eastern Europe",
    "Central Asia",
    "North Africa and Middle East",
    "South Asia",
    "Southeast Asia",
    "East Asia",
    "Oceania",
    "Western Sub-Saharan Africa",
    "Eastern Sub-Saharan Africa",
    "Central Sub-Saharan Africa",
    "Southern Sub-Saharan Africa"
  )

  supp9_location_order <- c(LOCATION_NAME, supp9_region_location_order)

  supp9_global_impairment_order <- c(
    "Epilepsy",
    "Hearing loss",
    "Mild hearing loss",
    "Moderate hearing loss",
    "Moderately severe hearing loss",
    "Severe hearing loss",
    "Profound hearing loss",
    "Complete hearing loss",
    "Developmental intellectual disability",
    "Borderline intellectual disability",
    "Mild intellectual disability",
    "Moderate intellectual disability",
    "Severe intellectual disability",
    "Blindness and vision loss",
    "Moderate vision loss",
    "Severe vision loss",
    "Blindness"
  )

  supp9_region_impairment_order <- c(
    "Epilepsy",
    "Hearing loss",
    "Developmental intellectual disability",
    "Blindness and vision loss"
  )

  supp9_all_impairment_order <- unique(c(
    supp9_global_impairment_order,
    supp9_region_impairment_order
  ))

  # Candidate columns in which GBD exports may store impairment/sequela names.
  impairment_column_candidates <- c(
    "sequela",
    "sequela_name",
    "impairment",
    "impairment_name",
    "health_state",
    "health_state_name",
    "rei",
    "cause"
  )

  available_impairment_columns <- impairment_column_candidates[
    impairment_column_candidates %in% names(gbd_data)
  ]

  if (length(available_impairment_columns) == 0) {
    stop(
      "Cannot find an impairment/sequela column for Supplementary Table 9. ",
      "Expected one of: ",
      paste(impairment_column_candidates, collapse = ", "),
      "\nAvailable columns are:\n",
      paste(names(gbd_data), collapse = " | "),
      call. = FALSE
    )
  }

  impairment_col <- NA

  for (candidate_col in available_impairment_columns) {
    candidate_values <- unique(as.character(gbd_data[[candidate_col]]))
    if (length(intersect(candidate_values, supp9_all_impairment_order)) > 0) {
      impairment_col <- candidate_col
      break
    }
  }

  if (is.na(impairment_col)) {
    stop(
      "An impairment/sequela column was found, but none of the expected ",
      "Supplementary Table 9 impairment names were detected.\n",
      "Checked columns: ",
      paste(available_impairment_columns, collapse = ", "),
      "\nExpected impairment values include:\n",
      paste(supp9_all_impairment_order, collapse = " | "),
      call. = FALSE
    )
  }

  cat(
    "Supplementary Table 9 impairment column detected as: ",
    impairment_col,
    "\n",
    sep = ""
  )

  gbd_data$Impairment <- as.character(gbd_data[[impairment_col]])

  # GBDage_aapc() uses the rei field when rei_included = TRUE. Copy the
  # impairment/sequela category into rei so that the single model below estimates
  # separate Location x Impairment time series.
  gbd_data$rei <- gbd_data$Impairment

  # If cause is a true cause column, filter to meningitis. If the impairment
  # itself is stored in the cause column, do not filter it away.
  if ("cause" %in% names(gbd_data) && impairment_col != "cause") {
    if (CAUSE_NAME %in% unique(as.character(gbd_data$cause))) {
      gbd_data <- gbd_data[as.character(gbd_data$cause) == CAUSE_NAME, , drop = FALSE]
    }
  }

  # If cause did not contain Meningitis or the impairment column was cause,
  # set cause to Meningitis for Joinpoint model compatibility.
  gbd_data$cause <- CAUSE_NAME

  assert_values_exist(gbd_data, "location", supp9_location_order)
  assert_values_exist(gbd_data, "sex", SEX_NAME)
  assert_values_exist(gbd_data, "measure", "Prevalence")

  # Prefer prevalence rate. If the downloaded file only contains Number,
  # the script uses Number and records this in the Measure/Metric columns.
  supp9_metric_candidates <- c("Rate", "Number")
  available_metrics <- unique(as.character(gbd_data$metric))
  matched_metrics <- supp9_metric_candidates[
    supp9_metric_candidates %in% available_metrics
  ]

  if (length(matched_metrics) == 0) {
    stop(
      "Supplementary Table 9 requires metric 'Rate' or 'Number'. ",
      "Available metric values are:\n",
      paste(available_metrics, collapse = " | "),
      call. = FALSE
    )
  }

  supp9_metric_name <- matched_metrics[1]

  if (supp9_metric_name != "Rate") {
    warning(
      "Supplementary Table 9 is using metric '",
      supp9_metric_name,
      "' because 'Rate' was not found in the input data.",
      call. = FALSE
    )
  }

  assert_values_exist(gbd_data, "rei", supp9_all_impairment_order)

  supp9_under5_age_label <- resolve_age_label(
    unique(gbd_data$age),
    c("<5", "< 5", "<5 years", "Under 5", "Under 5 years",
      "0 to 4", "0-4 years", "0 to 4 years"),
    "the under-five age group for Supplementary Table 9"
  )

  filter_supp9_input_data <- function(data) {
    common_selection <- (
      as.character(data$sex) == SEX_NAME &
        as.character(data$cause) == CAUSE_NAME &
        as.character(data$measure) == "Prevalence" &
        as.character(data$metric) == supp9_metric_name &
        as.character(data$age) == supp9_under5_age_label &
        as.numeric(data$year) >= START_YEAR &
        as.numeric(data$year) <= END_YEAR
    )

    global_selection <- (
      as.character(data$location) == LOCATION_NAME &
        as.character(data$rei) %in% supp9_global_impairment_order
    )

    region_selection <- (
      as.character(data$location) %in% supp9_region_location_order &
        as.character(data$rei) %in% supp9_region_impairment_order
    )

    selected <- data[
      common_selection & (global_selection | region_selection),
      ,
      drop = FALSE
    ]

    if (nrow(selected) == 0) {
      stop(
        "No data remained after filtering Supplementary Table 9 input data.",
        call. = FALSE
      )
    }

    selected$location <- factor(
      as.character(selected$location),
      levels = supp9_location_order,
      ordered = TRUE
    )

    selected$rei <- factor(
      as.character(selected$rei),
      levels = supp9_all_impairment_order,
      ordered = TRUE
    )

    selected <- selected[
      order(selected$location, selected$rei, as.numeric(selected$year)),
      ,
      drop = FALSE
    ]

    rownames(selected) <- NULL
    return(selected)
  }

  check_supp9_joinpoint_input <- function(data) {
    data$val <- as.numeric(as.character(data$val))

    if (any(is.na(data$val)) || any(!is.finite(data$val))) {
      stop(
        "Missing or non-finite prevalence values were found in Supplementary Table 9 input data.",
        call. = FALSE
      )
    }

    if (any(data$val <= 0)) {
      stop(
        "Zero or negative prevalence values were found in Supplementary Table 9 input data. ",
        "The log-linear Joinpoint model requires strictly positive values.",
        call. = FALSE
      )
    }

    required_years <- seq(START_YEAR, END_YEAR)

    series_key <- paste(
      as.character(data$location),
      as.character(data$rei),
      sep = "___"
    )

    duplicate_key <- paste(series_key, as.numeric(data$year), sep = "___")

    if (anyDuplicated(duplicate_key) > 0) {
      stop(
        "Duplicate location-impairment-year observations were found ",
        "in Supplementary Table 9 input data.",
        call. = FALSE
      )
    }

    years_by_series <- split(as.numeric(data$year), series_key)

    incomplete_series <- names(years_by_series)[
      vapply(
        years_by_series,
        function(years) {
          !identical(sort(unique(years)), required_years)
        },
        logical(1)
      )
    ]

    if (length(incomplete_series) > 0) {
      stop(
        "The following Supplementary Table 9 time series do not contain every year from ",
        START_YEAR, " through ", END_YEAR, ":\n",
        paste(incomplete_series, collapse = "\n"),
        call. = FALSE
      )
    }

    invisible(TRUE)
  }

  write_supp9_raw_component <- function(joinpoint_result, component_name, output_file) {
    if (component_name %in% names(joinpoint_result) &&
        !is.null(joinpoint_result[[component_name]])) {
      write.csv(joinpoint_result[[component_name]], file = output_file, row.names = FALSE)
    } else {
      write.csv(
        data.frame(
          note = paste0(
            "result[['",
            component_name,
            "']] was not returned by GBDage_aapc() for Supplementary Table 9."
          ),
          stringsAsFactors = FALSE
        ),
        file = output_file,
        row.names = FALSE
      )
    }
  }

  extract_supp9_aapc <- function(joinpoint_result) {
    aapc_table <- joinpoint_result[["AAPC"]]

    if (is.null(aapc_table)) {
      stop(
        "AAPC table was not found in the Joinpoint result for Supplementary Table 9.",
        call. = FALSE
      )
    }

    location_col <- find_column(aapc_table, c("location", "Location", "location_name"))

    rei_col <- find_column(
      aapc_table,
      c("rei", "REI", "sequela", "Sequela", "impairment", "Impairment")
    )

    aapc_col <- find_column(aapc_table, c("AAPC", "aapc"))

    lower_col <- find_column(
      aapc_table,
      c(
        "lower", "lower_CI", "Lower_CI", "AAPC_lower",
        "AAPC_LCI", "LCI", "lci", "AAPC_95CI_lower"
      )
    )

    upper_col <- find_column(
      aapc_table,
      c(
        "upper", "upper_CI", "Upper_CI", "AAPC_upper",
        "AAPC_UCI", "UCI", "uci", "AAPC_95CI_upper"
      )
    )

    p_col <- find_column(
      aapc_table,
      c(
        "P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"
      ),
      required = FALSE
    )

    out <- data.frame(
      Location = as.character(aapc_table[[location_col]]),
      Impairment = as.character(aapc_table[[rei_col]]),
      Age = "<5",
      Measure = "Prevalence",
      Metric = supp9_metric_name,
      Time = paste0(START_YEAR, "-", END_YEAR),
      AAPC = as.numeric(as.character(aapc_table[[aapc_col]])),
      Lower = as.numeric(as.character(aapc_table[[lower_col]])),
      Upper = as.numeric(as.character(aapc_table[[upper_col]])),
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(aapc_table[[p_col]]))
    } else {
      out$P_value <- NA
    }

    keep_global <- (
      out$Location == LOCATION_NAME &
        out$Impairment %in% supp9_global_impairment_order
    )

    keep_region <- (
      out$Location %in% supp9_region_location_order &
        out$Impairment %in% supp9_region_impairment_order
    )

    out <- out[keep_global | keep_region, , drop = FALSE]

    out$P_value_formatted <- format_p_value(out$P_value)
    out$AAPC_95CI <- make_aapc_ci_text(out$AAPC, out$Lower, out$Upper)

    out$Location <- factor(
      out$Location,
      levels = supp9_location_order,
      ordered = TRUE
    )

    out$Impairment <- factor(
      out$Impairment,
      levels = supp9_all_impairment_order,
      ordered = TRUE
    )

    out <- out[order(out$Location, out$Impairment), , drop = FALSE]
    out$Location <- as.character(out$Location)
    out$Impairment <- as.character(out$Impairment)

    out <- out[
      ,
      c(
        "Location", "Impairment", "Age", "Measure", "Metric", "Time",
        "P_value", "P_value_formatted",
        "AAPC", "Lower", "Upper", "AAPC_95CI"
      ),
      drop = FALSE
    ]

    return(out)
  }

  cat("\n=================================================================\n")
  cat("Running Supplementary Table 9 GBDage_aapc(): Location x Impairment\n")
  cat("=================================================================\n")

  supp9_input <- filter_supp9_input_data(gbd_data)
  check_supp9_joinpoint_input(supp9_input)

  # ---------------------------------------------------------------------------
  # Supplementary Table 9 core Joinpoint analysis step
  # ---------------------------------------------------------------------------
  # This is one additional GBDage_aapc() call at the Location x Impairment level.
  # Global contributes 17 impairment categories; each SDI/GBD-region location
  # contributes the 4 aggregate impairment categories.
  # ---------------------------------------------------------------------------

  result_supplementary_table9 <- GBDage_aapc(
    data = supp9_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = NULL
  )

  validate_joinpoint_result(
    joinpoint_result = result_supplementary_table9,
    analysis_label = "Supplementary Table 9 - Location x Impairment prevalence",
    require_aapc_range = FALSE
  )

  supp9_raw_output_dir <- create_folder(
    file.path(output_dir, "00_joinpoint_raw_components")
  )

  supp9_raw_aapc_file <- file.path(
    supp9_raw_output_dir,
    "Supplementary_Table_9_Location_Impairment_Prevalence_result_AAPC.csv"
  )

  supp9_raw_aapc_range_file <- file.path(
    supp9_raw_output_dir,
    "Supplementary_Table_9_Location_Impairment_Prevalence_result_AAPC_Range.csv"
  )

  supp9_raw_apc_file <- file.path(
    supp9_raw_output_dir,
    "Supplementary_Table_9_Location_Impairment_Prevalence_result_APC.csv"
  )

  supp9_raw_data_file <- file.path(
    supp9_raw_output_dir,
    "Supplementary_Table_9_Location_Impairment_Prevalence_result_data.csv"
  )

  write_supp9_raw_component(
    result_supplementary_table9,
    "AAPC",
    supp9_raw_aapc_file
  )

  write_supp9_raw_component(
    result_supplementary_table9,
    "AAPC_Range",
    supp9_raw_aapc_range_file
  )

  write_supp9_raw_component(
    result_supplementary_table9,
    "APC",
    supp9_raw_apc_file
  )

  write_supp9_raw_component(
    result_supplementary_table9,
    "data",
    supp9_raw_data_file
  )

  supp9_long <- extract_supp9_aapc(result_supplementary_table9)
  rownames(supp9_long) <- NULL

  supp9_long_file <- file.path(
    output_dir,
    "Supplementary_Table_9_Global_Regions_Under5_Meningitis_Impairment_Prevalence_AAPC_1990_2021_long.csv"
  )

  write.csv(supp9_long, file = supp9_long_file, row.names = FALSE)

  supp9_wide <- supp9_long[
    ,
    c(
      "Location", "Impairment", "Age", "Measure", "Metric", "Time",
      "P_value_formatted", "AAPC_95CI"
    ),
    drop = FALSE
  ]

  names(supp9_wide)[names(supp9_wide) == "P_value_formatted"] <- "Prevalence_P_value"
  names(supp9_wide)[names(supp9_wide) == "AAPC_95CI"] <- "Prevalence_AAPC_95CI"

  supp9_wide$Location <- factor(
    supp9_wide$Location,
    levels = supp9_location_order,
    ordered = TRUE
  )

  supp9_wide$Impairment <- factor(
    supp9_wide$Impairment,
    levels = supp9_all_impairment_order,
    ordered = TRUE
  )

  supp9_wide <- supp9_wide[
    order(supp9_wide$Location, supp9_wide$Impairment),
    ,
    drop = FALSE
  ]

  supp9_wide$Location <- as.character(supp9_wide$Location)
  supp9_wide$Impairment <- as.character(supp9_wide$Impairment)

  supp9_wide_file <- file.path(
    output_dir,
    "Supplementary_Table_9_Global_Regions_Under5_Meningitis_Impairment_Prevalence_AAPC_1990_2021_wide.csv"
  )

  write.csv(supp9_wide, file = supp9_wide_file, row.names = FALSE)

  cat("Saved Supplementary Table 9 files:\n")
  cat("  ", normalizePath(supp9_long_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp9_wide_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("Saved Supplementary Table 9 raw Joinpoint component files:\n")
  cat("  ", normalizePath(supp9_raw_aapc_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp9_raw_aapc_range_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp9_raw_apc_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp9_raw_data_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
}



# -----------------------------------------------------------------------------
# 8. Supplementary Table 10:
#    Etiology-specific ASYR trends among children under 5 years, globally and
#    across 5 SDI regions, stratified by age group, APC/AAPC-range 2017-2021
# -----------------------------------------------------------------------------

make_supp10_outputs <- function(supp10_input_folder, output_dir) {
  required_columns <- c(
    "location", "sex", "age", "cause", "measure",
    "metric", "year", "rei", "val"
  )

  gbd_data <- read_gbd_folder(supp10_input_folder, required_columns)

  gbd_data$rei[gbd_data$rei == "Other bacterial pathogens"] <-
    "Other bacterial pathogen"

  supp10_location_order <- c(
    LOCATION_NAME,
    "High SDI",
    "High-middle SDI",
    "Middle SDI",
    "Low-middle SDI",
    "Low SDI"
  )

  supp10_measure_name <- "YLDs (Years Lived with Disability)"

  supp10_rei_order <- c(
    "Escherichia coli",
    "Group B streptococcus",
    "Haemophilus influenzae",
    "Klebsiella pneumoniae",
    "Listeria monocytogenes",
    "Neisseria meningitidis",
    "Other bacterial pathogen",
    "Staphylococcus aureus",
    "Streptococcus pneumoniae",
    "Viral etiologies of meningitis"
  )

  assert_values_exist(gbd_data, "location", supp10_location_order)
  assert_values_exist(gbd_data, "sex", SEX_NAME)
  assert_values_exist(gbd_data, "cause", CAUSE_NAME)
  assert_values_exist(gbd_data, "measure", supp10_measure_name)
  assert_values_exist(gbd_data, "metric", METRIC_NAME)
  assert_values_exist(gbd_data, "rei", supp10_rei_order)

  available_ages <- unique(gbd_data$age)

  age_under5 <- resolve_age_label(
    available_ages,
    c("<5", "< 5", "<5 years", "Under 5", "Under 5 years",
      "0 to 4", "0 to 4 years", "0-4 years"),
    "under-five total age group for Supplementary Table 10"
  )

  age_neonatal <- resolve_age_label(
    available_ages,
    c("Neonatal", "Neonatal period", "<28 days", "< 28 days",
      "0 to 27 days", "0-27 days", "0 to 28 days"),
    "neonatal total age group for Supplementary Table 10"
  )

  age_early_neonatal <- resolve_age_label(
    available_ages,
    c("Early Neonatal", "Early neonatal", "0 to 6 days", "0-6 days", "0 to 6"),
    "early neonatal age group for Supplementary Table 10"
  )

  age_late_neonatal <- resolve_age_label(
    available_ages,
    c("Late Neonatal", "Late neonatal", "7 to 27 days", "7-27 days", "7 to 27"),
    "late neonatal age group for Supplementary Table 10"
  )

  age_1_to_5_months <- resolve_age_label(
    available_ages,
    c("1 to 5 months", "1-5 months"),
    "1 to 5 months age group for Supplementary Table 10"
  )

  age_6_to_11_months <- resolve_age_label(
    available_ages,
    c("6 to 11 months", "6-11 months"),
    "6 to 11 months age group for Supplementary Table 10"
  )

  age_12_to_23_months <- resolve_age_label(
    available_ages,
    c("12 to 23 months", "12-23 months"),
    "12 to 23 months age group for Supplementary Table 10"
  )

  age_2_to_4_years <- resolve_age_label(
    available_ages,
    c("2 to 4", "2 to 4 years", "2-4 years"),
    "2 to 4 years age group for Supplementary Table 10"
  )

  supp10_age_order <- c(
    age_under5,
    age_neonatal,
    age_early_neonatal,
    age_late_neonatal,
    age_1_to_5_months,
    age_6_to_11_months,
    age_12_to_23_months,
    age_2_to_4_years
  )

  supp10_age_display <- c(
    "<5",
    "<28 days",
    "0-6 days",
    "7-27 days",
    "1 to 5 months",
    "6 to 11 months",
    "12 to 23 months",
    "2 to 4 years"
  )

  names(supp10_age_display) <- supp10_age_order

  filter_supp10_input_data <- function(data) {
    selected <- data[
      as.character(data$location) %in% supp10_location_order &
        as.character(data$sex) == SEX_NAME &
        as.character(data$cause) == CAUSE_NAME &
        as.character(data$measure) == supp10_measure_name &
        as.character(data$metric) == METRIC_NAME &
        as.character(data$rei) %in% supp10_rei_order &
        as.character(data$age) %in% supp10_age_order &
        as.numeric(data$year) >= START_YEAR &
        as.numeric(data$year) <= END_YEAR,
      ,
      drop = FALSE
    ]

    if (nrow(selected) == 0) {
      stop(
        "No data remained after filtering Supplementary Table 10 input data.",
        call. = FALSE
      )
    }

    selected$location <- factor(
      as.character(selected$location),
      levels = supp10_location_order,
      ordered = TRUE
    )

    selected$rei <- factor(
      as.character(selected$rei),
      levels = supp10_rei_order,
      ordered = TRUE
    )

    selected$age <- factor(
      as.character(selected$age),
      levels = supp10_age_order,
      ordered = TRUE
    )

    selected <- selected[
      order(selected$location, selected$rei, selected$age, as.numeric(selected$year)),
      ,
      drop = FALSE
    ]

    rownames(selected) <- NULL
    return(selected)
  }

  check_supp10_joinpoint_input <- function(data) {
    data$val <- as.numeric(as.character(data$val))

    if (any(is.na(data$val)) || any(!is.finite(data$val))) {
      stop(
        "Missing or non-finite ASYR values were found in Supplementary Table 10 input data.",
        call. = FALSE
      )
    }

    if (any(data$val <= 0)) {
      stop(
        "Zero or negative ASYR values were found in Supplementary Table 10 input data. ",
        "The log-linear Joinpoint model requires strictly positive values.",
        call. = FALSE
      )
    }

    required_years <- seq(START_YEAR, END_YEAR)

    series_key <- paste(
      as.character(data$location),
      as.character(data$rei),
      as.character(data$age),
      sep = "___"
    )

    duplicate_key <- paste(series_key, as.numeric(data$year), sep = "___")

    if (anyDuplicated(duplicate_key) > 0) {
      stop(
        "Duplicate location-etiology-age-year observations were found ",
        "in Supplementary Table 10 input data.",
        call. = FALSE
      )
    }

    expected_series <- as.vector(
      outer(
        supp10_location_order,
        as.vector(outer(supp10_rei_order, supp10_age_order, paste, sep = "___")),
        paste,
        sep = "___"
      )
    )

    available_series <- unique(series_key)
    missing_series <- setdiff(expected_series, available_series)

    if (length(missing_series) > 0) {
      stop(
        "The following Supplementary Table 10 location-etiology-age series are missing:\n",
        paste(missing_series, collapse = "\n"),
        call. = FALSE
      )
    }

    years_by_series <- split(as.numeric(data$year), series_key)

    incomplete_series <- names(years_by_series)[
      vapply(
        years_by_series,
        function(years) {
          !identical(sort(unique(years)), required_years)
        },
        logical(1)
      )
    ]

    if (length(incomplete_series) > 0) {
      stop(
        "The following Supplementary Table 10 time series do not contain every year from ",
        START_YEAR, " through ", END_YEAR, ":\n",
        paste(incomplete_series, collapse = "\n"),
        call. = FALSE
      )
    }

    invisible(TRUE)
  }

  extract_supp10_apc_2017_2021 <- function(joinpoint_result) {
    # The requested 2017-2021 value is extracted from result[['AAPC_Range']],
    # because GBDage_aapc() returns the user-specified AAPCrange interval there.
    # The final table uses the label APC_2017_2021 to match the Supplementary
    # Table 10 wording, while preserving the raw AAPC_Range CSV for review.
    aapc_range <- joinpoint_result[["AAPC_Range"]]

    if (is.null(aapc_range)) {
      stop(
        "AAPC_Range table was not found in the Joinpoint result for Supplementary Table 10.",
        call. = FALSE
      )
    }

    location_col <- find_column(
      aapc_range,
      c("location", "Location", "location_name")
    )

    rei_col <- find_column(
      aapc_range,
      c("rei", "REI", "Etiology", "Aetiology", "risk", "risk_factor")
    )

    age_col <- find_column(
      aapc_range,
      c("age", "Age", "age_name")
    )

    aapc_col <- find_column(aapc_range, c("AAPC", "aapc", "APC", "apc"))

    lower_col <- find_column(
      aapc_range,
      c(
        "lower", "lower_CI", "Lower_CI", "AAPC_lower", "AAPC_LCI",
        "APC_lower", "APC_LCI", "LCI", "lci",
        "AAPC_95CI_lower", "APC_95CI_lower"
      )
    )

    upper_col <- find_column(
      aapc_range,
      c(
        "upper", "upper_CI", "Upper_CI", "AAPC_upper", "AAPC_UCI",
        "APC_upper", "APC_UCI", "UCI", "uci",
        "AAPC_95CI_upper", "APC_95CI_upper"
      )
    )

    p_col <- find_column(
      aapc_range,
      c(
        "P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"
      ),
      required = FALSE
    )

    out <- data.frame(
      Location = as.character(aapc_range[[location_col]]),
      Etiology = as.character(aapc_range[[rei_col]]),
      Age_raw = as.character(aapc_range[[age_col]]),
      Measure = supp10_measure_name,
      Metric = METRIC_NAME,
      Time = paste0(TABLE2_AAPC_RANGE_START, "-", TABLE2_AAPC_RANGE_END),
      APC_2017_2021 = as.numeric(as.character(aapc_range[[aapc_col]])),
      Lower = as.numeric(as.character(aapc_range[[lower_col]])),
      Upper = as.numeric(as.character(aapc_range[[upper_col]])),
      Source_component = "AAPC_Range",
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(aapc_range[[p_col]]))
    } else {
      out$P_value <- NA
    }

    out <- out[
      out$Location %in% supp10_location_order &
        out$Etiology %in% supp10_rei_order &
        out$Age_raw %in% supp10_age_order,
      ,
      drop = FALSE
    ]

    out$Age <- supp10_age_display[out$Age_raw]

    out$P_value_formatted <- format_p_value(out$P_value)
    out$APC_2017_2021_95CI <- make_aapc_ci_text(
      out$APC_2017_2021,
      out$Lower,
      out$Upper
    )

    out$Location <- factor(
      out$Location,
      levels = supp10_location_order,
      ordered = TRUE
    )

    out$Etiology <- factor(
      out$Etiology,
      levels = supp10_rei_order,
      ordered = TRUE
    )

    out$Age <- factor(
      out$Age,
      levels = supp10_age_display,
      ordered = TRUE
    )

    out <- out[order(out$Etiology, out$Age, out$Location), , drop = FALSE]

    out$Location <- as.character(out$Location)
    out$Etiology <- as.character(out$Etiology)
    out$Age <- as.character(out$Age)

    out <- out[
      ,
      c(
        "Etiology", "Age", "Location", "Measure", "Metric", "Time",
        "P_value", "P_value_formatted",
        "APC_2017_2021", "Lower", "Upper", "APC_2017_2021_95CI",
        "Source_component"
      ),
      drop = FALSE
    ]

    return(out)
  }

  cat("\n=================================================================\n")
  cat("Running Supplementary Table 10 GBDage_aapc(): Location x Etiology x Age\n")
  cat("=================================================================\n")

  supp10_input <- filter_supp10_input_data(gbd_data)
  check_supp10_joinpoint_input(supp10_input)

  # ---------------------------------------------------------------------------
  # Supplementary Table 10 core Joinpoint analysis step
  # ---------------------------------------------------------------------------
  # This is one additional GBDage_aapc() call at the
  # Location x Etiology x Age level.
  # The requested 2017-2021 result is returned in result[['AAPC_Range']]
  # because AAPCrange = c(2017, 2021).
  # ---------------------------------------------------------------------------

  result_supplementary_table10 <- GBDage_aapc(
    data = supp10_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = c(TABLE2_AAPC_RANGE_START, TABLE2_AAPC_RANGE_END)
  )

  validate_joinpoint_result(
    joinpoint_result = result_supplementary_table10,
    analysis_label = "Supplementary Table 10 - Location x Etiology x Age ASYR",
    require_aapc_range = TRUE
  )

  component_prefix_supp10 <- "SupplementaryTable10_Location_Etiology_Age_ASYR_APC_2017_2021"

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table10[["AAPC"]],
      "AAPC",
      component_prefix_supp10
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp10, "AAPC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table10[["AAPC_Range"]],
      "AAPC_Range",
      component_prefix_supp10
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp10, "AAPC_Range"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table10[["APC"]],
      "APC",
      component_prefix_supp10
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp10, "APC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table10[["data"]],
      "data",
      component_prefix_supp10
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp10, "data"),
    row.names = FALSE
  )

  supp10_long <- extract_supp10_apc_2017_2021(result_supplementary_table10)
  rownames(supp10_long) <- NULL

  supp10_long_file <- file.path(
    output_dir,
    "Supplementary_Table_10_Global_5SDI_Etiology_Age_ASYR_APC_2017_2021_long.csv"
  )

  write.csv(supp10_long, file = supp10_long_file, row.names = FALSE)

  supp10_wide <- unique(
    supp10_long[
      ,
      c("Etiology", "Age", "Measure", "Metric", "Time", "Source_component"),
      drop = FALSE
    ]
  )

  for (current_location in supp10_location_order) {
    current_rows <- supp10_long[
      supp10_long$Location == current_location,
      c(
        "Etiology", "Age", "Measure", "Metric", "Time", "Source_component",
        "P_value_formatted", "APC_2017_2021_95CI"
      ),
      drop = FALSE
    ]

    current_location_prefix <- sanitize_file_part(current_location)

    names(current_rows)[names(current_rows) == "P_value_formatted"] <-
      paste0(current_location_prefix, "_P_value")

    names(current_rows)[names(current_rows) == "APC_2017_2021_95CI"] <-
      paste0(current_location_prefix, "_APC_2017_2021_95CI")

    supp10_wide <- merge(
      supp10_wide,
      current_rows,
      by = c("Etiology", "Age", "Measure", "Metric", "Time", "Source_component"),
      all.x = TRUE
    )
  }

  supp10_wide$Etiology <- factor(
    supp10_wide$Etiology,
    levels = supp10_rei_order,
    ordered = TRUE
  )

  supp10_wide$Age <- factor(
    supp10_wide$Age,
    levels = supp10_age_display,
    ordered = TRUE
  )

  supp10_wide <- supp10_wide[
    order(supp10_wide$Etiology, supp10_wide$Age),
    ,
    drop = FALSE
  ]

  supp10_wide$Etiology <- as.character(supp10_wide$Etiology)
  supp10_wide$Age <- as.character(supp10_wide$Age)

  supp10_wide_file <- file.path(
    output_dir,
    "Supplementary_Table_10_Global_5SDI_Etiology_Age_ASYR_APC_2017_2021_wide.csv"
  )

  write.csv(supp10_wide, file = supp10_wide_file, row.names = FALSE)

  cat("Saved Supplementary Table 10 files:\n")
  cat("  ", normalizePath(supp10_long_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp10_wide_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("Saved Supplementary Table 10 raw Joinpoint component files under 00_joinpoint_raw_components/.\n")
}



# -----------------------------------------------------------------------------
# 9. Supplementary Table 11:
#    Prevalence trends of meningitis-related functional impairments among
#    children under 5 years, globally and across five SDI regions, stratified by
#    age group, APC/AAPC-range 2017-2021
# -----------------------------------------------------------------------------

make_supp11_outputs <- function(supp11_input_folder, output_dir) {
  required_columns <- c(
    "location", "sex", "age", "measure",
    "metric", "year", "val"
  )

  gbd_data <- read_gbd_folder(supp11_input_folder, required_columns)

  # If the impairment/sequela file does not include a cause column, create one
  # for compatibility with easyGBDR::GBDage_aapc().
  if (!("cause" %in% names(gbd_data))) {
    gbd_data$cause <- CAUSE_NAME
  }

  supp11_location_order <- c(
    LOCATION_NAME,
    "High SDI",
    "High-middle SDI",
    "Middle SDI",
    "Low-middle SDI",
    "Low SDI"
  )

  supp11_impairment_order <- c(
    "Hearing loss",
    "Epilepsy",
    "Blindness and vision loss",
    "Developmental intellectual disability"
  )

  # Candidate columns in which GBD exports may store impairment/sequela names.
  impairment_column_candidates <- c(
    "sequela",
    "sequela_name",
    "impairment",
    "impairment_name",
    "health_state",
    "health_state_name",
    "rei",
    "cause"
  )

  available_impairment_columns <- impairment_column_candidates[
    impairment_column_candidates %in% names(gbd_data)
  ]

  if (length(available_impairment_columns) == 0) {
    stop(
      "Cannot find an impairment/sequela column for Supplementary Table 11. ",
      "Expected one of: ",
      paste(impairment_column_candidates, collapse = ", "),
      "\nAvailable columns are:\n",
      paste(names(gbd_data), collapse = " | "),
      call. = FALSE
    )
  }

  impairment_col <- NA

  for (candidate_col in available_impairment_columns) {
    candidate_values <- unique(as.character(gbd_data[[candidate_col]]))
    if (length(intersect(candidate_values, supp11_impairment_order)) > 0) {
      impairment_col <- candidate_col
      break
    }
  }

  if (is.na(impairment_col)) {
    stop(
      "An impairment/sequela column was found, but none of the expected ",
      "Supplementary Table 11 impairment names were detected.\n",
      "Checked columns: ",
      paste(available_impairment_columns, collapse = ", "),
      "\nExpected impairment values include:\n",
      paste(supp11_impairment_order, collapse = " | "),
      call. = FALSE
    )
  }

  cat(
    "Supplementary Table 11 impairment column detected as: ",
    impairment_col,
    "\n",
    sep = ""
  )

  gbd_data$Impairment <- as.character(gbd_data[[impairment_col]])

  # GBDage_aapc() uses the rei field when rei_included = TRUE. Copy the
  # impairment/sequela category into rei so that the single model below estimates
  # separate Location x Age x Impairment time series.
  gbd_data$rei <- gbd_data$Impairment

  # If cause is a true cause column, filter to meningitis. If the impairment
  # itself is stored in the cause column, do not filter it away.
  if ("cause" %in% names(gbd_data) && impairment_col != "cause") {
    if (CAUSE_NAME %in% unique(as.character(gbd_data$cause))) {
      gbd_data <- gbd_data[as.character(gbd_data$cause) == CAUSE_NAME, , drop = FALSE]
    }
  }

  # If cause did not contain Meningitis or the impairment column was cause,
  # set cause to Meningitis for Joinpoint model compatibility.
  gbd_data$cause <- CAUSE_NAME

  assert_values_exist(gbd_data, "location", supp11_location_order)
  assert_values_exist(gbd_data, "sex", SEX_NAME)
  assert_values_exist(gbd_data, "measure", "Prevalence")
  assert_values_exist(gbd_data, "rei", supp11_impairment_order)

  # Prefer prevalence rate. If the downloaded file only contains Number,
  # the script uses Number and records this in the Measure/Metric columns.
  supp11_metric_candidates <- c("Rate", "Number")
  available_metrics <- unique(as.character(gbd_data$metric))
  matched_metrics <- supp11_metric_candidates[
    supp11_metric_candidates %in% available_metrics
  ]

  if (length(matched_metrics) == 0) {
    stop(
      "Supplementary Table 11 requires metric 'Rate' or 'Number'. ",
      "Available metric values are:\n",
      paste(available_metrics, collapse = " | "),
      call. = FALSE
    )
  }

  supp11_metric_name <- matched_metrics[1]

  if (supp11_metric_name != "Rate") {
    warning(
      "Supplementary Table 11 is using metric '",
      supp11_metric_name,
      "' because 'Rate' was not found in the input data.",
      call. = FALSE
    )
  }

  available_ages <- unique(gbd_data$age)

  age_under5 <- resolve_age_label(
    available_ages,
    c("<5", "< 5", "<5 years", "Under 5", "Under 5 years",
      "0 to 4", "0 to 4 years", "0-4 years"),
    "under-five total age group for Supplementary Table 11"
  )

  age_neonatal <- resolve_age_label(
    available_ages,
    c("Neonatal", "Neonatal period", "<28 days", "< 28 days",
      "0 to 27 days", "0-27 days", "0 to 28 days"),
    "neonatal total age group for Supplementary Table 11"
  )

  age_early_neonatal <- resolve_age_label(
    available_ages,
    c("Early Neonatal", "Early neonatal", "0 to 6 days", "0-6 days", "0 to 6"),
    "early neonatal age group for Supplementary Table 11"
  )

  age_late_neonatal <- resolve_age_label(
    available_ages,
    c("Late Neonatal", "Late neonatal", "7 to 27 days", "7-27 days", "7 to 27"),
    "late neonatal age group for Supplementary Table 11"
  )

  age_1_to_5_months <- resolve_age_label(
    available_ages,
    c("1 to 5 months", "1-5 months"),
    "1 to 5 months age group for Supplementary Table 11"
  )

  age_6_to_11_months <- resolve_age_label(
    available_ages,
    c("6 to 11 months", "6-11 months"),
    "6 to 11 months age group for Supplementary Table 11"
  )

  age_12_to_23_months <- resolve_age_label(
    available_ages,
    c("12 to 23 months", "12-23 months"),
    "12 to 23 months age group for Supplementary Table 11"
  )

  age_2_to_4_years <- resolve_age_label(
    available_ages,
    c("2 to 4", "2 to 4 years", "2-4 years"),
    "2 to 4 years age group for Supplementary Table 11"
  )

  supp11_age_order <- c(
    age_under5,
    age_neonatal,
    age_early_neonatal,
    age_late_neonatal,
    age_1_to_5_months,
    age_6_to_11_months,
    age_12_to_23_months,
    age_2_to_4_years
  )

  supp11_age_display <- c(
    "<5",
    "<28 days",
    "0-6 days",
    "7-27 days",
    "1 to 5 months",
    "6 to 11 months",
    "12 to 23 months",
    "2 to 4 years"
  )

  names(supp11_age_display) <- supp11_age_order

  filter_supp11_input_data <- function(data) {
    selected <- data[
      as.character(data$location) %in% supp11_location_order &
        as.character(data$sex) == SEX_NAME &
        as.character(data$cause) == CAUSE_NAME &
        as.character(data$measure) == "Prevalence" &
        as.character(data$metric) == supp11_metric_name &
        as.character(data$rei) %in% supp11_impairment_order &
        as.character(data$age) %in% supp11_age_order &
        as.numeric(data$year) >= START_YEAR &
        as.numeric(data$year) <= END_YEAR,
      ,
      drop = FALSE
    ]

    if (nrow(selected) == 0) {
      stop(
        "No data remained after filtering Supplementary Table 11 input data.",
        call. = FALSE
      )
    }

    selected$location <- factor(
      as.character(selected$location),
      levels = supp11_location_order,
      ordered = TRUE
    )

    selected$age <- factor(
      as.character(selected$age),
      levels = supp11_age_order,
      ordered = TRUE
    )

    selected$rei <- factor(
      as.character(selected$rei),
      levels = supp11_impairment_order,
      ordered = TRUE
    )

    selected <- selected[
      order(selected$location, selected$age, selected$rei, as.numeric(selected$year)),
      ,
      drop = FALSE
    ]

    rownames(selected) <- NULL
    return(selected)
  }

  check_supp11_joinpoint_input <- function(data) {
    data$val <- as.numeric(as.character(data$val))

    if (any(is.na(data$val)) || any(!is.finite(data$val))) {
      stop(
        "Missing or non-finite prevalence values were found in Supplementary Table 11 input data.",
        call. = FALSE
      )
    }

    if (any(data$val <= 0)) {
      stop(
        "Zero or negative prevalence values were found in Supplementary Table 11 input data. ",
        "The log-linear Joinpoint model requires strictly positive values.",
        call. = FALSE
      )
    }

    required_years <- seq(START_YEAR, END_YEAR)

    series_key <- paste(
      as.character(data$location),
      as.character(data$age),
      as.character(data$rei),
      sep = "___"
    )

    duplicate_key <- paste(series_key, as.numeric(data$year), sep = "___")

    if (anyDuplicated(duplicate_key) > 0) {
      stop(
        "Duplicate location-age-impairment-year observations were found ",
        "in Supplementary Table 11 input data.",
        call. = FALSE
      )
    }

    expected_series <- as.vector(
      outer(
        supp11_location_order,
        as.vector(outer(supp11_age_order, supp11_impairment_order, paste, sep = "___")),
        paste,
        sep = "___"
      )
    )

    available_series <- unique(series_key)
    missing_series <- setdiff(expected_series, available_series)

    if (length(missing_series) > 0) {
      stop(
        "The following Supplementary Table 11 location-age-impairment series are missing:\n",
        paste(missing_series, collapse = "\n"),
        call. = FALSE
      )
    }

    years_by_series <- split(as.numeric(data$year), series_key)

    incomplete_series <- names(years_by_series)[
      vapply(
        years_by_series,
        function(years) {
          !identical(sort(unique(years)), required_years)
        },
        logical(1)
      )
    ]

    if (length(incomplete_series) > 0) {
      stop(
        "The following Supplementary Table 11 time series do not contain every year from ",
        START_YEAR, " through ", END_YEAR, ":\n",
        paste(incomplete_series, collapse = "\n"),
        call. = FALSE
      )
    }

    invisible(TRUE)
  }

  extract_supp11_apc_2017_2021 <- function(joinpoint_result) {
    # The requested 2017-2021 value is extracted from result[['AAPC_Range']],
    # because GBDage_aapc() returns the user-specified AAPCrange interval there.
    # The final table uses the label APC_2017_2021 to match the Supplementary
    # Table 11 wording, while preserving the raw AAPC_Range CSV for review.
    aapc_range <- joinpoint_result[["AAPC_Range"]]

    if (is.null(aapc_range)) {
      stop(
        "AAPC_Range table was not found in the Joinpoint result for Supplementary Table 11.",
        call. = FALSE
      )
    }

    location_col <- find_column(
      aapc_range,
      c("location", "Location", "location_name")
    )

    age_col <- find_column(
      aapc_range,
      c("age", "Age", "age_name")
    )

    rei_col <- find_column(
      aapc_range,
      c("rei", "REI", "sequela", "Sequela", "impairment", "Impairment")
    )

    aapc_col <- find_column(aapc_range, c("AAPC", "aapc", "APC", "apc"))

    lower_col <- find_column(
      aapc_range,
      c(
        "lower", "lower_CI", "Lower_CI", "AAPC_lower", "AAPC_LCI",
        "APC_lower", "APC_LCI", "LCI", "lci",
        "AAPC_95CI_lower", "APC_95CI_lower"
      )
    )

    upper_col <- find_column(
      aapc_range,
      c(
        "upper", "upper_CI", "Upper_CI", "AAPC_upper", "AAPC_UCI",
        "APC_upper", "APC_UCI", "UCI", "uci",
        "AAPC_95CI_upper", "APC_95CI_upper"
      )
    )

    p_col <- find_column(
      aapc_range,
      c(
        "P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"
      ),
      required = FALSE
    )

    out <- data.frame(
      Location = as.character(aapc_range[[location_col]]),
      Age_raw = as.character(aapc_range[[age_col]]),
      Impairment = as.character(aapc_range[[rei_col]]),
      Measure = "Prevalence",
      Metric = supp11_metric_name,
      Time = paste0(TABLE2_AAPC_RANGE_START, "-", TABLE2_AAPC_RANGE_END),
      APC_2017_2021 = as.numeric(as.character(aapc_range[[aapc_col]])),
      Lower = as.numeric(as.character(aapc_range[[lower_col]])),
      Upper = as.numeric(as.character(aapc_range[[upper_col]])),
      Source_component = "AAPC_Range",
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(aapc_range[[p_col]]))
    } else {
      out$P_value <- NA
    }

    out <- out[
      out$Location %in% supp11_location_order &
        out$Age_raw %in% supp11_age_order &
        out$Impairment %in% supp11_impairment_order,
      ,
      drop = FALSE
    ]

    out$Age <- supp11_age_display[out$Age_raw]

    out$P_value_formatted <- format_p_value(out$P_value)
    out$APC_2017_2021_95CI <- make_aapc_ci_text(
      out$APC_2017_2021,
      out$Lower,
      out$Upper
    )

    out$Location <- factor(
      out$Location,
      levels = supp11_location_order,
      ordered = TRUE
    )

    out$Age <- factor(
      out$Age,
      levels = supp11_age_display,
      ordered = TRUE
    )

    out$Impairment <- factor(
      out$Impairment,
      levels = supp11_impairment_order,
      ordered = TRUE
    )

    out <- out[order(out$Age, out$Impairment, out$Location), , drop = FALSE]

    out$Location <- as.character(out$Location)
    out$Age <- as.character(out$Age)
    out$Impairment <- as.character(out$Impairment)

    out <- out[
      ,
      c(
        "Age", "Impairment", "Location", "Measure", "Metric", "Time",
        "P_value", "P_value_formatted",
        "APC_2017_2021", "Lower", "Upper", "APC_2017_2021_95CI",
        "Source_component"
      ),
      drop = FALSE
    ]

    return(out)
  }

  cat("\n=================================================================\n")
  cat("Running Supplementary Table 11 GBDage_aapc(): Location x Age x Impairment\n")
  cat("=================================================================\n")

  supp11_input <- filter_supp11_input_data(gbd_data)
  check_supp11_joinpoint_input(supp11_input)

  # ---------------------------------------------------------------------------
  # Supplementary Table 11 core Joinpoint analysis step
  # ---------------------------------------------------------------------------
  # This is one additional GBDage_aapc() call at the
  # Location x Age x Impairment level.
  # The requested 2017-2021 result is returned in result[['AAPC_Range']]
  # because AAPCrange = c(2017, 2021).
  # ---------------------------------------------------------------------------

  result_supplementary_table11 <- GBDage_aapc(
    data = supp11_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = c(TABLE2_AAPC_RANGE_START, TABLE2_AAPC_RANGE_END)
  )

  validate_joinpoint_result(
    joinpoint_result = result_supplementary_table11,
    analysis_label = "Supplementary Table 11 - Location x Age x Impairment prevalence",
    require_aapc_range = TRUE
  )

  component_prefix_supp11 <- "SupplementaryTable11_Location_Age_Impairment_Prevalence_APC_2017_2021"

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table11[["AAPC"]],
      "AAPC",
      component_prefix_supp11
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp11, "AAPC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table11[["AAPC_Range"]],
      "AAPC_Range",
      component_prefix_supp11
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp11, "AAPC_Range"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table11[["APC"]],
      "APC",
      component_prefix_supp11
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp11, "APC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_supplementary_table11[["data"]],
      "data",
      component_prefix_supp11
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_supp11, "data"),
    row.names = FALSE
  )

  supp11_long <- extract_supp11_apc_2017_2021(result_supplementary_table11)
  rownames(supp11_long) <- NULL

  supp11_long_file <- file.path(
    output_dir,
    "Supplementary_Table_11_Global_5SDI_Age_Impairment_Prevalence_APC_2017_2021_long.csv"
  )

  write.csv(supp11_long, file = supp11_long_file, row.names = FALSE)

  supp11_wide <- unique(
    supp11_long[
      ,
      c("Age", "Impairment", "Measure", "Metric", "Time", "Source_component"),
      drop = FALSE
    ]
  )

  for (current_location in supp11_location_order) {
    current_rows <- supp11_long[
      supp11_long$Location == current_location,
      c(
        "Age", "Impairment", "Measure", "Metric", "Time", "Source_component",
        "P_value_formatted", "APC_2017_2021_95CI"
      ),
      drop = FALSE
    ]

    current_location_prefix <- sanitize_file_part(current_location)

    names(current_rows)[names(current_rows) == "P_value_formatted"] <-
      paste0(current_location_prefix, "_P_value")

    names(current_rows)[names(current_rows) == "APC_2017_2021_95CI"] <-
      paste0(current_location_prefix, "_APC_2017_2021_95CI")

    supp11_wide <- merge(
      supp11_wide,
      current_rows,
      by = c("Age", "Impairment", "Measure", "Metric", "Time", "Source_component"),
      all.x = TRUE
    )
  }

  supp11_wide$Age <- factor(
    supp11_wide$Age,
    levels = supp11_age_display,
    ordered = TRUE
  )

  supp11_wide$Impairment <- factor(
    supp11_wide$Impairment,
    levels = supp11_impairment_order,
    ordered = TRUE
  )

  supp11_wide <- supp11_wide[
    order(supp11_wide$Age, supp11_wide$Impairment),
    ,
    drop = FALSE
  ]

  supp11_wide$Age <- as.character(supp11_wide$Age)
  supp11_wide$Impairment <- as.character(supp11_wide$Impairment)

  supp11_wide_file <- file.path(
    output_dir,
    "Supplementary_Table_11_Global_5SDI_Age_Impairment_Prevalence_APC_2017_2021_wide.csv"
  )

  write.csv(supp11_wide, file = supp11_wide_file, row.names = FALSE)

  cat("Saved Supplementary Table 11 files:\n")
  cat("  ", normalizePath(supp11_long_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(supp11_wide_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("Saved Supplementary Table 11 raw Joinpoint component files under 00_joinpoint_raw_components/.\n")
}


# -----------------------------------------------------------------------------
# 10. Table 2: Etiology of meningitis-related ASYR, 2017-2021
# -----------------------------------------------------------------------------

make_table2_outputs <- function(table2_input_folder, output_dir) {
  required_columns <- c(
    "location", "sex", "age", "cause", "measure",
    "metric", "year", "rei", "val"
  )

  gbd_data <- read_gbd_folder(table2_input_folder, required_columns)

  gbd_data$rei[gbd_data$rei == "Other bacterial pathogens"] <-
    "Other bacterial pathogen"

  measure_name <- "YLDs (Years Lived with Disability)"

  rei_order <- c(
    "Escherichia coli",
    "Group B streptococcus",
    "Haemophilus influenzae",
    "Klebsiella pneumoniae",
    "Listeria monocytogenes",
    "Neisseria meningitidis",
    "Other bacterial pathogen",
    "Staphylococcus aureus",
    "Streptococcus pneumoniae",
    "Viral etiologies of meningitis"
  )

  assert_values_exist(gbd_data, "location", LOCATION_NAME)
  assert_values_exist(gbd_data, "sex", SEX_NAME)
  assert_values_exist(gbd_data, "cause", CAUSE_NAME)
  assert_values_exist(gbd_data, "measure", measure_name)
  assert_values_exist(gbd_data, "metric", METRIC_NAME)
  assert_values_exist(gbd_data, "rei", rei_order)

  available_ages <- unique(gbd_data$age)

  age_under5 <- resolve_age_label(
    available_ages,
    c("<5", "< 5", "<5 years", "Under 5", "Under 5 years",
      "0 to 4", "0-4 years", "0 to 4 years"),
    "the under-five age group for Table 2"
  )

  age_neonatal <- resolve_age_label(
    available_ages,
    c("Neonatal", "Neonatal period", "<28 days", "< 28 days",
      "0 to 27 days", "0-27 days", "0 to 28 days"),
    "the neonatal total age group for Table 2"
  )

  filter_table2_data <- function(data, age_label, age_output_name) {
    selected <- data[
      data$location == LOCATION_NAME &
        data$sex == SEX_NAME &
        data$cause == CAUSE_NAME &
        data$measure == measure_name &
        data$metric == METRIC_NAME &
        data$age == age_label &
        data$rei %in% rei_order &
        data$year >= START_YEAR &
        data$year <= END_YEAR,
      ,
      drop = FALSE
    ]

    if (nrow(selected) == 0) {
      stop(
        "No data remained after filtering Table 2 data for age group: ",
        age_label,
        call. = FALSE
      )
    }

    selected$rei <- factor(selected$rei, levels = rei_order, ordered = TRUE)

    selected <- selected[
      order(selected$rei, selected$year),
      ,
      drop = FALSE
    ]

    rownames(selected) <- NULL
    selected$age_output <- age_output_name

    return(selected)
  }

  check_table2_joinpoint_input <- function(data, age_label) {
    data$val <- as.numeric(as.character(data$val))

    if (any(is.na(data$val)) || any(!is.finite(data$val))) {
      stop(
        "Missing or non-finite values were found in Table 2 age group: ",
        age_label,
        call. = FALSE
      )
    }

    if (any(data$val <= 0)) {
      stop(
        "Zero or negative YLD rate values were found in Table 2 age group: ",
        age_label,
        ". The log-linear Joinpoint model requires strictly positive values.",
        call. = FALSE
      )
    }

    required_years <- seq(START_YEAR, END_YEAR)

    for (current_rei in rei_order) {
      current_years <- sort(unique(data$year[as.character(data$rei) == current_rei]))

      if (!identical(current_years, required_years)) {
        stop(
          "Incomplete year series for Table 2 etiology: ",
          current_rei,
          " in age group: ",
          age_label,
          ". Required years are ",
          START_YEAR,
          "-",
          END_YEAR,
          ".",
          call. = FALSE
        )
      }
    }

    duplicate_key <- paste(data$rei, data$year, sep = "___")

    if (anyDuplicated(duplicate_key) > 0) {
      stop(
        "Duplicate etiology-year observations were found in Table 2 age group: ",
        age_label,
        call. = FALSE
      )
    }

    invisible(TRUE)
  }

  extract_table2_from_aapc_range <- function(joinpoint_result, age_output_name) {
    aapc_range <- joinpoint_result[["AAPC_Range"]]

    if (is.null(aapc_range)) {
      stop(
        "AAPC_Range was not found in the Joinpoint result. ",
        "Please check whether easyGBDR::GBDage_aapc() supports the AAPCrange argument.",
        call. = FALSE
      )
    }

    rei_col   <- find_column(aapc_range, c("rei", "Etiology", "Aetiology", "risk", "risk_factor"))
    aapc_col  <- find_column(aapc_range, c("AAPC", "aapc"))
    lower_col <- find_column(
      aapc_range,
      c("lower", "lower_CI", "Lower_CI", "AAPC_lower", "AAPC_LCI",
        "LCI", "lci", "AAPC_95CI_lower", "AAPC_95CI_low")
    )
    upper_col <- find_column(
      aapc_range,
      c("upper", "upper_CI", "Upper_CI", "AAPC_upper", "AAPC_UCI",
        "UCI", "uci", "AAPC_95CI_upper", "AAPC_95CI_high")
    )
    p_col <- find_column(
      aapc_range,
      c("P", "p", "P.Value", "P_value", "p_value",
        "Pvalue", "pvalue", "P value"),
      required = FALSE
    )

    out <- data.frame(
      Etiology = as.character(aapc_range[[rei_col]]),
      Time = paste0(TABLE2_AAPC_RANGE_START, "-", TABLE2_AAPC_RANGE_END),
      AAPC = as.numeric(as.character(aapc_range[[aapc_col]])),
      Lower = as.numeric(as.character(aapc_range[[lower_col]])),
      Upper = as.numeric(as.character(aapc_range[[upper_col]])),
      stringsAsFactors = FALSE
    )

    if (!is.na(p_col)) {
      out$P_value <- as.numeric(as.character(aapc_range[[p_col]]))
    } else {
      out$P_value <- NA
    }

    out$P_value_formatted <- format_p_value(out$P_value)
    out$AAPC_95CI <- make_aapc_ci_text(out$AAPC, out$Lower, out$Upper)

    out <- out[out$Etiology %in% rei_order, , drop = FALSE]
    out$Etiology <- factor(out$Etiology, levels = rei_order, ordered = TRUE)
    out <- out[order(out$Etiology), , drop = FALSE]
    out$Etiology <- as.character(out$Etiology)

    names(out)[names(out) == "P_value_formatted"] <-
      paste0(age_output_name, "_P_value")

    names(out)[names(out) == "AAPC_95CI"] <-
      paste0(age_output_name, "_AAPC_95CI")

    out <- out[
      ,
      c(
        "Etiology",
        "Time",
        paste0(age_output_name, "_P_value"),
        paste0(age_output_name, "_AAPC_95CI")
      ),
      drop = FALSE
    ]

    return(out)
  }

  cat("\n=================================================================\n")
  cat("Extracting Table 2 AAPC_Range results\n")
  cat("=================================================================\n")

  under5_input <- filter_table2_data(gbd_data, age_under5, "<5")
  neonatal_input <- filter_table2_data(gbd_data, age_neonatal, "<28 days")

  check_table2_joinpoint_input(under5_input, "under5")
  check_table2_joinpoint_input(neonatal_input, "neonatal")

  # Full 1990-2021 Joinpoint models with AAPCrange = NULL.
  # These are exported for reviewer verification.
  analysis_label_table2_under5_full <- "Table 2 - under-five etiology ASYR - full 1990-2021"
  component_prefix_table2_under5_full <- "Table2_Under5_Etiology_ASYR_Full_1990_2021"

  cat("\nRunning complete Joinpoint core step for: ", analysis_label_table2_under5_full, "\n", sep = "")

  result_table2_under5_full <- GBDage_aapc(
    data = under5_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = NULL
  )

  validate_joinpoint_result(
    joinpoint_result = result_table2_under5_full,
    analysis_label = analysis_label_table2_under5_full,
    require_aapc_range = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_full[["AAPC"]],
      "AAPC",
      component_prefix_table2_under5_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_full, "AAPC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_full[["AAPC_Range"]],
      "AAPC_Range",
      component_prefix_table2_under5_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_full, "AAPC_Range"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_full[["APC"]],
      "APC",
      component_prefix_table2_under5_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_full, "APC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_full[["data"]],
      "data",
      component_prefix_table2_under5_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_full, "data"),
    row.names = FALSE
  )

  under5_joinpoint_full <- result_table2_under5_full

  analysis_label_table2_neonatal_full <- "Table 2 - neonatal etiology ASYR - full 1990-2021"
  component_prefix_table2_neonatal_full <- "Table2_Neonatal_Etiology_ASYR_Full_1990_2021"

  cat("\nRunning complete Joinpoint core step for: ", analysis_label_table2_neonatal_full, "\n", sep = "")

  result_table2_neonatal_full <- GBDage_aapc(
    data = neonatal_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = NULL
  )

  validate_joinpoint_result(
    joinpoint_result = result_table2_neonatal_full,
    analysis_label = analysis_label_table2_neonatal_full,
    require_aapc_range = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_full[["AAPC"]],
      "AAPC",
      component_prefix_table2_neonatal_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_full, "AAPC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_full[["AAPC_Range"]],
      "AAPC_Range",
      component_prefix_table2_neonatal_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_full, "AAPC_Range"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_full[["APC"]],
      "APC",
      component_prefix_table2_neonatal_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_full, "APC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_full[["data"]],
      "data",
      component_prefix_table2_neonatal_full
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_full, "data"),
    row.names = FALSE
  )

  neonatal_joinpoint_full <- result_table2_neonatal_full

  # Range-specific 2017-2021 Joinpoint models used for the final Table 2.
  analysis_label_table2_under5_range <- "Table 2 - under-five etiology ASYR - AAPCrange 2017-2021"
  component_prefix_table2_under5_range <- "Table2_Under5_Etiology_ASYR_AAPCrange_2017_2021"

  cat("\nRunning complete Joinpoint core step for: ", analysis_label_table2_under5_range, "\n", sep = "")

  result_table2_under5_range <- GBDage_aapc(
    data = under5_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = c(TABLE2_AAPC_RANGE_START, TABLE2_AAPC_RANGE_END)
  )

  validate_joinpoint_result(
    joinpoint_result = result_table2_under5_range,
    analysis_label = analysis_label_table2_under5_range,
    require_aapc_range = TRUE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_range[["AAPC"]],
      "AAPC",
      component_prefix_table2_under5_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_range, "AAPC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_range[["AAPC_Range"]],
      "AAPC_Range",
      component_prefix_table2_under5_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_range, "AAPC_Range"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_range[["APC"]],
      "APC",
      component_prefix_table2_under5_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_range, "APC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_under5_range[["data"]],
      "data",
      component_prefix_table2_under5_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_under5_range, "data"),
    row.names = FALSE
  )

  under5_joinpoint_range <- result_table2_under5_range

  analysis_label_table2_neonatal_range <- "Table 2 - neonatal etiology ASYR - AAPCrange 2017-2021"
  component_prefix_table2_neonatal_range <- "Table2_Neonatal_Etiology_ASYR_AAPCrange_2017_2021"

  cat("\nRunning complete Joinpoint core step for: ", analysis_label_table2_neonatal_range, "\n", sep = "")

  result_table2_neonatal_range <- GBDage_aapc(
    data = neonatal_input,
    startyear = START_YEAR,
    endyear = END_YEAR,
    model = MODEL_TYPE,
    joinpoints = N_JOINPOINTS,
    rei_included = TRUE,
    CI = CALCULATE_CI,
    digits = ROUND_DIGITS,
    sep = " to ",
    constant_variance = CONSTANT_VARIANCE,
    AAPCrange = c(TABLE2_AAPC_RANGE_START, TABLE2_AAPC_RANGE_END)
  )

  validate_joinpoint_result(
    joinpoint_result = result_table2_neonatal_range,
    analysis_label = analysis_label_table2_neonatal_range,
    require_aapc_range = TRUE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_range[["AAPC"]],
      "AAPC",
      component_prefix_table2_neonatal_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_range, "AAPC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_range[["AAPC_Range"]],
      "AAPC_Range",
      component_prefix_table2_neonatal_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_range, "AAPC_Range"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_range[["APC"]],
      "APC",
      component_prefix_table2_neonatal_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_range, "APC"),
    row.names = FALSE
  )

  write.csv(
    coerce_joinpoint_component_to_data_frame(
      result_table2_neonatal_range[["data"]],
      "data",
      component_prefix_table2_neonatal_range
    ),
    file = joinpoint_raw_component_file(output_dir, component_prefix_table2_neonatal_range, "data"),
    row.names = FALSE
  )

  neonatal_joinpoint_range <- result_table2_neonatal_range

  under5_table <- extract_table2_from_aapc_range(
    joinpoint_result = under5_joinpoint_range,
    age_output_name = "under5"
  )

  neonatal_table <- extract_table2_from_aapc_range(
    joinpoint_result = neonatal_joinpoint_range,
    age_output_name = "neonatal"
  )

  table2 <- merge(
    under5_table,
    neonatal_table,
    by = c("Etiology", "Time"),
    all = TRUE
  )

  table2$Etiology <- factor(table2$Etiology, levels = rei_order, ordered = TRUE)
  table2 <- table2[order(table2$Etiology), , drop = FALSE]
  table2$Etiology <- as.character(table2$Etiology)

  names(table2) <- c(
    "Etiology",
    "Time",
    "<5 P value",
    "<5 AAPC (95% CI)",
    "<28 days P value",
    "<28 days AAPC (95% CI)"
  )

  table2_csv_file <- file.path(
    output_dir,
    "Table_2_Global_Etiology_Meningitis_ASYR_AAPC_2017_2021.csv"
  )

  table2_rds_file <- file.path(
    output_dir,
    "Table_2_Global_Etiology_Meningitis_ASYR_AAPC_2017_2021.rds"
  )

  write.csv(table2, file = table2_csv_file, row.names = FALSE)
  saveRDS(table2, file = table2_rds_file)

  cat("Saved Table 2 files:\n")
  cat("  ", normalizePath(table2_csv_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("  ", normalizePath(table2_rds_file, winslash = "/", mustWork = FALSE), "\n", sep = "")
}

# -----------------------------------------------------------------------------
# 11. Run table-only workflow
# -----------------------------------------------------------------------------

print_raw_data_download_manifest()

TABLE_OUTPUT_DIR <- create_folder(TABLE_OUTPUT_DIR)

make_table1_outputs(
  table1_input_folder = TABLE1_INPUT_FOLDER,
  output_dir = TABLE_OUTPUT_DIR
)

make_supp4_outputs(
  supp4_input_folder = SUPP4_INPUT_FOLDER,
  output_dir = TABLE_OUTPUT_DIR
)

make_supp9_outputs(
  supp9_input_folder = SUPP9_INPUT_FOLDER,
  output_dir = TABLE_OUTPUT_DIR
)

make_supp10_outputs(
  supp10_input_folder = SUPP10_INPUT_FOLDER,
  output_dir = TABLE_OUTPUT_DIR
)

make_supp11_outputs(
  supp11_input_folder = SUPP11_INPUT_FOLDER,
  output_dir = TABLE_OUTPUT_DIR
)

make_table2_outputs(
  table2_input_folder = TABLE2_INPUT_FOLDER,
  output_dir = TABLE_OUTPUT_DIR
)

cat("\n=================================================================\n")
cat("Table-only reproducibility analysis completed successfully.\n")
cat("Output folder: ", normalizePath(TABLE_OUTPUT_DIR, winslash = "/", mustWork = FALSE), "\n", sep = "")
cat("Raw data folder names are reviewer-facing and printed at the start of the workflow.\n")
cat("Joinpoint analyses completed and validated:\n")
cat("  Table 1 / Supplementary Table 2: ASIR, ASMR, ASYR; each uses complete GBDage_aapc() core step\n")
cat("  Supplementary Table 4: ASIR, ASMR, ASYR; each uses complete GBDage_aapc() core step\n")
cat("  Supplementary Table 9: impairment prevalence; uses complete additional GBDage_aapc() core step\n")
cat("  Supplementary Table 10: etiology-specific ASYR; uses one additional Location x Etiology x Age GBDage_aapc() core step with AAPCrange = c(2017, 2021)\n")
cat("  Supplementary Table 11: functional impairment prevalence; uses one additional Location x Age x Impairment GBDage_aapc() core step with AAPCrange = c(2017, 2021)\n")
cat("  Table 2: under-five and neonatal etiology ASYR; each uses complete GBDage_aapc() core step twice: AAPCrange = NULL and AAPCrange = c(2017, 2021)\n")
cat("  Raw components: every GBDage_aapc() result exports AAPC, AAPC_Range, APC and data CSVs under 00_joinpoint_raw_components/\n")
cat("Files generated:\n")
cat("  Table_1_Global_ASIR_ASMR_ASYR_AAPC_1990_2021_long.csv\n")
cat("  Table_1_Global_ASIR_ASMR_ASYR_AAPC_1990_2021_wide.csv\n")
cat("  Supplementary_Table_2_Global_LowSDI_LowMiddleSDI_Under5_ASIR_ASMR_ASYR_APC_1990_2021_long.csv\n")
cat("  Supplementary_Table_2_Global_LowSDI_LowMiddleSDI_Under5_ASIR_ASMR_ASYR_APC_1990_2021_wide.csv\n")
cat("  Supplementary_Table_4_Country_ASIR_ASMR_ASYR_AAPC_1990_2021_long.csv\n")
cat("  Supplementary_Table_4_Country_ASIR_ASMR_ASYR_AAPC_1990_2021_wide.csv\n")
cat("  Supplementary_Table_9_Global_Regions_Under5_Meningitis_Impairment_Prevalence_AAPC_1990_2021_long.csv\n")
cat("  Supplementary_Table_9_Global_Regions_Under5_Meningitis_Impairment_Prevalence_AAPC_1990_2021_wide.csv\n")
cat("  Supplementary_Table_10_Global_5SDI_Etiology_Age_ASYR_APC_2017_2021_long.csv\n")
cat("  Supplementary_Table_10_Global_5SDI_Etiology_Age_ASYR_APC_2017_2021_wide.csv\n")
cat("  Supplementary_Table_11_Global_5SDI_Age_Impairment_Prevalence_APC_2017_2021_long.csv\n")
cat("  Supplementary_Table_11_Global_5SDI_Age_Impairment_Prevalence_APC_2017_2021_wide.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable11_Location_Age_Impairment_Prevalence_APC_2017_2021_AAPC.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable11_Location_Age_Impairment_Prevalence_APC_2017_2021_AAPC_Range.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable11_Location_Age_Impairment_Prevalence_APC_2017_2021_APC.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable11_Location_Age_Impairment_Prevalence_APC_2017_2021_data.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable10_Location_Etiology_Age_ASYR_APC_2017_2021_AAPC.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable10_Location_Etiology_Age_ASYR_APC_2017_2021_AAPC_Range.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable10_Location_Etiology_Age_ASYR_APC_2017_2021_APC.csv\n")
cat("  00_joinpoint_raw_components/SupplementaryTable10_Location_Etiology_Age_ASYR_APC_2017_2021_data.csv\n")
cat("  Table_2_Global_Etiology_Meningitis_ASYR_AAPC_2017_2021.csv\n")
cat("  Table_2_Global_Etiology_Meningitis_ASYR_AAPC_2017_2021.rds\n")
cat("=================================================================\n")
