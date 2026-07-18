# =============================================================================
# Figure 2 and Figure 6 Reproducibility Script
#
# Study topic:
#   Relationship between meningitis burden rates among children under 5 years
#   of age and the Socio-demographic Index (SDI).
#
# Final outputs:
#   Figure 2.tif
#     Relationship between under-five incidence, mortality, and YLD rates
#     and SDI, globally and across 21 GBD regions from 1990 to 2021.
#
#   Figure 6.tif
#     Association between under-five incidence, mortality, and YLD rates
#     and SDI across 204 countries and territories in 2021.
#
# Core plotting function:
#   easyGBDR::ggGBDsdiASR()
#
# IMPORTANT METHOD LOGIC
# ----------------------
# The easyGBDR SDI-rate correlation tool reads estimates from rows coded as:
#
#   age    = "Age-standardized"
#   metric = "Rate"
#
# This analysis concerns one age interval only: children under 5 years.
# Therefore:
#
#   1. The downloaded GBD input is the directly reported under-five Rate.
#   2. No cross-age aggregation, weighting, or age standardisation is applied.
#   3. The under-five Rate is copied unchanged into rows whose `age` field is
#      set to "Age-standardized" only for compatibility with ggGBDsdiASR().
#   4. The original under-five age label is preserved in `source_age`.
#   5. The original rate is preserved in `source_rate_value`.
#   6. The value still represents the rate of the under-five population and
#      must not be interpreted as a conventional all-age age-standardised rate.
#
# Required downloaded GBD data:
#
#   Figure 2:
#     GBD release: GBD 2021
#     Cause:       Meningitis
#     Locations:   Global and 21 GBD regions
#     Sex:         Both
#     Age:         <5 / 0 to 4 / Under 5 years
#     Metric:      Rate
#     Measures:    Incidence; Deaths; YLDs
#     Years:       Every individual year from 1990 through 2021
#
#   Figure 6:
#     GBD release: GBD 2021
#     Cause:       Meningitis
#     Locations:   204 countries and territories
#     Sex:         Both
#     Age:         <5 / 0 to 4 / Under 5 years
#     Metric:      Rate
#     Measures:    Incidence; Deaths; YLDs
#     Year:        2021
#
# R version:
#   R 4.4.1 compatible
# =============================================================================

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. Required packages
# -----------------------------------------------------------------------------

required_packages <- c(
  "easyGBDR",
  "ggplot2",
  "ggrepel",
  "dplyr",
  "grid"
)

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
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(ggrepel))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(grid))

if ("GBD_edition" %in% getNamespaceExports("easyGBDR")) {
  GBD_edition(edition = 2021)
}

# -----------------------------------------------------------------------------
# 2. Project folders and reviewer-facing raw-data names
# -----------------------------------------------------------------------------
#
# Recommended folder structure:
#
# D:/Meningitis_Figure2_Figure6_SDI_Reproducibility/
# ├── 01_raw_GBD_data/
# │   ├── Figure2_Meningitis_Global_21GBDRegions_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021/
# │   │   └── IHME-GBD_2021_DATA-xxxxxxxx.csv
# │   └── Figure6_Meningitis_204Countries_BothSex_Under5_Incidence_Deaths_YLD_Rate_2021/
# │       └── IHME-GBD_2021_DATA-xxxxxxxx.csv
# └── 02_outputs/
#
# The folder names explicitly identify figure number, cause, location scope,
# sex, age group, measures, metric, and year range.

PROJECT_DIR <- "D:/Meningitis_Figure2_Figure6_SDI_Reproducibility"

FIGURE2_RAW_GBD_FOLDER_NAME <- paste0(
  "Figure2_Meningitis_Global_21GBDRegions_BothSex_Under5_",
  "Incidence_Deaths_YLD_Rate_1990_2021"
)

FIGURE6_RAW_GBD_FOLDER_NAME <- paste0(
  "Figure6_Meningitis_204Countries_BothSex_Under5_",
  "Incidence_Deaths_YLD_Rate_2021"
)

FIGURE2_RAW_GBD_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  FIGURE2_RAW_GBD_FOLDER_NAME
)

FIGURE6_RAW_GBD_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  FIGURE6_RAW_GBD_FOLDER_NAME
)

OUTPUT_DIR <- file.path(
  PROJECT_DIR,
  "02_outputs"
)

# -----------------------------------------------------------------------------
# 3. Global settings
# -----------------------------------------------------------------------------

CAUSE_NAME <- "Meningitis"
SEX_NAME <- "Both"

SOURCE_METRIC_NAME <- "Rate"
TOOL_COMPATIBLE_AGE_NAME <- "Age-standardized"
TOOL_COMPATIBLE_METRIC_NAME <- "Rate"

START_YEAR_FIGURE2 <- 1990
END_YEAR_FIGURE2 <- 2021
YEAR_FIGURE6 <- 2021

# ggGBDsdiASR() reads the age-standardized-rate field.
GGBD_RATE_ARGUMENT <- "Age-standardized"

UNDER_FIVE_AGE_CANDIDATES <- c(
  "<5",
  "< 5",
  "<5 years",
  "0 to 4",
  "0 to 4 years",
  "0-4",
  "0-4 years",
  "Under 5",
  "Under 5 years",
  "Under 5 Years"
)

GBD_REGION_LOCATION_ORDER <- c(
  "Global",
  "Central Asia",
  "Central Europe",
  "Eastern Europe",
  "Australasia",
  "High-income Asia Pacific",
  "High-income North America",
  "Southern Latin America",
  "Western Europe",
  "Andean Latin America",
  "Caribbean",
  "Central Latin America",
  "Tropical Latin America",
  "North Africa and Middle East",
  "South Asia",
  "East Asia",
  "Oceania",
  "Southeast Asia",
  "Central Sub-Saharan Africa",
  "Eastern Sub-Saharan Africa",
  "Southern Sub-Saharan Africa",
  "Western Sub-Saharan Africa"
)

SDI_GROUPS <- c(
  "High SDI",
  "High-middle SDI",
  "Middle SDI",
  "Low-middle SDI",
  "Low SDI"
)

NON_COUNTRY_AGGREGATES <- c(
  GBD_REGION_LOCATION_ORDER,
  SDI_GROUPS,
  "World Bank High Income",
  "World Bank Low Income",
  "World Bank Lower Middle Income",
  "World Bank Upper Middle Income"
)

