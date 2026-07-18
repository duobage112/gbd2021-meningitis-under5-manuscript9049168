# =============================================================================
# Figure 3 Reproducibility Script
#
# Frontier analysis of meningitis ASIR (A, B), ASMR (C, D), and ASYR (E, F)
# among children under 5 years of age and SDI across 204 countries and
# territories, 1990–2021.
#
# R version: 4.4.1 compatible
#
# Final output:
#   Figure 3.tif
#
# Panel layout:
#   Figure 3A: ASIR, all years, 1990–2021
#   Figure 3B: ASIR, single year
#   Figure 3C: ASMR, all years, 1990–2021
#   Figure 3D: ASMR, single year
#   Figure 3E: ASYR, all years, 1990–2021
#   Figure 3F: ASYR, single year
#
# Core functions:
#   easyGBDR::GBDfrontier()
#   easyGBDR::GBDfrontier_table()
#   easyGBDR::ggfrontier()
#
# Important:
#   This Figure 3 script DOES NOT calculate age-standardized rates.
#   It directly uses the under-5 rate already present in the GBD data:
#
#     age    = "<5"
#     metric = "Rate"
#
# Required downloaded/prepared GBD data:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Locations:   231 locations may be included in the raw file
#                Global + 5 SDI regions + 21 GBD regions
#                + 204 countries and territories
#   Model data:  only 204 countries and territories are used:
#                location %in% GBDRegion2021$location
#   Sex:         Both
#   Age:         <5
#   Metric:      Rate
#   Measures:    Incidence; Deaths; YLDs (Years Lived with Disability)
#   Years:       every year from 1990 through 2021
#
# Reviewer note:
#   For reproduction, reviewers only need to place the GBD CSV file(s) in the
#   clearly named raw-data folder below and run this script.
# =============================================================================

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. Required packages
# -----------------------------------------------------------------------------

required_packages <- c("easyGBDR", "ggplot2", "dplyr")

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
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(grid))

if ("GBD_edition" %in% getNamespaceExports("easyGBDR")) {
  GBD_edition(edition = 2021)
}

set.seed(20210708)

# -----------------------------------------------------------------------------
# 2. Project folders and reviewer-facing data names
# -----------------------------------------------------------------------------
#
# Recommended folder structure:
#
# D:/Figure3_Meningitis_Under5Rate_Frontier_Reproducibility/
# ├── 01_raw_GBD_data/
# │   └── Figure3_GBD2021_Meningitis_231Locations_BothSex_Under5_Rate_1990_2021/
# │       └── IHME-GBD_2021_DATA-xxxxxxxx.csv
# └── 02_Figure3_outputs/
#
# The raw-data folder name tells reviewers exactly what to download:
#   Figure 3 data, GBD 2021, meningitis, all 231 locations, both sexes,
#   under-5 age group, rate metric, and annual estimates from 1990 to 2021.
#
# The frontier analysis itself then restricts the dataset to 204 countries and
# territories using:
#   location %in% GBDRegion2021$location

PROJECT_DIR <- "D:/Figure3_Meningitis_Under5Rate_Frontier_Reproducibility"

RAW_GBD_FOLDER_NAME <- paste0(
  "Figure3_GBD2021_Meningitis_231Locations_",
  "BothSex_Under5_Rate_1990_2021"
)

RAW_GBD_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  RAW_GBD_FOLDER_NAME
)

OUTPUT_DIR <- file.path(PROJECT_DIR, "02_Figure3_outputs")

# -----------------------------------------------------------------------------
# 3. Figure 3 analysis settings
# -----------------------------------------------------------------------------

CAUSE_NAME <- "Meningitis"
SEX_NAME   <- "Both"

FRONTIER_AGE_NAME <- "<5"
FRONTIER_METRIC_NAME <- "Rate"

START_YEAR <- 1990
END_YEAR   <- 2021

