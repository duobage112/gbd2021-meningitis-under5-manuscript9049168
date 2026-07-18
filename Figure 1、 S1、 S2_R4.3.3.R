# =============================================================================
# Reproducibility Script A:
# Figures only
#
# Outputs only:
#   Figure 1.tif
#   Additional file 1 Fig. S1.tif
#   Additional file 1 Fig. S2.tif
#
# Raw GBD data folder expected by this script:
#   Figure1_FigS1_FigS2_Global_BothSex_AgeSpecific_Incidence_Deaths_YLD_Rate_1990_2021
#
# Reviewer-facing design:
#   1. The raw-data folder name explicitly states the required location, sex,
#      age level, measures, metric and year range.
#   2. The script prints a raw-data download manifest before reading data.
#   3. Each figure section directly shows the easyGBDR::GBDage_aapc() call.
#
# R version: 3.3.3 compatible
# =============================================================================

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. Packages
# -----------------------------------------------------------------------------

required_packages <- c("easyGBDR", "ggsci")

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
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(grid))

if ("GBD_edition" %in% ls("package:easyGBDR")) {
  GBD_edition(edition = 2021)
}

# -----------------------------------------------------------------------------
# 2. Project paths and reviewer-facing raw-data folder name
# -----------------------------------------------------------------------------
#
# Reviewer-facing raw GBD Results download requirement:
#
#   Place the downloaded IHME GBD 2021 CSV file(s) for Figure 1,
#   Additional file 1 Fig. S1 and Additional file 1 Fig. S2 into:
#
#     D:/Meningitis_Joinpoint_Reproducibility/01_raw_GBD_data/
#       Figure1_FigS1_FigS2_Global_BothSex_AgeSpecific_Incidence_Deaths_YLD_Rate_1990_2021/
#
# Required GBD Results selections:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Location:    Global
#   Sex:         Both
#   Metric:      Rate
#   Measures:    Incidence; Deaths; YLDs (Years Lived with Disability)
#   Years:       Every individual year from 1990 through 2021
#   Ages:        <5 / 0 to 4 / Under 5 years;
#                1 to 5 months; 6 to 11 months;
#                12 to 23 months; 2 to 4 years;
#                Early Neonatal / 0-6 days;
#                Neonatal / <28 days;
#                Late Neonatal / 7-27 days
#
# The folder name is intentionally descriptive and reviewer-facing. It is not
# required to match IHME's default downloaded ZIP/CSV name. Reviewers only need
# to place the corresponding downloaded CSV file(s) inside this folder.

PROJECT_DIR <- "D:/Meningitis_Joinpoint_Reproducibility"

# Reviewer-facing folder name for the raw data used by Figure 1, Fig. S1 and Fig. S2.
# The name encodes: figures, location, sex, age level, measures, metric and years.
FIGURE_RAW_DATA_FOLDER_NAME <- paste0(
  "Figure1_FigS1_FigS2_Global_BothSex_",
  "AgeSpecific_Incidence_Deaths_YLD_Rate_1990_2021"
)

FIGURE_INPUT_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  FIGURE_RAW_DATA_FOLDER_NAME
)

# This script writes only the three TIFF figure files into this folder.
FIGURE_OUTPUT_DIR <- file.path(
  PROJECT_DIR,
  "02_figure_output"
)

# -----------------------------------------------------------------------------
# 3. Analysis settings
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

TIFF_WIDTH_PX  <- 4017
TIFF_HEIGHT_PX <- 1891
TIFF_DPI       <- 600