FIGURE2_PANEL_SPECS <- list(
  list(
    panel_id = "Figure2A_ASIR",
    panel_label = "A",
    measure_name = "Incidence",
    y_axis_title = "Under-five incidence rate (per 100,000)",
    input_csv_name = "Figure2A_ASIR_directUnder5Rate_input_data.csv",
    panel_pdf_name = "Figure2A_ASIR_Incidence_panel.pdf"
  ),
  list(
    panel_id = "Figure2B_ASMR",
    panel_label = "B",
    measure_name = "Deaths",
    y_axis_title = "Under-five mortality rate (per 100,000)",
    input_csv_name = "Figure2B_ASMR_directUnder5Rate_input_data.csv",
    panel_pdf_name = "Figure2B_ASMR_Mortality_panel.pdf"
  ),
  list(
    panel_id = "Figure2C_ASYR",
    panel_label = "C",
    measure_name = "YLDs (Years Lived with Disability)",
    y_axis_title = "Under-five YLD rate (per 100,000)",
    input_csv_name = "Figure2C_ASYR_directUnder5Rate_input_data.csv",
    panel_pdf_name = "Figure2C_ASYR_YLDs_panel.pdf"
  )
)

FIGURE6_PANEL_SPECS <- list(
  list(
    panel_id = "Figure6A_ASIR",
    panel_label = "A",
    measure_name = "Incidence",
    y_axis_title = "Under-five incidence rate (per 100,000)",
    input_csv_name = "Figure6A_ASIR_directUnder5Rate_input_data.csv",
    panel_pdf_name = "Figure6A_ASIR_Incidence_panel.pdf"
  ),
  list(
    panel_id = "Figure6B_ASMR",
    panel_label = "B",
    measure_name = "Deaths",
    y_axis_title = "Under-five mortality rate (per 100,000)",
    input_csv_name = "Figure6B_ASMR_directUnder5Rate_input_data.csv",
    panel_pdf_name = "Figure6B_ASMR_Mortality_panel.pdf"
  ),
  list(
    panel_id = "Figure6C_ASYR",
    panel_label = "C",
    measure_name = "YLDs (Years Lived with Disability)",
    y_axis_title = "Under-five YLD rate (per 100,000)",
    input_csv_name = "Figure6C_ASYR_directUnder5Rate_input_data.csv",
    panel_pdf_name = "Figure6C_ASYR_YLDs_panel.pdf"
  )
)

FIGURE2_TIFF_WIDTH_PX <- 4005
FIGURE2_TIFF_HEIGHT_PX <- 3511
FIGURE2_TIFF_DPI <- 600

FIGURE6_TIFF_WIDTH_PX <- 5000
FIGURE6_TIFF_HEIGHT_PX <- 1800
FIGURE6_TIFF_DPI <- 600

WRITE_PANEL_PDFS <- TRUE
WRITE_COMBINED_PDFS <- TRUE
FIGURE6_SHOW_COUNTRY_LABELS <- TRUE

# -----------------------------------------------------------------------------
# 4. Helper functions
# -----------------------------------------------------------------------------

create_folder <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  return(path)
}

print_raw_data_download_manifest <- function() {
  manifest <- data.frame(
    Analysis = c("Figure 2", "Figure 6"),
    Raw_data_folder = c(
      FIGURE2_RAW_GBD_FOLDER_NAME,
      FIGURE6_RAW_GBD_FOLDER_NAME
    ),
    Locations = c(
      "Global and 21 GBD regions",
      "204 countries and territories"
    ),
    Sex = c(SEX_NAME, SEX_NAME),
    Age = c(
      "<5 / 0 to 4 / Under 5 years",
      "<5 / 0 to 4 / Under 5 years"
    ),
    Measures = c(
      "Incidence; Deaths; YLDs",
      "Incidence; Deaths; YLDs"
    ),
    Metric = c(SOURCE_METRIC_NAME, SOURCE_METRIC_NAME),
    Years = c(
      "1990-2021, every individual year",
      "2021"
    ),
    Cross_age_standardisation = c("Not applied", "Not applied"),
    Tool_compatibility = c(
      "Under-five Rate copied unchanged into age = Age-standardized",
      "Under-five Rate copied unchanged into age = Age-standardized"
    ),
    stringsAsFactors = FALSE
  )

  cat("\n============================================================\n")
  cat("Reviewer-facing raw GBD data download manifest\n")
  cat("Raw data root: ")
  cat(
    normalizePath(
      file.path(PROJECT_DIR, "01_raw_GBD_data"),
      winslash = "/",
      mustWork = FALSE
    ),
    "\n",
    sep = ""
  )
  cat("============================================================\n")
  print(manifest, row.names = FALSE)
  cat("============================================================\n\n")

  invisible(manifest)
}

assert_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      "Required column(s) are missing: ",
      paste(missing_columns, collapse = ", "),
      "\nAvailable columns: ",
      paste(names(data), collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
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

  invisible(TRUE)
}

standardize_basic_columns <- function(data) {
  alias_pairs <- list(
    location = c("location", "location_name"),
    sex = c("sex", "sex_name"),
    age = c("age", "age_name"),
    cause = c("cause", "cause_name"),
    measure = c("measure", "measure_name"),
    metric = c("metric", "metric_name"),
    year = c("year"),
    val = c("val", "mean", "value")
  )

  current_names_lower <- tolower(gsub("\\.", "_", names(data)))

  for (target_name in names(alias_pairs)) {
    if (!(target_name %in% names(data))) {
      aliases <- alias_pairs[[target_name]]
      match_index <- match(
        tolower(aliases),
        current_names_lower,
        nomatch = 0
      )
      match_index <- match_index[match_index > 0]

      if (length(match_index) > 0) {
        names(data)[match_index[1]] <- target_name
      }
    }
  }

  required_columns <- c(
    "location", "sex", "age", "cause",
    "measure", "metric", "year", "val"
  )

  assert_columns(data, required_columns)

  data$location <- as.character(data$location)
  data$sex <- as.character(data$sex)
  data$age <- as.character(data$age)
  data$cause <- as.character(data$cause)
  data$measure <- as.character(data$measure)
  data$metric <- as.character(data$metric)
  data$year <- as.numeric(as.character(data$year))
  data$val <- as.numeric(as.character(data$val))

  data$measure[
    data$measure %in% c(
      "YLDs",
      "YLDs (Years lived with disability)",
      "YLDs (years lived with disability)"
    )
  ] <- "YLDs (Years Lived with Disability)"

  return(data)
}