BOOT_NUMBER <- 100
CPU_NUMBER  <- 10
SMOOTH_SPAN <- 0.3
HIGH_SDI_CUTOFF <- 0.85
LOW_SDI_CUTOFF  <- 0.50

# Approximate dimensions of the uploaded/reference Figure 3.
TIFF_WIDTH_PX  <- 3907
TIFF_HEIGHT_PX <- 4435
TIFF_DPI       <- 600

WRITE_PANEL_FILES <- TRUE
WRITE_FINAL_PDF <- FALSE

FIGURE3_MEASURE_SPECS <- list(
  list(
    measure_name = "Incidence",
    metric_short = "ASIR",
    all_years_panel_id = "Figure3A_ASIR_all_years",
    single_year_panel_id = "Figure3B_ASIR_single_year",
    all_years_panel_label = "A",
    single_year_panel_label = "B",
    y_axis_title = "ASIR (per 100,000)",
    model_input_file = "Figure3A_B_ASIR_Incidence_model_input_204Countries_Under5Rate_1990_2021.csv",
    table_file = "Figure3A_B_ASIR_Incidence_frontier_effective_difference_table.csv",
    all_years_pdf = "Figure3A_ASIR_Incidence_allYears_frontier_panel.pdf",
    single_year_pdf = "Figure3B_ASIR_Incidence_singleYear_frontier_panel.pdf",
    result_rds = "Figure3A_B_ASIR_Incidence_GBDfrontier_result.rds"
  ),
  list(
    measure_name = "Deaths",
    metric_short = "ASMR",
    all_years_panel_id = "Figure3C_ASMR_all_years",
    single_year_panel_id = "Figure3D_ASMR_single_year",
    all_years_panel_label = "C",
    single_year_panel_label = "D",
    y_axis_title = "ASMR (per 100,000)",
    model_input_file = "Figure3C_D_ASMR_Mortality_model_input_204Countries_Under5Rate_1990_2021.csv",
    table_file = "Figure3C_D_ASMR_Mortality_frontier_effective_difference_table.csv",
    all_years_pdf = "Figure3C_ASMR_Mortality_allYears_frontier_panel.pdf",
    single_year_pdf = "Figure3D_ASMR_Mortality_singleYear_frontier_panel.pdf",
    result_rds = "Figure3C_D_ASMR_Mortality_GBDfrontier_result.rds"
  ),
  list(
    measure_name = "YLDs (Years Lived with Disability)",
    metric_short = "ASYR",
    all_years_panel_id = "Figure3E_ASYR_all_years",
    single_year_panel_id = "Figure3F_ASYR_single_year",
    all_years_panel_label = "E",
    single_year_panel_label = "F",
    y_axis_title = "ASYR (per 100,000)",
    model_input_file = "Figure3E_F_ASYR_YLDs_model_input_204Countries_Under5Rate_1990_2021.csv",
    table_file = "Figure3E_F_ASYR_YLDs_frontier_effective_difference_table.csv",
    all_years_pdf = "Figure3E_ASYR_YLDs_allYears_frontier_panel.pdf",
    single_year_pdf = "Figure3F_ASYR_YLDs_singleYear_frontier_panel.pdf",
    result_rds = "Figure3E_F_ASYR_YLDs_GBDfrontier_result.rds"
  )
)

# -----------------------------------------------------------------------------
# 4. Helper functions
# -----------------------------------------------------------------------------

create_folder <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  return(path)
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