FIGURE_SPECS <- list(
  list(
    figure_id = "Figure_1_YLD_rate",
    figure_file = "Figure 1.tif",
    figure_label = "Figure 1",
    measure_name = "YLDs (Years Lived with Disability)",
    outcome_label = "YLD rate"
  ),
  list(
    figure_id = "Figure_S1_Incidence_rate",
    figure_file = "Additional file 1 Fig. S1.tif",
    figure_label = "Additional file 1 Fig. S1",
    measure_name = "Incidence",
    outcome_label = "Incidence rate"
  ),
  list(
    figure_id = "Figure_S2_Death_rate",
    figure_file = "Additional file 1 Fig. S2.tif",
    figure_label = "Additional file 1 Fig. S2",
    measure_name = "Deaths",
    outcome_label = "Death rate"
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

print_raw_data_download_manifest <- function() {
  manifest <- data.frame(
    Analysis = "Figure 1; Additional file 1 Fig. S1; Additional file 1 Fig. S2",
    Raw_data_folder = FIGURE_RAW_DATA_FOLDER_NAME,
    Location = LOCATION_NAME,
    Sex = SEX_NAME,
    Cause = CAUSE_NAME,
    Measures = "YLDs (Years Lived with Disability); Incidence; Deaths",
    Metric = METRIC_NAME,
    Age_groups = paste(
      "<5 / 0 to 4 / Under 5 years;",
      "1 to 5 months;",
      "6 to 11 months;",
      "12 to 23 months;",
      "2 to 4 years;",
      "Early Neonatal / 0-6 days;",
      "Neonatal / <28 days;",
      "Late Neonatal / 7-27 days"
    ),
    Years = "1990-2021, every individual year",
    stringsAsFactors = FALSE
  )

  cat("\n=================================================================\n")
  cat("Reviewer-facing raw GBD data download manifest\n")
  cat("Place downloaded IHME GBD 2021 CSV file(s) into this folder:\n")
  cat(
    "  ",
    normalizePath(FIGURE_INPUT_FOLDER, winslash = "/", mustWork = FALSE),
    "\n",
    sep = ""
  )
  cat("=================================================================\n")
  print(manifest, row.names = FALSE)
  cat("=================================================================\n\n")

  invisible(manifest)
}

assert_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      "Required data column(s) are missing: ",
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

read_gbd_data_for_figures <- function(input_folder) {
  if (!dir.exists(input_folder)) {
    stop(
      "FIGURE_INPUT_FOLDER does not exist:\n",
      input_folder,
      "\n\nCreate this reviewer-facing folder and place the downloaded IHME GBD 2021 CSV file(s) inside it.",
      call. = FALSE
    )
  }

  data <- GBDread(
    folder = TRUE,
    foldername = input_folder
  )

  required_columns <- c(
    "location", "sex", "age", "cause", "measure",
    "metric", "year", "val"
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

filter_figure_input_data <- function(
  data,
  measure_name,
  required_ages,
  location_name,
  sex_name,
  cause_name,
  metric_name,
  start_year,
  end_year
) {
  selected_data <- data[
    as.character(data$location) == location_name &
      as.character(data$sex) == sex_name &
      as.character(data$cause) == cause_name &
      as.character(data$metric) == metric_name &
      as.character(data$measure) == measure_name &
      as.character(data$age) %in% required_ages &
      as.numeric(data$year) >= start_year &
      as.numeric(data$year) <= end_year,
    ,
    drop = FALSE
  ]

  selected_data <- selected_data[
    order(
      selected_data$measure,
      selected_data$location,
      selected_data$sex,
      selected_data$age,
      selected_data$year
    ),
    ,
    drop = FALSE
  ]

  rownames(selected_data) <- NULL

  if (nrow(selected_data) == 0) {
    stop(
      "No rows remained after filtering figure data for measure: ",
      measure_name,
      call. = FALSE
    )
  }

  return(selected_data)
}

check_joinpoint_input <- function(data, analysis_label, start_year, end_year) {
  if (!("val" %in% names(data))) {
    stop(
      "The input data must contain a column named 'val' for: ",
      analysis_label,
      call. = FALSE
    )
  }

  data$val <- as.numeric(as.character(data$val))

  if (any(is.na(data$val)) || any(!is.finite(data$val))) {
    stop(
      "Column 'val' contains missing or non-finite values for: ",
      analysis_label,
      call. = FALSE
    )
  }

  if (any(data$val <= 0)) {
    stop(
      "At least one rate is zero or negative for: ",
      analysis_label,
      ". The log-linear Joinpoint model requires strictly positive values.",
      call. = FALSE
    )
  }

  time_series_key <- paste(
    data$location,
    data$sex,
    data$cause,
    data$measure,
    data$age,
    sep = "___"
  )

  duplicate_key <- paste(time_series_key, data$year, sep = "___")

  if (anyDuplicated(duplicate_key) > 0) {
    stop(
      "Duplicate observations were found within a ",
      "location-sex-cause-measure-age-year series for: ",
      analysis_label,
      call. = FALSE
    )
  }

  required_years <- seq(start_year, end_year)

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
      "The following time series do not contain every year from ",
      start_year, " through ", end_year, " for: ", analysis_label, "\n",
      paste(incomplete_series, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

validate_figure_joinpoint_result <- function(joinpoint_result, analysis_label) {
  required_result_names <- c("AAPC", "APC", "data")

  missing_result_names <- required_result_names[
    !required_result_names %in% names(joinpoint_result)
  ]

  if (length(missing_result_names) > 0) {
    stop(
      "Joinpoint result is incomplete for: ",
      analysis_label,
      "\nMissing component(s): ",
      paste(missing_result_names, collapse = ", "),
      "\nExpected core outputs include result[['AAPC']], result[['APC']] and result[['data']].",
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

make_age_panel <- function(
  joinpoint_result,
  measure_name,
  location_name,
  age_names,
  colors,
  shapes
) {
  ggjoinpoint_compare(
    data = joinpoint_result,
    group_name = "age",
    measure_name = measure_name,
    cause_name = CAUSE_NAME,
    nudge_y = -0.5,
    sex_name = SEX_NAME,
    location_name = location_name,
    age_name = age_names,
    rei_name = NULL,
    facet_name = NULL,
    color_name = colors,
    shape_name = shapes,
    line_size = 1
  )
}

save_two_panel_tiff <- function(panel_a, panel_b, output_file) {
  grDevices::tiff(
    filename = output_file,
    width = TIFF_WIDTH_PX,
    height = TIFF_HEIGHT_PX,
    units = "px",
    res = TIFF_DPI,
    compression = "lzw"
  )

  grid::grid.newpage()

  panel_layout <- grid::viewport(
    layout = grid::grid.layout(
      nrow = 1,
      ncol = 2,
      widths = grid::unit(c(1, 1), "null")
    )
  )

  grid::pushViewport(panel_layout)

  print(
    panel_a,
    vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 1),
    newpage = FALSE
  )

  print(
    panel_b,
    vp = grid::viewport(layout.pos.row = 1, layout.pos.col = 2),
    newpage = FALSE
  )

  grid::upViewport()

  grid::grid.text(
    label = "A",
    x = grid::unit(0.015, "npc"),
    y = grid::unit(0.970, "npc"),
    just = c("left", "top"),
    gp = grid::gpar(fontface = "bold", fontsize = 18)
  )

  grid::grid.text(
    label = "B",
    x = grid::unit(0.510, "npc"),
    y = grid::unit(0.970, "npc"),
    just = c("left", "top"),
    gp = grid::gpar(fontface = "bold", fontsize = 18)
  )

  grDevices::dev.off()
}

# -----------------------------------------------------------------------------
# 5. Read and validate raw data
# -----------------------------------------------------------------------------

print_raw_data_download_manifest()

FIGURE_OUTPUT_DIR <- create_folder(FIGURE_OUTPUT_DIR)

figure1_figs1_figs2_global_age_specific_raw_data <- read_gbd_data_for_figures(
  FIGURE_INPUT_FOLDER
)

assert_values_exist(
  figure1_figs1_figs2_global_age_specific_raw_data,
  "location",
  LOCATION_NAME
)

assert_values_exist(
  figure1_figs1_figs2_global_age_specific_raw_data,
  "sex",
  SEX_NAME
)

assert_values_exist(
  figure1_figs1_figs2_global_age_specific_raw_data,
  "cause",
  CAUSE_NAME
)

assert_values_exist(
  figure1_figs1_figs2_global_age_specific_raw_data,
  "metric",
  METRIC_NAME
)

figure_measures <- vapply(
  FIGURE_SPECS,
  function(specification) specification$measure_name,
  character(1)
)

assert_values_exist(
  figure1_figs1_figs2_global_age_specific_raw_data,
  "measure",
  figure_measures
)

# -----------------------------------------------------------------------------
# 6. Resolve age labels
# -----------------------------------------------------------------------------

available_ages <- unique(figure1_figs1_figs2_global_age_specific_raw_data$age)

AGE_UNDER_FIVE_TOTAL <- resolve_age_label(
  available_ages = available_ages,
  candidates = c(
    "<5", "0 to 4", "< 5",
    "Under 5", "Under 5 years",
    "0 to 4 years", "0-4 years"
  ),
  description = "under-five total"
)

AGE_1_TO_5_MONTHS <- resolve_age_label(
  available_ages = available_ages,
  candidates = c("1 to 5 months", "1-5 months"),
  description = "1 to 5 months"
)

AGE_6_TO_11_MONTHS <- resolve_age_label(
  available_ages = available_ages,
  candidates = c("6 to 11 months", "6-11 months"),
  description = "6 to 11 months"
)

AGE_12_TO_23_MONTHS <- resolve_age_label(
  available_ages = available_ages,
  candidates = c("12 to 23 months", "12-23 months"),
  description = "12 to 23 months"
)

AGE_2_TO_4_YEARS <- resolve_age_label(
  available_ages = available_ages,
  candidates = c("2 to 4", "2-4 years", "2 to 4 years"),
  description = "2 to 4 years"
)

AGE_EARLY_NEONATAL <- resolve_age_label(
  available_ages = available_ages,
  candidates = c(
    "Early Neonatal", "Early neonatal",
    "0 to 6 days", "0-6 days", "0 to 6"
  ),
  description = "early neonatal age group"
)

AGE_NEONATAL_TOTAL <- resolve_age_label(
  available_ages = available_ages,
  candidates = c(
    "Neonatal", "Neonatal period",
    "<28 days", "< 28 days",
    "0 to 27 days", "0-27 days", "0 to 28 days"
  ),
  description = "neonatal total"
)

AGE_LATE_NEONATAL <- resolve_age_label(
  available_ages = available_ages,
  candidates = c(
    "Late Neonatal", "Late neonatal",
    "7 to 27 days", "7-27 days", "7 to 27"
  ),
  description = "late neonatal age group"
)

PANEL_A_AGE_GROUPS <- c(
  AGE_1_TO_5_MONTHS,
  AGE_6_TO_11_MONTHS,
  AGE_12_TO_23_MONTHS,
  AGE_2_TO_4_YEARS,
  AGE_UNDER_FIVE_TOTAL
)

PANEL_B_AGE_GROUPS <- c(
  AGE_EARLY_NEONATAL,
  AGE_NEONATAL_TOTAL,
  AGE_LATE_NEONATAL
)

MODEL_AGE_GROUPS <- unique(c(PANEL_A_AGE_GROUPS, PANEL_B_AGE_GROUPS))

# -----------------------------------------------------------------------------
# 7. Visual coding
# -----------------------------------------------------------------------------

LANCET_COLORS <- ggsci::pal_lancet("lanonc")(9)

PANEL_A_COLORS <- LANCET_COLORS[c(1, 2, 3, 4, 5)]
PANEL_A_SHAPES <- c(17, 18, 16, 16, 1)

PANEL_B_COLORS <- LANCET_COLORS[c(6, 7, 8)]
PANEL_B_SHAPES <- c(16, 16, 1)

# -----------------------------------------------------------------------------
# 8. Fit Joinpoint models and output only the three TIFF figures
# -----------------------------------------------------------------------------

for (figure_index in seq_along(FIGURE_SPECS)) {
  current_figure <- FIGURE_SPECS[[figure_index]]

  cat("\n=================================================================\n")
  cat("Reproducing ", current_figure$figure_label, "\n", sep = "")
  cat("Outcome: ", current_figure$outcome_label, "\n", sep = "")
  cat("Measure: ", current_figure$measure_name, "\n", sep = "")
  cat("=================================================================\n")

  figure_input_data <- filter_figure_input_data(
    data = figure1_figs1_figs2_global_age_specific_raw_data,
    measure_name = current_figure$measure_name,
    required_ages = MODEL_AGE_GROUPS,
    location_name = LOCATION_NAME,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    metric_name = METRIC_NAME,
    start_year = START_YEAR,
    end_year = END_YEAR
  )

  current_joinpoint_label <- paste(
    current_figure$figure_label,
    current_figure$outcome_label,
    sep = " - "
  )

  check_joinpoint_input(
    data = figure_input_data,
    analysis_label = current_joinpoint_label,
    start_year = START_YEAR,
    end_year = END_YEAR
  )

  cat(
    "Running easyGBDR::GBDage_aapc() for ",
    current_joinpoint_label,
    "\n",
    sep = ""
  )

  # ---------------------------------------------------------------------------
  # Core Joinpoint analysis step for the current figure
  # ---------------------------------------------------------------------------
  # This explicit GBDage_aapc() call is intentionally kept inside the figure
  # loop so reviewers can verify that Figure 1, Fig. S1 and Fig. S2 each use a
  # complete Joinpoint analysis based on the corresponding measure.
  # ---------------------------------------------------------------------------

  result_figure_joinpoint_current <- GBDage_aapc(
    data = figure_input_data,
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

  validate_figure_joinpoint_result(
    joinpoint_result = result_figure_joinpoint_current,
    analysis_label = current_joinpoint_label
  )

  figure_joinpoint_result <- result_figure_joinpoint_current

  figure_panel_a <- make_age_panel(
    joinpoint_result = figure_joinpoint_result,
    measure_name = current_figure$measure_name,
    location_name = LOCATION_NAME,
    age_names = PANEL_A_AGE_GROUPS,
    colors = PANEL_A_COLORS,
    shapes = PANEL_A_SHAPES
  )

  figure_panel_b <- make_age_panel(
    joinpoint_result = figure_joinpoint_result,
    measure_name = current_figure$measure_name,
    location_name = LOCATION_NAME,
    age_names = PANEL_B_AGE_GROUPS,
    colors = PANEL_B_COLORS,
    shapes = PANEL_B_SHAPES
  )

  figure_tiff_path <- file.path(
    FIGURE_OUTPUT_DIR,
    current_figure$figure_file
  )

  save_two_panel_tiff(
    panel_a = figure_panel_a,
    panel_b = figure_panel_b,
    output_file = figure_tiff_path
  )

  cat(
    "Saved: ",
    normalizePath(figure_tiff_path, winslash = "/", mustWork = FALSE),
    "\n",
    sep = ""
  )
}

cat("\n=================================================================\n")
cat("Figure-only reproducibility analysis completed successfully.\n")
cat("Raw data folder name: ", FIGURE_RAW_DATA_FOLDER_NAME, "\n", sep = "")
cat("Input folder: ", normalizePath(FIGURE_INPUT_FOLDER, winslash = "/", mustWork = FALSE), "\n", sep = "")
cat("Output folder: ", normalizePath(FIGURE_OUTPUT_DIR, winslash = "/", mustWork = FALSE), "\n", sep = "")
cat("Joinpoint analyses completed and validated:\n")
cat("  Figure 1: YLD rate; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Additional file 1 Fig. S1: Incidence rate; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Additional file 1 Fig. S2: Death rate; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("Files generated:\n")
cat("  Figure 1.tif\n")
cat("  Additional file 1 Fig. S1.tif\n")
cat("  Additional file 1 Fig. S2.tif\n")
cat("=================================================================\n")