resolve_under_five_label <- function(available_ages, figure_name) {
  matched <- UNDER_FIVE_AGE_CANDIDATES[
    UNDER_FIVE_AGE_CANDIDATES %in% available_ages
  ]

  if (length(matched) == 0) {
    stop(
      "Cannot identify the under-five age group for ",
      figure_name,
      ".\nExpected one of: ",
      paste(UNDER_FIVE_AGE_CANDIDATES, collapse = " | "),
      "\nAvailable age values are:\n",
      paste(available_ages, collapse = " | "),
      call. = FALSE
    )
  }

  return(matched[1])
}

read_raw_gbd_data <- function(raw_folder, figure_name) {
  if (!dir.exists(raw_folder)) {
    stop(
      figure_name,
      " raw GBD folder does not exist:\n",
      raw_folder,
      "\n\nCreate this reviewer-facing folder and place the downloaded ",
      "IHME GBD 2021 CSV file(s) inside it.",
      call. = FALSE
    )
  }

  raw_data <- GBDread(
    folder = TRUE,
    foldername = raw_folder
  )

  return(standardize_basic_columns(raw_data))
}

prepare_direct_under5_rate_data <- function(
  raw_data,
  figure_name,
  required_locations,
  required_years
) {
  required_measures <- unique(c(
    vapply(
      FIGURE2_PANEL_SPECS,
      function(x) x$measure_name,
      character(1)
    ),
    vapply(
      FIGURE6_PANEL_SPECS,
      function(x) x$measure_name,
      character(1)
    )
  ))

  source_under_five_label <- resolve_under_five_label(
    available_ages = unique(as.character(raw_data$age)),
    figure_name = figure_name
  )

  assert_values_exist(raw_data, "location", required_locations)
  assert_values_exist(raw_data, "sex", SEX_NAME)
  assert_values_exist(raw_data, "cause", CAUSE_NAME)
  assert_values_exist(raw_data, "age", source_under_five_label)
  assert_values_exist(raw_data, "metric", SOURCE_METRIC_NAME)
  assert_values_exist(raw_data, "measure", required_measures)

  selected_data <- raw_data[
    as.character(raw_data$location) %in% required_locations &
      as.character(raw_data$sex) == SEX_NAME &
      as.character(raw_data$cause) == CAUSE_NAME &
      as.character(raw_data$age) == source_under_five_label &
      as.character(raw_data$metric) == SOURCE_METRIC_NAME &
      as.character(raw_data$measure) %in% required_measures &
      as.numeric(raw_data$year) %in% required_years,
    ,
    drop = FALSE
  ]

  if (nrow(selected_data) == 0) {
    stop(
      "No direct under-five Rate rows remain for ",
      figure_name,
      ".",
      call. = FALSE
    )
  }

  selected_data <- selected_data[
    order(
      selected_data$measure,
      selected_data$location,
      selected_data$year
    ),
    ,
    drop = FALSE
  ]

  rownames(selected_data) <- NULL

  attr(selected_data, "source_under_five_label") <-
    source_under_five_label

  return(selected_data)
}