standardize_basic_columns <- function(data) {
  alias_pairs <- list(
    location = c("location", "location_name"),
    sex      = c("sex", "sex_name"),
    age      = c("age", "age_name"),
    cause    = c("cause", "cause_name"),
    measure  = c("measure", "measure_name"),
    metric   = c("metric", "metric_name"),
    year     = c("year"),
    val      = c("val", "mean", "value")
  )

  current_names_lower <- tolower(gsub("\\.", "_", names(data)))

  for (target_name in names(alias_pairs)) {
    if (!(target_name %in% names(data))) {
      aliases <- alias_pairs[[target_name]]
      match_index <- match(tolower(aliases), current_names_lower, nomatch = 0)
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
  data$sex      <- as.character(data$sex)
  data$age      <- as.character(data$age)
  data$cause    <- as.character(data$cause)
  data$measure  <- as.character(data$measure)
  data$metric   <- as.character(data$metric)
  data$year     <- as.numeric(as.character(data$year))
  data$val      <- as.numeric(as.character(data$val))

  return(data)
}

load_country_location_vector <- function() {
  if (!exists("GBDRegion2021")) {
    try(utils::data("GBDRegion2021", package = "easyGBDR"), silent = TRUE)
  }

  if (!exists("GBDRegion2021")) {
    stop(
      "Object 'GBDRegion2021' was not found. It should be available from ",
      "easyGBDR after GBD_edition(edition = 2021).",
      call. = FALSE
    )
  }

  if (!("location" %in% names(GBDRegion2021))) {
    stop(
      "GBDRegion2021 exists but does not contain a 'location' column.",
      call. = FALSE
    )
  }

  country_locations <- unique(as.character(GBDRegion2021$location))
  country_locations <- country_locations[!is.na(country_locations)]

  return(country_locations)
}

read_frontier_raw_data <- function(raw_folder) {
  if (!dir.exists(raw_folder)) {
    stop(
      "RAW_GBD_FOLDER does not exist:\n",
      raw_folder,
      "\n\nCreate this folder and place the downloaded IHME GBD CSV file(s) ",
      "inside it.",
      call. = FALSE
    )
  }

  raw_data <- GBDread(
    folder = TRUE,
    foldername = raw_folder
  )

  raw_data <- standardize_basic_columns(raw_data)

  return(raw_data)
}

check_frontier_input_data <- function(data, country_locations) {
  assert_values_exist(data, "location", country_locations)
  assert_values_exist(data, "sex", SEX_NAME)
  assert_values_exist(data, "age", FRONTIER_AGE_NAME)
  assert_values_exist(data, "cause", CAUSE_NAME)
  assert_values_exist(data, "metric", FRONTIER_METRIC_NAME)

  required_measures <- vapply(
    FIGURE3_MEASURE_SPECS,
    function(x) x$measure_name,
    character(1)
  )
  assert_values_exist(data, "measure", required_measures)

  available_years <- sort(unique(as.numeric(data$year)))
  required_years <- seq(START_YEAR, END_YEAR)
  missing_years <- setdiff(required_years, available_years)

  if (length(missing_years) > 0) {
    stop(
      "The following required years are missing: ",
      paste(missing_years, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

prepare_frontier_model_data <- function(raw_data, country_locations) {
  model_data <- raw_data[
    as.character(raw_data$location) %in% country_locations &
      as.character(raw_data$sex) == SEX_NAME &
      as.character(raw_data$age) == FRONTIER_AGE_NAME &
      as.character(raw_data$cause) == CAUSE_NAME &
      as.character(raw_data$metric) == FRONTIER_METRIC_NAME &
      as.numeric(raw_data$year) >= START_YEAR &
      as.numeric(raw_data$year) <= END_YEAR,
    ,
    drop = FALSE
  ]

  model_data$location <- as.character(model_data$location)

  model_data <- model_data[
    order(
      model_data$measure,
      model_data$location,
      as.numeric(model_data$year)
    ),
    ,
    drop = FALSE
  ]

  rownames(model_data) <- NULL

  if (nrow(model_data) == 0) {
    stop(
      "No data remained after applying the Figure 3 frontier filters.",
      call. = FALSE
    )
  }

  observed_country_count <- length(unique(as.character(model_data$location)))
  expected_country_count <- length(country_locations)

  if (observed_country_count != expected_country_count) {
    stop(
      "The filtered model data contain ", observed_country_count,
      " countries/territories, but GBDRegion2021 contains ",
      expected_country_count, ". Please check country/territory location names.",
      call. = FALSE
    )
  }

  return(model_data)
}

check_measure_panel_data <- function(model_data, measure_name, country_locations) {
  current_data <- model_data[
    as.character(model_data$measure) == measure_name,
    ,
    drop = FALSE
  ]

  if (nrow(current_data) == 0) {
    stop(
      "No rows found for measure: ", measure_name,
      call. = FALSE
    )
  }

  if (any(is.na(current_data$val)) || any(!is.finite(current_data$val))) {
    stop(
      "The 'val' column contains missing or non-finite values for ",
      measure_name,
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
      "Duplicate location-year rows were found for ", measure_name,
      ". Confirm that only age = '", FRONTIER_AGE_NAME,
      "' and metric = '", FRONTIER_METRIC_NAME, "' are retained.",
      call. = FALSE
    )
  }

  expected_years <- seq(START_YEAR, END_YEAR)
  years_by_location <- split(
    as.numeric(current_data$year),
    as.character(current_data$location)
  )

  incomplete_locations <- names(years_by_location)[
    vapply(
      years_by_location,
      function(years) {
        !identical(sort(unique(years)), expected_years)
      },
      logical(1)
    )
  ]

  if (length(incomplete_locations) > 0) {
    stop(
      "The following countries/territories do not include every year from ",
      START_YEAR, " through ", END_YEAR, " for ", measure_name, ":\n",
      paste(incomplete_locations, collapse = "\n"),
      call. = FALSE
    )
  }

  missing_locations <- setdiff(country_locations, unique(as.character(current_data$location)))
  if (length(missing_locations) > 0) {
    stop(
      "The following countries/territories are missing for ", measure_name, ":\n",
      paste(missing_locations, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

adjust_cpu_number <- function(boot_number, requested_cpu_number) {
  detected_cores <- parallel::detectCores()
  cpu_number <- requested_cpu_number

  if (!is.na(detected_cores)) {
    cpu_number <- min(cpu_number, detected_cores)
  }

  cpu_number <- max(1, cpu_number)

  while (boot_number %% cpu_number != 0 && cpu_number > 1) {
    cpu_number <- cpu_number - 1
  }

  if (boot_number %% cpu_number != 0) {
    cpu_number <- 1
  }

  return(cpu_number)
}

make_frontier_panel <- function(frontier_result, panel_label, panel_type, y_axis_title) {
  if (panel_type == "all years") {
    panel_plot <- ggfrontier(
      frontier_result = frontier_result,
      smooth_span = SMOOTH_SPAN,
      type = c("all years"),
      high_SDI = HIGH_SDI_CUTOFF,
      low_SDI = LOW_SDI_CUTOFF
    ) +
      scale_color_gradient(low = "blue", high = "red")
  } else if (panel_type == "single year") {
    panel_plot <- ggfrontier(
      frontier_result = frontier_result,
      smooth_span = SMOOTH_SPAN,
      type = c("single year"),
      high_SDI = HIGH_SDI_CUTOFF,
      low_SDI = LOW_SDI_CUTOFF
    ) +
      scale_color_manual(values = c("red", "blue"))
  } else {
    stop("panel_type must be 'all years' or 'single year'.", call. = FALSE)
  }

  panel_plot <- panel_plot +
    labs(
      title = panel_label,
      x = "SDI",
      y = y_axis_title
    ) +
    theme(
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      axis.line = element_line(color = "black"),
      axis.ticks = element_line(color = "black"),
      axis.text.x = element_text(size = 8),
      axis.text.y = element_text(size = 8),
      axis.title.x = element_text(size = 10),
      axis.title.y = element_text(size = 10),
      plot.title = element_text(face = "bold", size = 14, hjust = 0),
      legend.title = element_text(size = 8),
      legend.text = element_text(size = 7),
      legend.key.width = unit(0.35, "cm"),
      legend.key.height = unit(0.30, "cm")
    )

  return(panel_plot)
}

save_six_panel_tiff <- function(
  panel_a,
  panel_b,
  panel_c,
  panel_d,
  panel_e,
  panel_f,
  output_file
) {
  grDevices::tiff(
    filename = output_file,
    width = TIFF_WIDTH_PX,
    height = TIFF_HEIGHT_PX,
    units = "px",
    res = TIFF_DPI,
    compression = "lzw"
  )

  grid::grid.newpage()

  figure_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 3,
      ncol = 2,
      widths = grid::unit(c(1, 1), "null"),
      heights = grid::unit(c(1, 1, 1), "null")
    )
  )

  grid::pushViewport(figure_layout)

  print(panel_a, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1), newpage = FALSE)
  print(panel_b, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2), newpage = FALSE)
  print(panel_c, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1), newpage = FALSE)
  print(panel_d, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 2), newpage = FALSE)
  print(panel_e, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 1), newpage = FALSE)
  print(panel_f, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 2), newpage = FALSE)

  grid::upViewport()
  grDevices::dev.off()
}

save_six_panel_pdf <- function(
  panel_a,
  panel_b,
  panel_c,
  panel_d,
  panel_e,
  panel_f,
  output_file
) {
  grDevices::pdf(
    file = output_file,
    width = TIFF_WIDTH_PX / TIFF_DPI,
    height = TIFF_HEIGHT_PX / TIFF_DPI
  )

  grid::grid.newpage()

  figure_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 3,
      ncol = 2,
      widths = grid::unit(c(1, 1), "null"),
      heights = grid::unit(c(1, 1, 1), "null")
    )
  )

  grid::pushViewport(figure_layout)

  print(panel_a, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1), newpage = FALSE)
  print(panel_b, vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2), newpage = FALSE)
  print(panel_c, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 1), newpage = FALSE)
  print(panel_d, vp = grid::viewport(layout.pos.row = 2, layout.pos.col = 2), newpage = FALSE)
  print(panel_e, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 1), newpage = FALSE)
  print(panel_f, vp = grid::viewport(layout.pos.row = 3, layout.pos.col = 2), newpage = FALSE)

  grid::upViewport()
  grDevices::dev.off()
}