check_direct_rate_data <- function(
  data,
  figure_name,
  required_locations,
  required_years
) {
  if (any(is.na(data$val)) || any(!is.finite(data$val))) {
    stop(
      figure_name,
      " contains missing or non-finite Rate values.",
      call. = FALSE
    )
  }

  required_measures <- unique(c(
    vapply(
      FIGURE2_PANEL_SPECS,
      function(x) x$measure_name,
      character(1)
    ),
    vapply(
      FIGURE6_PANEL_SPECS,
      function(x) x$measure_name,
      character(1)
    )
  ))

  for (current_measure in required_measures) {
    current_data <- data[
      as.character(data$measure) == current_measure,
      ,
      drop = FALSE
    ]

    missing_locations <- setdiff(
      required_locations,
      unique(as.character(current_data$location))
    )

    if (length(missing_locations) > 0) {
      stop(
        "The following locations are missing for ",
        figure_name,
        " and ",
        current_measure,
        ":\n",
        paste(missing_locations, collapse = "\n"),
        call. = FALSE
      )
    }

    duplicate_identifier <- paste(
      current_data$location,
      current_data$year,
      sep = "___"
    )

    if (anyDuplicated(duplicate_identifier) > 0) {
      stop(
        "Duplicate location-year rows were found for ",
        figure_name,
        " and ",
        current_measure,
        ".",
        call. = FALSE
      )
    }

    years_by_location <- split(
      as.numeric(current_data$year),
      as.character(current_data$location)
    )

    incomplete_locations <- names(years_by_location)[
      vapply(
        years_by_location,
        function(years) {
          !identical(
            sort(unique(years)),
            sort(unique(required_years))
          )
        },
        logical(1)
      )
    ]

    if (length(incomplete_locations) > 0) {
      stop(
        "The following locations have incomplete years for ",
        figure_name,
        " and ",
        current_measure,
        ":\n",
        paste(incomplete_locations, collapse = "\n"),
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

create_tool_compatible_sdi_data <- function(
  direct_under5_rate_data,
  source_under_five_label
) {
  model_data <- direct_under5_rate_data

  model_data$source_age <- as.character(model_data$age)
  model_data$source_metric <- as.character(model_data$metric)
  model_data$source_rate_value <- as.numeric(model_data$val)

  # Compatibility-only field assignment.
  # No rate recalculation or cross-age standardisation is performed.
  model_data$age <- TOOL_COMPATIBLE_AGE_NAME
  model_data$metric <- TOOL_COMPATIBLE_METRIC_NAME

  model_data$analysis_age_band <- "Children under 5 years"
  model_data$cross_age_standardisation_applied <- "No"
  model_data$tool_compatibility_note <- paste0(
    "Original under-five Rate (source age label: ",
    source_under_five_label,
    ") copied unchanged into age='",
    TOOL_COMPATIBLE_AGE_NAME,
    "' for easyGBDR::ggGBDsdiASR() compatibility."
  )

  if (!isTRUE(all.equal(
    as.numeric(model_data$val),
    as.numeric(model_data$source_rate_value),
    check.attributes = FALSE
  ))) {
    stop(
      "The Rate values changed while creating the tool-compatible SDI dataset.",
      call. = FALSE
    )
  }

  return(model_data)
}

get_easygbdr_location_vector <- function(object_name) {
  object_env <- new.env(parent = emptyenv())

  try_result <- try(
    suppressWarnings(
      data(
        list = object_name,
        package = "easyGBDR",
        envir = object_env
      )
    ),
    silent = TRUE
  )

  if (inherits(try_result, "try-error")) {
    return(NULL)
  }

  if (!(object_name %in% ls(object_env))) {
    return(NULL)
  }

  object <- get(object_name, envir = object_env)

  if ("location" %in% names(object)) {
    return(as.character(object$location))
  }

  if ("location_name" %in% names(object)) {
    return(as.character(object$location_name))
  }

  return(NULL)
}

resolve_country_locations <- function(data) {
  country_locations <- get_easygbdr_location_vector("GBDCountry2021")

  if (is.null(country_locations)) {
    country_locations <- get_easygbdr_location_vector("GBDCountry")
  }

  if (is.null(country_locations)) {
    message(
      "GBDCountry2021 was not found in easyGBDR. ",
      "Using a fallback rule that excludes aggregate locations."
    )

    country_locations <- setdiff(
      sort(unique(as.character(data$location))),
      NON_COUNTRY_AGGREGATES
    )
  }

  country_locations <- intersect(
    country_locations,
    unique(as.character(data$location))
  )

  return(sort(unique(country_locations)))
}

filter_figure2_panel_data <- function(data, measure_name) {
  panel_data <- data[
    as.character(data$location) %in% GBD_REGION_LOCATION_ORDER &
      as.character(data$sex) == SEX_NAME &
      as.character(data$cause) == CAUSE_NAME &
      as.character(data$measure) == measure_name &
      as.character(data$metric) == TOOL_COMPATIBLE_METRIC_NAME &
      as.character(data$age) == TOOL_COMPATIBLE_AGE_NAME &
      as.numeric(data$year) >= START_YEAR_FIGURE2 &
      as.numeric(data$year) <= END_YEAR_FIGURE2,
    ,
    drop = FALSE
  ]

  if (nrow(panel_data) == 0) {
    stop(
      "No rows remain after filtering Figure 2 data for measure: ",
      measure_name,
      call. = FALSE
    )
  }

  panel_data$location <- factor(
    as.character(panel_data$location),
    levels = GBD_REGION_LOCATION_ORDER,
    ordered = TRUE
  )

  panel_data <- panel_data[
    order(
      panel_data$location,
      as.numeric(panel_data$year)
    ),
    ,
    drop = FALSE
  ]

  rownames(panel_data) <- NULL
  return(panel_data)
}

filter_figure6_panel_data <- function(
  data,
  measure_name,
  country_locations
) {
  panel_data <- data[
    as.character(data$location) %in% country_locations &
      as.character(data$sex) == SEX_NAME &
      as.character(data$cause) == CAUSE_NAME &
      as.character(data$measure) == measure_name &
      as.character(data$metric) == TOOL_COMPATIBLE_METRIC_NAME &
      as.character(data$age) == TOOL_COMPATIBLE_AGE_NAME &
      as.numeric(data$year) == YEAR_FIGURE6,
    ,
    drop = FALSE
  ]

  if (nrow(panel_data) == 0) {
    stop(
      "No rows remain after filtering Figure 6 data for measure: ",
      measure_name,
      call. = FALSE
    )
  }

  rownames(panel_data) <- NULL
  return(panel_data)
}

check_figure2_panel_data <- function(panel_data, measure_name) {
  if (!isTRUE(all.equal(
    as.numeric(panel_data$val),
    as.numeric(panel_data$source_rate_value),
    check.attributes = FALSE
  ))) {
    stop(
      "Figure 2 model values differ from the original under-five Rate for ",
      measure_name,
      ".",
      call. = FALSE
    )
  }

  observed_locations <- unique(as.character(panel_data$location))
  absent_locations <- setdiff(
    GBD_REGION_LOCATION_ORDER,
    observed_locations
  )

  if (length(absent_locations) > 0) {
    stop(
      "The following Figure 2 locations are missing for ",
      measure_name,
      ": ",
      paste(absent_locations, collapse = ", "),
      call. = FALSE
    )
  }

  expected_years <- seq(
    START_YEAR_FIGURE2,
    END_YEAR_FIGURE2
  )

  years_by_location <- split(
    as.numeric(panel_data$year),
    as.character(panel_data$location)
  )

  incomplete_locations <- names(years_by_location)[
    vapply(
      years_by_location,
      function(years) {
        !identical(
          sort(unique(years)),
          expected_years
        )
      },
      logical(1)
    )
  ]

  if (length(incomplete_locations) > 0) {
    stop(
      "The following Figure 2 locations do not include every year from ",
      START_YEAR_FIGURE2,
      " to ",
      END_YEAR_FIGURE2,
      " for ",
      measure_name,
      ":\n",
      paste(incomplete_locations, collapse = "\n"),
      call. = FALSE
    )
  }

  duplicate_identifier <- paste(
    as.character(panel_data$location),
    panel_data$year,
    sep = "___"
  )

  if (anyDuplicated(duplicate_identifier) > 0) {
    stop(
      "Duplicate Figure 2 location-year rows were found for ",
      measure_name,
      ".",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

check_figure6_panel_data <- function(
  panel_data,
  measure_name,
  country_locations
) {
  if (!isTRUE(all.equal(
    as.numeric(panel_data$val),
    as.numeric(panel_data$source_rate_value),
    check.attributes = FALSE
  ))) {
    stop(
      "Figure 6 model values differ from the original under-five Rate for ",
      measure_name,
      ".",
      call. = FALSE
    )
  }

  missing_locations <- setdiff(
    country_locations,
    unique(as.character(panel_data$location))
  )

  if (length(missing_locations) > 0) {
    stop(
      "The following Figure 6 countries/territories are missing for ",
      measure_name,
      ":\n",
      paste(missing_locations, collapse = "\n"),
      call. = FALSE
    )
  }

  if (length(country_locations) != 204) {
    warning(
      "The resolved Figure 6 country/territory vector contains ",
      length(country_locations),
      " locations rather than 204.",
      call. = FALSE
    )
  }

  duplicate_identifier <- paste(
    as.character(panel_data$location),
    panel_data$year,
    sep = "___"
  )

  if (anyDuplicated(duplicate_identifier) > 0) {
    stop(
      "Duplicate Figure 6 country-year rows were found for ",
      measure_name,
      ".",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

remove_repel_label_layers <- function(plot_object) {
  if (length(plot_object$layers) == 0) {
    return(plot_object)
  }

  keep_layer <- vapply(
    plot_object$layers,
    function(layer) {
      geom_class <- class(layer$geom)[1]
      !(geom_class %in% c("GeomTextRepel", "GeomLabelRepel"))
    },
    logical(1)
  )

  plot_object$layers <- plot_object$layers[keep_layer]
  return(plot_object)
}

make_figure2_panel <- function(
  panel_data,
  panel_spec,
  show_legend
) {
  panel_plot <- ggGBDsdiASR(
    data = panel_data,
    span_val = 0.5,
    se_plot = FALSE,
    rate = GGBD_RATE_ARGUMENT,
    cor = "spearman",
    fig_type = "region"
  )

  panel_plot <- remove_repel_label_layers(panel_plot)

  panel_plot <- panel_plot +
    labs(
      x = "SDI",
      y = panel_spec$y_axis_title,
      title = panel_spec$panel_label
    ) +
    scale_x_continuous(
      limits = c(0, 0.9),
      breaks = seq(0, 0.9, by = 0.1)
    ) +
    theme(
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      axis.line = element_line(color = "black"),
      axis.ticks = element_line(color = "black"),
      axis.text.x = element_text(
        angle = 0,
        hjust = 0.5,
        vjust = 0.5,
        size = 10
      ),
      axis.text.y = element_text(
        angle = 0,
        hjust = 1,
        vjust = 0.5,
        size = 10
      ),
      axis.title.x = element_text(size = 12),
      axis.title.y = element_text(size = 12),
      plot.title = element_text(
        face = "bold",
        size = 18,
        hjust = 0
      ),
      legend.title = element_text(size = 10),
      legend.text = element_text(size = 8),
      legend.key.width = unit(0.45, "cm"),
      legend.key.height = unit(0.35, "cm")
    )

  if (!show_legend) {
    panel_plot <- panel_plot +
      theme(legend.position = "none")
  } else {
    panel_plot <- panel_plot +
      theme(legend.position = "right")
  }

  return(panel_plot)
}

make_figure6_panel <- function(
  panel_data,
  panel_spec
) {
  panel_plot <- ggGBDsdiASR(
    data = panel_data,
    span_val = 0.5,
    se_plot = FALSE,
    rate = GGBD_RATE_ARGUMENT,
    cor = "spearman",
    fig_type = "country"
  )

  panel_plot <- remove_repel_label_layers(panel_plot)

  panel_plot <- panel_plot +
    labs(
      x = "SDI",
      y = panel_spec$y_axis_title,
      title = panel_spec$panel_label
    ) +
    scale_x_continuous(
      limits = c(0, 0.9),
      breaks = seq(0, 0.9, by = 0.1)
    ) +
    theme(
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      axis.line = element_line(color = "black"),
      axis.ticks = element_line(color = "black"),
      axis.text.x = element_text(
        angle = 0,
        hjust = 0.5,
        vjust = 0.5,
        size = 8
      ),
      axis.text.y = element_text(
        angle = 0,
        hjust = 1,
        vjust = 0.5,
        size = 8
      ),
      axis.title.x = element_text(size = 10),
      axis.title.y = element_text(size = 10),
      plot.title = element_text(
        face = "bold",
        size = 16,
        hjust = 0
      ),
      legend.position = "none"
    )

  if (FIGURE6_SHOW_COUNTRY_LABELS) {
    panel_plot <- panel_plot +
      ggrepel::geom_text_repel(
        aes(
          label = location,
          color = location
        ),
        size = 1.6,
        fontface = "plain",
        max.overlaps = Inf,
        min.segment.length = 0.1,
        box.padding = 0.15,
        point.padding = 0.05,
        show.legend = FALSE
      )
  }

  return(panel_plot)
}

extract_legend <- function(plot_object) {
  plot_grob <- ggplotGrob(plot_object)

  grob_names <- vapply(
    plot_grob$grobs,
    function(x) x$name,
    character(1)
  )

  legend_index <- which(grob_names == "guide-box")

  if (length(legend_index) == 0) {
    return(NULL)
  }

  return(plot_grob$grobs[[legend_index[1]]])
}

make_legend_panel <- function(legend_grob) {
  legend_panel <- ggplot() +
    theme_void() +
    theme(
      plot.background = element_rect(
        fill = "white",
        color = NA
      ),
      panel.background = element_rect(
        fill = "white",
        color = NA
      )
    )

  if (!is.null(legend_grob)) {
    legend_panel <- legend_panel +
      annotation_custom(
        grob = legend_grob,
        xmin = -Inf,
        xmax = Inf,
        ymin = -Inf,
        ymax = Inf
      )
  }

  return(legend_panel)
}

save_figure2_tiff <- function(
  panel_a,
  panel_b,
  panel_c,
  legend_panel,
  output_file
) {
  grDevices::tiff(
    filename = output_file,
    width = FIGURE2_TIFF_WIDTH_PX,
    height = FIGURE2_TIFF_HEIGHT_PX,
    units = "px",
    res = FIGURE2_TIFF_DPI,
    compression = "lzw"
  )

  grid::grid.newpage()

  figure_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 2,
      ncol = 2,
      widths = grid::unit(c(1, 1), "null"),
      heights = grid::unit(c(1, 1), "null")
    )
  )

  grid::pushViewport(figure_layout)

  print(
    panel_a,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 1
    ),
    newpage = FALSE
  )

  print(
    panel_b,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 2
    ),
    newpage = FALSE
  )

  print(
    panel_c,
    vp = grid::viewport(
      layout.pos.row = 2,
      layout.pos.col = 1
    ),
    newpage = FALSE
  )

  print(
    legend_panel,
    vp = grid::viewport(
      layout.pos.row = 2,
      layout.pos.col = 2
    ),
    newpage = FALSE
  )

  grid::upViewport()
  grDevices::dev.off()
}

save_figure2_pdf <- function(
  panel_a,
  panel_b,
  panel_c,
  legend_panel,
  output_file
) {
  grDevices::pdf(
    file = output_file,
    width = FIGURE2_TIFF_WIDTH_PX / FIGURE2_TIFF_DPI,
    height = FIGURE2_TIFF_HEIGHT_PX / FIGURE2_TIFF_DPI
  )

  grid::grid.newpage()

  figure_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 2,
      ncol = 2,
      widths = grid::unit(c(1, 1), "null"),
      heights = grid::unit(c(1, 1), "null")
    )
  )

  grid::pushViewport(figure_layout)

  print(
    panel_a,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 1
    ),
    newpage = FALSE
  )

  print(
    panel_b,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 2
    ),
    newpage = FALSE
  )

  print(
    panel_c,
    vp = grid::viewport(
      layout.pos.row = 2,
      layout.pos.col = 1
    ),
    newpage = FALSE
  )

  print(
    legend_panel,
    vp = grid::viewport(
      layout.pos.row = 2,
      layout.pos.col = 2
    ),
    newpage = FALSE
  )

  grid::upViewport()
  grDevices::dev.off()
}

save_figure6_tiff <- function(
  panel_a,
  panel_b,
  panel_c,
  output_file
) {
  grDevices::tiff(
    filename = output_file,
    width = FIGURE6_TIFF_WIDTH_PX,
    height = FIGURE6_TIFF_HEIGHT_PX,
    units = "px",
    res = FIGURE6_TIFF_DPI,
    compression = "lzw"
  )

  grid::grid.newpage()

  figure_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 1,
      ncol = 3,
      widths = grid::unit(c(1, 1, 1), "null"),
      heights = grid::unit(1, "null")
    )
  )

  grid::pushViewport(figure_layout)

  print(
    panel_a,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 1
    ),
    newpage = FALSE
  )

  print(
    panel_b,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 2
    ),
    newpage = FALSE
  )

  print(
    panel_c,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 3
    ),
    newpage = FALSE
  )

  grid::upViewport()
  grDevices::dev.off()
}

save_figure6_pdf <- function(
  panel_a,
  panel_b,
  panel_c,
  output_file
) {
  grDevices::pdf(
    file = output_file,
    width = FIGURE6_TIFF_WIDTH_PX / FIGURE6_TIFF_DPI,
    height = FIGURE6_TIFF_HEIGHT_PX / FIGURE6_TIFF_DPI
  )

  grid::grid.newpage()

  figure_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 1,
      ncol = 3,
      widths = grid::unit(c(1, 1, 1), "null"),
      heights = grid::unit(1, "null")
    )
  )

  grid::pushViewport(figure_layout)

  print(
    panel_a,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 1
    ),
    newpage = FALSE
  )

  print(
    panel_b,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 2
    ),
    newpage = FALSE
  )

  print(
    panel_c,
    vp = grid::viewport(
      layout.pos.row = 1,
      layout.pos.col = 3
    ),
    newpage = FALSE
  )

  grid::upViewport()
  grDevices::dev.off()
}

write_manifest <- function(
  output_folder,
  figure2_source_age,
  figure6_source_age,
  figure6_country_count
) {
  manifest <- data.frame(
    item = c(
      "GBD release",
      "Cause",
      "Sex",
      "Downloaded age for Figure 2",
      "Downloaded age for Figure 6",
      "Downloaded metric",
      "Measures",
      "Figure 2 locations",
      "Figure 2 years",
      "Figure 2 geographic scale",
      "Figure 6 locations",
      "Figure 6 year",
      "Figure 6 geographic scale",
      "Cross-age standardisation",
      "Tool-compatible age field",
      "Value transformation",
      "Core plotting function",
      "Correlation method",
      "Final Figure 2 file",
      "Final Figure 6 file"
    ),
    selection = c(
      "GBD 2021",
      CAUSE_NAME,
      SEX_NAME,
      figure2_source_age,
      figure6_source_age,
      SOURCE_METRIC_NAME,
      "Incidence; Deaths; YLDs (Years Lived with Disability)",
      "Global and 21 GBD regions",
      paste0(
        START_YEAR_FIGURE2,
        "-",
        END_YEAR_FIGURE2,
        ", every individual year"
      ),
      "region",
      paste0(
        figure6_country_count,
        " countries and territories"
      ),
      as.character(YEAR_FIGURE6),
      "country",
      "Not applied; one age interval only",
      TOOL_COMPATIBLE_AGE_NAME,
      "Under-five Rate copied unchanged into the tool-compatible age field",
      "easyGBDR::ggGBDsdiASR()",
      "Spearman",
      "Figure 2.tif",
      "Figure 6.tif"
    ),
    stringsAsFactors = FALSE
  )

  write.csv(
    manifest,
    file = file.path(
      output_folder,
      "00_Figure2_Figure6_data_and_method_manifest.csv"
    ),
    row.names = FALSE
  )

  readme_lines <- c(
    "Figure 2 and Figure 6 SDI-rate reproducibility package",
    "======================================================",
    "",
    "Method clarification:",
    "  The analyses concern one age interval only: children under 5 years.",
    "  The directly downloaded under-five Rate is used without recalculation.",
    "  No cross-age aggregation, weighting, or age standardisation is applied.",
    "",
    "Tool compatibility:",
    "  easyGBDR::ggGBDsdiASR() reads estimates from rows coded as",
    "  age = Age-standardized and metric = Rate.",
    "  Therefore the under-five Rate is copied unchanged into that age field.",
    "  The original age and rate are retained in source_age and",
    "  source_rate_value for reviewer verification.",
    "",
    "Interpretation:",
    "  The values correspond to the under-five population.",
    "  They are not conventional all-age age-standardised rates.",
    "",
    "Required raw-data folders:",
    paste0("  ", FIGURE2_RAW_GBD_FOLDER_NAME),
    paste0("  ", FIGURE6_RAW_GBD_FOLDER_NAME),
    "",
    "Final outputs:",
    "  Figure 2.tif",
    "  Figure 6.tif"
  )

  writeLines(
    readme_lines,
    con = file.path(
      output_folder,
      "00_README_Figure2_Figure6_SDI_rate_method.txt"
    )
  )
}