write_reproducibility_files <- function(output_folder, country_locations, effective_cpu_number) {
  manifest <- data.frame(
    item = c(
      "Figure",
      "GBD release",
      "Cause",
      "Raw downloaded locations",
      "Frontier model locations",
      "Sex",
      "Age used for frontier model",
      "Metric used for frontier model",
      "Measures",
      "Years",
      "Frontier bootstrap iterations",
      "CPU number used",
      "Smooth span",
      "High SDI cutoff",
      "Low SDI cutoff",
      "Core functions",
      "Raw data folder name",
      "Final TIFF"
    ),
    required_selection = c(
      "Figure 3",
      "GBD 2021",
      CAUSE_NAME,
      "231 locations: Global + 5 SDI regions + 21 GBD regions + 204 countries/territories",
      paste0(length(country_locations), " countries/territories from GBDRegion2021$location"),
      SEX_NAME,
      FRONTIER_AGE_NAME,
      FRONTIER_METRIC_NAME,
      "Incidence; Deaths; YLDs (Years Lived with Disability)",
      paste0(START_YEAR, "–", END_YEAR, " (every individual year)"),
      as.character(BOOT_NUMBER),
      as.character(effective_cpu_number),
      as.character(SMOOTH_SPAN),
      as.character(HIGH_SDI_CUTOFF),
      as.character(LOW_SDI_CUTOFF),
      "GBDfrontier(); GBDfrontier_table(); ggfrontier()",
      RAW_GBD_FOLDER_NAME,
      "Figure 3.tif"
    ),
    stringsAsFactors = FALSE
  )

  write.csv(
    manifest,
    file = file.path(output_folder, "00_Figure3_data_download_and_reproduction_manifest.csv"),
    row.names = FALSE
  )

  write.csv(
    data.frame(
      country_order = seq_along(country_locations),
      location = country_locations,
      stringsAsFactors = FALSE
    ),
    file = file.path(output_folder, "00_Figure3_204_country_and_territory_locations_used.csv"),
    row.names = FALSE
  )

  readme_lines <- c(
    "Figure 3 reproducibility package",
    "================================",
    "",
    "Final figure:",
    "  Figure 3.tif",
    "",
    "Panels:",
    "  Figure 3A: ASIR frontier analysis, all years, 1990–2021",
    "  Figure 3B: ASIR frontier analysis, single year",
    "  Figure 3C: ASMR frontier analysis, all years, 1990–2021",
    "  Figure 3D: ASMR frontier analysis, single year",
    "  Figure 3E: ASYR frontier analysis, all years, 1990–2021",
    "  Figure 3F: ASYR frontier analysis, single year",
    "",
    "Raw input data folder:",
    paste0("  ", RAW_GBD_FOLDER_NAME),
    "",
    "Required GBD data selections:",
    "  GBD 2021; cause = Meningitis; sex = Both;",
    "  age = <5; metric = Rate;",
    "  measures = Incidence, Deaths, YLDs;",
    "  years = 1990–2021;",
    "  locations = 231 locations may be downloaded, but only 204 countries",
    "  and territories from GBDRegion2021$location are used in the frontier model.",
    "",
    "Important:",
    "  This script does not run GBDage_recal(). It directly uses the <5 Rate",
    "  already present in the imported GBD data.",
    "",
    "Main outputs:",
    "  01_Figure3_model_input_data: exact 204-country input data used for models",
    "  02_Figure3_frontier_results: saved GBDfrontier() result objects",
    "  03_Figure3_frontier_tables: effective-difference frontier tables",
    "  04_Figure3_panel_figures: Figure 3A–3F single-panel PDFs",
    "  05_final_Figure3: final six-panel Figure 3 TIFF",
    "  06_saved_R_objects: saved ggplot objects and model-result lists"
  )

  writeLines(
    readme_lines,
    con = file.path(output_folder, "00_README_Figure3_reproducibility.txt")
  )
}

# -----------------------------------------------------------------------------
# 5. Create output folders
# -----------------------------------------------------------------------------

MODEL_INPUT_DIR <- create_folder(file.path(OUTPUT_DIR, "01_Figure3_model_input_data"))
FRONTIER_RESULT_DIR <- create_folder(file.path(OUTPUT_DIR, "02_Figure3_frontier_results"))
FRONTIER_TABLE_DIR <- create_folder(file.path(OUTPUT_DIR, "03_Figure3_frontier_tables"))
PANEL_FIGURE_DIR <- create_folder(file.path(OUTPUT_DIR, "04_Figure3_panel_figures"))
FINAL_FIGURE_DIR <- create_folder(file.path(OUTPUT_DIR, "05_final_Figure3"))
OBJECT_DIR <- create_folder(file.path(OUTPUT_DIR, "06_saved_R_objects"))

# -----------------------------------------------------------------------------
# 6. Read and validate data
# -----------------------------------------------------------------------------

country_locations <- load_country_location_vector()

if (length(country_locations) != 204) {
  warning(
    "GBDRegion2021$location contains ", length(country_locations),
    " locations, not 204. The script will still use this vector as the ",
    "country/territory reference."
  )
}

raw_frontier_data <- read_frontier_raw_data(
  raw_folder = RAW_GBD_FOLDER
)