# -----------------------------------------------------------------------------
# 5. Create output folders
# -----------------------------------------------------------------------------

print_raw_data_download_manifest()

create_folder(OUTPUT_DIR)

RAW_USED_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "00_direct_under5_rate_used"
  )
)

TOOL_INPUT_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "01_tool_compatible_SDI_input"
  )
)

FIGURE2_INPUT_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "02_Figure2_panel_input_data"
  )
)

FIGURE2_PANEL_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "03_Figure2_panel_figures"
  )
)

FIGURE2_FINAL_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "04_final_Figure2"
  )
)

FIGURE6_INPUT_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "05_Figure6_panel_input_data"
  )
)

FIGURE6_PANEL_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "06_Figure6_panel_figures"
  )
)

FIGURE6_FINAL_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "07_final_Figure6"
  )
)

OBJECT_DIR <- create_folder(
  file.path(
    OUTPUT_DIR,
    "08_saved_R_objects"
  )
)

# -----------------------------------------------------------------------------
# 6. Prepare Figure 2 direct under-five Rate data
# -----------------------------------------------------------------------------

cat("\n============================================================\n")
cat("Preparing Figure 2 direct under-five Rate data\n")
cat("No age-recalculation step is used.\n")
cat("============================================================\n")

figure2_global_21regions_under5_raw_data <- read_raw_gbd_data(
  raw_folder = FIGURE2_RAW_GBD_FOLDER,
  figure_name = "Figure 2"
)