available_labels <- list(
  location = unique(raw_frontier_data$location),
  sex = unique(raw_frontier_data$sex),
  age = unique(raw_frontier_data$age),
  cause = unique(raw_frontier_data$cause),
  measure = unique(raw_frontier_data$measure),
  metric = unique(raw_frontier_data$metric),
  year = sort(unique(raw_frontier_data$year))
)

saveRDS(
  available_labels,
  file = file.path(OUTPUT_DIR, "00_available_GBD_labels_in_raw_Figure3_data.rds")
)

cat("\nAvailable labels in the raw Figure 3 data:\n")
cat("Locations: ", length(available_labels$location), "\n", sep = "")
cat("Sex: ", paste(available_labels$sex, collapse = " | "), "\n", sep = "")
cat("Age: ", paste(available_labels$age, collapse = " | "), "\n", sep = "")
cat("Cause: ", paste(available_labels$cause, collapse = " | "), "\n", sep = "")
cat("Measure: ", paste(available_labels$measure, collapse = " | "), "\n", sep = "")
cat("Metric: ", paste(available_labels$metric, collapse = " | "), "\n", sep = "")
cat("Years: ", paste(range(available_labels$year), collapse = "–"), "\n", sep = "")

check_frontier_input_data(
  data = raw_frontier_data,
  country_locations = country_locations
)

frontier_model_data <- prepare_frontier_model_data(
  raw_data = raw_frontier_data,
  country_locations = country_locations
)

write.csv(
  frontier_model_data,
  file = file.path(
    MODEL_INPUT_DIR,
    "Figure3_allMeasures_model_input_204Countries_BothSex_Under5Rate_1990_2021.csv"
  ),
  row.names = FALSE
)

effective_cpu_number <- adjust_cpu_number(
  boot_number = BOOT_NUMBER,
  requested_cpu_number = CPU_NUMBER
)

write_reproducibility_files(
  output_folder = OUTPUT_DIR,
  country_locations = country_locations,
  effective_cpu_number = effective_cpu_number
)

# -----------------------------------------------------------------------------
# 7. Run frontier models and generate Figure 3A–3F panels
# -----------------------------------------------------------------------------

frontier_results_by_measure <- list()
frontier_tables_by_measure <- list()
figure3_panels <- list()

for (measure_index in seq_along(FIGURE3_MEASURE_SPECS)) {

  current_spec <- FIGURE3_MEASURE_SPECS[[measure_index]]

  cat("\n============================================================\n")
  cat("Running Figure 3 frontier analysis: ", current_spec$metric_short, "\n", sep = "")
  cat("Measure: ", current_spec$measure_name, "\n", sep = "")
  cat("============================================================\n")

  check_measure_panel_data(
    model_data = frontier_model_data,
    measure_name = current_spec$measure_name,
    country_locations = country_locations
  )

  current_measure_input <- frontier_model_data[
    as.character(frontier_model_data$measure) == current_spec$measure_name,
    ,
    drop = FALSE
  ]

  write.csv(
    current_measure_input,
    file = file.path(MODEL_INPUT_DIR, current_spec$model_input_file),
    row.names = FALSE
  )

  frontier_result <- GBDfrontier(
    data = current_measure_input,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    measure_name = current_spec$measure_name,
    rei_name = NULL,
    age_name = FRONTIER_AGE_NAME,
    boot = BOOT_NUMBER,
    cpu_num = effective_cpu_number
  )

  frontier_results_by_measure[[current_spec$metric_short]] <- frontier_result

  saveRDS(
    frontier_result,
    file = file.path(FRONTIER_RESULT_DIR, current_spec$result_rds)
  )

  frontier_table <- GBDfrontier_table(
    frontier_result = frontier_result,
    data = current_measure_input,
    digits = 2,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    measure_name = current_spec$measure_name,
    age_name = FRONTIER_AGE_NAME,
    rei_name = NULL
  )

  frontier_tables_by_measure[[current_spec$metric_short]] <- frontier_table

  write.csv(
    frontier_table,
    file = file.path(FRONTIER_TABLE_DIR, current_spec$table_file),
    row.names = FALSE
  )

  panel_all_years <- make_frontier_panel(
    frontier_result = frontier_result,
    panel_label = current_spec$all_years_panel_label,
    panel_type = "all years",
    y_axis_title = current_spec$y_axis_title
  )

  panel_single_year <- make_frontier_panel(
    frontier_result = frontier_result,
    panel_label = current_spec$single_year_panel_label,
    panel_type = "single year",
    y_axis_title = current_spec$y_axis_title
  )

  figure3_panels[[current_spec$all_years_panel_id]] <- panel_all_years
  figure3_panels[[current_spec$single_year_panel_id]] <- panel_single_year

  if (WRITE_PANEL_FILES) {
    ggsave(
      filename = file.path(PANEL_FIGURE_DIR, current_spec$all_years_pdf),
      plot = panel_all_years,
      width = 6,
      height = 4,
      dpi = 600
    )

    ggsave(
      filename = file.path(PANEL_FIGURE_DIR, current_spec$single_year_pdf),
      plot = panel_single_year,
      width = 6,
      height = 4,
      dpi = 600
    )
  }
}