figure2_direct_under5_rate_data <- prepare_direct_under5_rate_data(
  raw_data = figure2_global_21regions_under5_raw_data,
  figure_name = "Figure 2",
  required_locations = GBD_REGION_LOCATION_ORDER,
  required_years = seq(
    START_YEAR_FIGURE2,
    END_YEAR_FIGURE2
  )
)

FIGURE2_SOURCE_UNDER_FIVE_AGE_LABEL <- attr(
  figure2_direct_under5_rate_data,
  "source_under_five_label"
)

check_direct_rate_data(
  data = figure2_direct_under5_rate_data,
  figure_name = "Figure 2",
  required_locations = GBD_REGION_LOCATION_ORDER,
  required_years = seq(
    START_YEAR_FIGURE2,
    END_YEAR_FIGURE2
  )
)

write.csv(
  figure2_direct_under5_rate_data,
  file = file.path(
    RAW_USED_DIR,
    "Figure2_directUnder5Rate_Global_21GBDRegions_Incidence_Deaths_YLD_1990_2021.csv"
  ),
  row.names = FALSE
)

figure2_tool_compatible_data <- create_tool_compatible_sdi_data(
  direct_under5_rate_data = figure2_direct_under5_rate_data,
  source_under_five_label = FIGURE2_SOURCE_UNDER_FIVE_AGE_LABEL
)

write.csv(
  figure2_tool_compatible_data,
  file = file.path(
    TOOL_INPUT_DIR,
    "Figure2_toolCompatibleAgeField_directUnder5Rate_Global_21GBDRegions_1990_2021.csv"
  ),
  row.names = FALSE
)

# -----------------------------------------------------------------------------
# 7. Generate Figure 2 panels
# -----------------------------------------------------------------------------

figure2_panel_input_data <- list()
figure2_panel_plots_no_legend <- list()
figure2_panel_plots_with_legend <- list()

for (panel_index in seq_along(FIGURE2_PANEL_SPECS)) {
  current_panel <- FIGURE2_PANEL_SPECS[[panel_index]]

  cat(
    "\nPreparing ",
    current_panel$panel_id,
    "\n",
    sep = ""
  )

  current_panel_data <- filter_figure2_panel_data(
    data = figure2_tool_compatible_data,
    measure_name = current_panel$measure_name
  )

  check_figure2_panel_data(
    panel_data = current_panel_data,
    measure_name = current_panel$measure_name
  )

  figure2_panel_input_data[[current_panel$panel_id]] <-
    current_panel_data

  write.csv(
    current_panel_data,
    file = file.path(
      FIGURE2_INPUT_DIR,
      current_panel$input_csv_name
    ),
    row.names = FALSE
  )

  figure2_panel_plots_no_legend[[current_panel$panel_id]] <-
    make_figure2_panel(
      panel_data = current_panel_data,
      panel_spec = current_panel,
      show_legend = FALSE
    )

  figure2_panel_plots_with_legend[[current_panel$panel_id]] <-
    make_figure2_panel(
      panel_data = current_panel_data,
      panel_spec = current_panel,
      show_legend = TRUE
    )

  if (WRITE_PANEL_PDFS) {
    ggsave(
      filename = file.path(
        FIGURE2_PANEL_DIR,
        current_panel$panel_pdf_name
      ),
      plot = figure2_panel_plots_no_legend[[current_panel$panel_id]],
      width = 6,
      height = 5,
      dpi = 600
    )
  }
}

figure2_legend_grob <- extract_legend(
  figure2_panel_plots_with_legend[["Figure2A_ASIR"]]
)

figure2_legend_panel <- make_legend_panel(
  figure2_legend_grob
)

figure2_tiff_path <- file.path(
  FIGURE2_FINAL_DIR,
  "Figure 2.tif"
)

save_figure2_tiff(
  panel_a = figure2_panel_plots_no_legend[["Figure2A_ASIR"]],
  panel_b = figure2_panel_plots_no_legend[["Figure2B_ASMR"]],
  panel_c = figure2_panel_plots_no_legend[["Figure2C_ASYR"]],
  legend_panel = figure2_legend_panel,
  output_file = figure2_tiff_path
)

if (WRITE_COMBINED_PDFS) {
  save_figure2_pdf(
    panel_a = figure2_panel_plots_no_legend[["Figure2A_ASIR"]],
    panel_b = figure2_panel_plots_no_legend[["Figure2B_ASMR"]],
    panel_c = figure2_panel_plots_no_legend[["Figure2C_ASYR"]],
    legend_panel = figure2_legend_panel,
    output_file = file.path(
      FIGURE2_FINAL_DIR,
      "Figure 2.pdf"
    )
  )
}

# -----------------------------------------------------------------------------
# 8. Prepare Figure 6 direct under-five Rate data
# -----------------------------------------------------------------------------

cat("\n============================================================\n")
cat("Preparing Figure 6 direct under-five Rate data\n")
cat("No age-recalculation step is used.\n")
cat("============================================================\n")

figure6_204countries_under5_raw_data <- read_raw_gbd_data(
  raw_folder = FIGURE6_RAW_GBD_FOLDER,
  figure_name = "Figure 6"
)

figure6_country_locations <- resolve_country_locations(
  figure6_204countries_under5_raw_data
)

figure6_direct_under5_rate_data <- prepare_direct_under5_rate_data(
  raw_data = figure6_204countries_under5_raw_data,
  figure_name = "Figure 6",
  required_locations = figure6_country_locations,
  required_years = YEAR_FIGURE6
)

FIGURE6_SOURCE_UNDER_FIVE_AGE_LABEL <- attr(
  figure6_direct_under5_rate_data,
  "source_under_five_label"
)

check_direct_rate_data(
  data = figure6_direct_under5_rate_data,
  figure_name = "Figure 6",
  required_locations = figure6_country_locations,
  required_years = YEAR_FIGURE6
)

write.csv(
  figure6_direct_under5_rate_data,
  file = file.path(
    RAW_USED_DIR,
    "Figure6_directUnder5Rate_204Countries_Incidence_Deaths_YLD_2021.csv"
  ),
  row.names = FALSE
)

figure6_tool_compatible_data <- create_tool_compatible_sdi_data(
  direct_under5_rate_data = figure6_direct_under5_rate_data,
  source_under_five_label = FIGURE6_SOURCE_UNDER_FIVE_AGE_LABEL
)

write.csv(
  figure6_tool_compatible_data,
  file = file.path(
    TOOL_INPUT_DIR,
    "Figure6_toolCompatibleAgeField_directUnder5Rate_204Countries_2021.csv"
  ),
  row.names = FALSE
)

# -----------------------------------------------------------------------------
# 9. Generate Figure 6 panels
# -----------------------------------------------------------------------------

figure6_panel_input_data <- list()
figure6_panel_plots <- list()

for (panel_index in seq_along(FIGURE6_PANEL_SPECS)) {
  current_panel <- FIGURE6_PANEL_SPECS[[panel_index]]

  cat(
    "\nPreparing ",
    current_panel$panel_id,
    "\n",
    sep = ""
  )

  current_panel_data <- filter_figure6_panel_data(
    data = figure6_tool_compatible_data,
    measure_name = current_panel$measure_name,
    country_locations = figure6_country_locations
  )

  check_figure6_panel_data(
    panel_data = current_panel_data,
    measure_name = current_panel$measure_name,
    country_locations = figure6_country_locations
  )

  figure6_panel_input_data[[current_panel$panel_id]] <-
    current_panel_data

  write.csv(
    current_panel_data,
    file = file.path(
      FIGURE6_INPUT_DIR,
      current_panel$input_csv_name
    ),
    row.names = FALSE
  )

  figure6_panel_plots[[current_panel$panel_id]] <-
    make_figure6_panel(
      panel_data = current_panel_data,
      panel_spec = current_panel
    )

  if (WRITE_PANEL_PDFS) {
    ggsave(
      filename = file.path(
        FIGURE6_PANEL_DIR,
        current_panel$panel_pdf_name
      ),
      plot = figure6_panel_plots[[current_panel$panel_id]],
      width = 5.5,
      height = 4.2,
      dpi = 600
    )
  }
}

figure6_tiff_path <- file.path(
  FIGURE6_FINAL_DIR,
  "Figure 6.tif"
)

save_figure6_tiff(
  panel_a = figure6_panel_plots[["Figure6A_ASIR"]],
  panel_b = figure6_panel_plots[["Figure6B_ASMR"]],
  panel_c = figure6_panel_plots[["Figure6C_ASYR"]],
  output_file = figure6_tiff_path
)

if (WRITE_COMBINED_PDFS) {
  save_figure6_pdf(
    panel_a = figure6_panel_plots[["Figure6A_ASIR"]],
    panel_b = figure6_panel_plots[["Figure6B_ASMR"]],
    panel_c = figure6_panel_plots[["Figure6C_ASYR"]],
    output_file = file.path(
      FIGURE6_FINAL_DIR,
      "Figure 6.pdf"
    )
  )
}

# -----------------------------------------------------------------------------
# 10. Save objects, manifest, and session information
# -----------------------------------------------------------------------------

write_manifest(
  output_folder = OUTPUT_DIR,
  figure2_source_age = FIGURE2_SOURCE_UNDER_FIVE_AGE_LABEL,
  figure6_source_age = FIGURE6_SOURCE_UNDER_FIVE_AGE_LABEL,
  figure6_country_count = length(figure6_country_locations)
)

saveRDS(
  figure2_direct_under5_rate_data,
  file = file.path(
    OBJECT_DIR,
    "Figure2_direct_under5_rate_data.rds"
  )
)

saveRDS(
  figure2_tool_compatible_data,
  file = file.path(
    OBJECT_DIR,
    "Figure2_tool_compatible_SDI_input.rds"
  )
)

saveRDS(
  figure2_panel_input_data,
  file = file.path(
    OBJECT_DIR,
    "Figure2_panel_input_data_by_panel.rds"
  )
)

saveRDS(
  figure2_panel_plots_no_legend,
  file = file.path(
    OBJECT_DIR,
    "Figure2_panel_ggplot_objects_no_legend.rds"
  )
)

saveRDS(
  figure6_direct_under5_rate_data,
  file = file.path(
    OBJECT_DIR,
    "Figure6_direct_under5_rate_data.rds"
  )
)

saveRDS(
  figure6_tool_compatible_data,
  file = file.path(
    OBJECT_DIR,
    "Figure6_tool_compatible_SDI_input.rds"
  )
)

saveRDS(
  figure6_panel_input_data,
  file = file.path(
    OBJECT_DIR,
    "Figure6_panel_input_data_by_panel.rds"
  )
)

saveRDS(
  figure6_panel_plots,
  file = file.path(
    OBJECT_DIR,
    "Figure6_panel_ggplot_objects.rds"
  )
)

capture.output(
  sessionInfo(),
  file = file.path(
    OUTPUT_DIR,
    "00_R_sessionInfo.txt"
  )
)

cat("\n============================================================\n")
cat("Figure 2 and Figure 6 were generated successfully.\n")
cat(
  "Final Figure 2: ",
  normalizePath(
    figure2_tiff_path,
    winslash = "/",
    mustWork = FALSE
  ),
  "\n",
  sep = ""
)
cat(
  "Final Figure 6: ",
  normalizePath(
    figure6_tiff_path,
    winslash = "/",
    mustWork = FALSE
  ),
  "\n",
  sep = ""
)
cat(
  "Output folder: ",
  normalizePath(
    OUTPUT_DIR,
    winslash = "/",
    mustWork = FALSE
  ),
  "\n",
  sep = ""
)
cat(
  "Figure 2 source age label: ",
  FIGURE2_SOURCE_UNDER_FIVE_AGE_LABEL,
  "\n",
  sep = ""
)
cat(
  "Figure 6 source age label: ",
  FIGURE6_SOURCE_UNDER_FIVE_AGE_LABEL,
  "\n",
  sep = ""
)
cat(
  "Tool-compatible age field: ",
  TOOL_COMPATIBLE_AGE_NAME,
  "\n",
  sep = ""
)
cat("Cross-age standardisation applied: No\n")
cat("Value transformation: none; under-five Rate copied unchanged.\n")
cat("============================================================\n")

# =============================================================================
# Suggested methodological wording
# =============================================================================
#
# The R tool used for the SDI-rate correlation analysis reads estimates only
# from the age-standardised-rate field. As the analysis concerned a single age
# band (children under 5 years), the directly downloaded under-five rate was
# supplied unchanged in that field. No cross-age standardisation was applied,
# and the values therefore represent rates in the under-five population rather
# than conventional all-age age-standardised rates.
#
# =============================================================================
# End of script
# =============================================================================