# -----------------------------------------------------------------------------
# 8. Save final six-panel Figure 3
# -----------------------------------------------------------------------------

figure3_tiff_path <- file.path(FINAL_FIGURE_DIR, "Figure 3.tif")

save_six_panel_tiff(
  panel_a = figure3_panels[["Figure3A_ASIR_all_years"]],
  panel_b = figure3_panels[["Figure3B_ASIR_single_year"]],
  panel_c = figure3_panels[["Figure3C_ASMR_all_years"]],
  panel_d = figure3_panels[["Figure3D_ASMR_single_year"]],
  panel_e = figure3_panels[["Figure3E_ASYR_all_years"]],
  panel_f = figure3_panels[["Figure3F_ASYR_single_year"]],
  output_file = figure3_tiff_path
)

if (WRITE_FINAL_PDF) {
  figure3_pdf_path <- file.path(FINAL_FIGURE_DIR, "Figure 3.pdf")

  save_six_panel_pdf(
    panel_a = figure3_panels[["Figure3A_ASIR_all_years"]],
    panel_b = figure3_panels[["Figure3B_ASIR_single_year"]],
    panel_c = figure3_panels[["Figure3C_ASMR_all_years"]],
    panel_d = figure3_panels[["Figure3D_ASMR_single_year"]],
    panel_e = figure3_panels[["Figure3E_ASYR_all_years"]],
    panel_f = figure3_panels[["Figure3F_ASYR_single_year"]],
    output_file = figure3_pdf_path
  )
}

saveRDS(
  frontier_results_by_measure,
  file = file.path(OBJECT_DIR, "Figure3_frontier_results_by_measure_ASIR_ASMR_ASYR.rds")
)

saveRDS(
  frontier_tables_by_measure,
  file = file.path(OBJECT_DIR, "Figure3_frontier_tables_by_measure_ASIR_ASMR_ASYR.rds")
)

saveRDS(
  figure3_panels,
  file = file.path(OBJECT_DIR, "Figure3_panel_ggplot_objects_A_to_F.rds")
)

capture.output(
  sessionInfo(),
  file = file.path(OUTPUT_DIR, "00_R_sessionInfo.txt")
)

cat("\n============================================================\n")
cat("Figure 3 frontier analysis completed successfully.\n")
cat("Final figure: ", normalizePath(figure3_tiff_path, winslash = "/", mustWork = FALSE), "\n", sep = "")
cat("Output folder: ", normalizePath(OUTPUT_DIR, winslash = "/", mustWork = FALSE), "\n", sep = "")
cat("Countries/territories used: ", length(country_locations), "\n", sep = "")
cat("Age used: ", FRONTIER_AGE_NAME, "\n", sep = "")
cat("Metric used: ", FRONTIER_METRIC_NAME, "\n", sep = "")
cat("Bootstrap iterations: ", BOOT_NUMBER, "\n", sep = "")
cat("CPU number used: ", effective_cpu_number, "\n", sep = "")
cat("============================================================\n")

# =============================================================================
# End of script
# =============================================================================
