# =============================================================================
# Reproducibility Script:
# Meningitis_Joinpoint_Reproducibility_R3.3.3
#
# Reproduced figures:
#   Figure 5.tif
#     Under-five YLD rate of meningitis by selected location/SDI group
#
#   Additional file 1 Fig. S3.tif
#     Under-five incidence rate of meningitis by selected location/SDI group
#
#   Additional file 1 Fig. S4.tif
#     Under-five death rate of meningitis by selected location/SDI group
#
#   Supplementary material Figure 7.tif
#     Trends in ASIR(a), ASMR(b), and ASYR(c) of meningitis among children
#     under 5 years of age in South Sudan from 1990 to 2021
#
# Reviewer-facing raw GBD data folders expected by this script:
#   Fig5_FigS3_FigS4_Meningitis_7SelectedLocations_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021
#   SuppFig7_Meningitis_SouthSudan_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021
#
# Reviewer-facing design:
#   1. Raw-data folder names explicitly state figure number, cause, location
#      scope, sex, age group, measures, metric and year range.
#   2. The script prints a raw-data download manifest before reading data.
#   3. The imported raw-data objects have descriptive names.
#   4. Each figure/panel section directly shows the easyGBDR::GBDage_aapc()
#      core analysis call. No wrapper hides the Joinpoint model step.
#
# R version:
#   Designed to be compatible with R 3.3.3
#
# Main analysis package:
#   easyGBDR
#
# Note:
#   The rates in these figures are based on the under-five age group and are
#   therefore under-five age-specific rates. The abbreviations ASIR, ASMR, and
#   ASYR are used according to the manuscript figure labels to denote
#   age-specific incidence rate, age-specific mortality rate, and age-specific
#   YLD rate, respectively. They should not be interpreted as age-standardized
#   rates unless the downloaded GBD age selection is "Age-standardized".
# =============================================================================


# -----------------------------------------------------------------------------
# 0. Clean workspace
# -----------------------------------------------------------------------------

rm(list = ls())
options(stringsAsFactors = FALSE)


# -----------------------------------------------------------------------------
# 1. Required packages
# -----------------------------------------------------------------------------

required_packages <- c(
  "easyGBDR",
  "ggsci",
  "ggplot2",
  "gridExtra"
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
suppressPackageStartupMessages(library(ggsci))
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(grid))

if ("GBD_edition" %in% ls("package:easyGBDR")) {
  GBD_edition(edition = 2021)
}


# -----------------------------------------------------------------------------
# 2. Project paths and reviewer-facing GBD download specification
# -----------------------------------------------------------------------------
#
# Recommended project structure:
#
# D:/Meningitis_Joinpoint_Reproducibility_R3.3.3/
# ├── 01_raw_GBD_data/
# │   ├── Fig5_FigS3_FigS4_Meningitis_7SelectedLocations_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021/
# │   │   └── IHME-GBD_2021_DATA-xxxxxxxx.csv
# │   └── SuppFig7_Meningitis_SouthSudan_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021/
# │       └── IHME-GBD_2021_DATA-xxxxxxxx.csv
# └── 02_analysis_output/
#
# -------------------------------------------------------------------------------
# Required GBD Results selections for Figure 5, Fig. S3, and Fig. S4:
# -------------------------------------------------------------------------------
#   GBD release:  GBD 2021
#   Cause:        Meningitis
#   Locations:    Low-middle SDI;
#                 South Asia;
#                 Central Sub-Saharan Africa;
#                 Low SDI;
#                 Oceania;
#                 Eastern Sub-Saharan Africa;
#                 Western Sub-Saharan Africa
#   Sex:          Both
#   Age:          <5 / 0 to 4 / Under 5 years, depending on the exported label
#   Metric:       Rate
#   Measures:     Incidence;
#                 Deaths;
#                 YLDs (Years Lived with Disability)
#   Years:        Every individual year from 1990 through 2021
#
# -------------------------------------------------------------------------------
# Required GBD Results selections for Supplementary material Figure 7:
# -------------------------------------------------------------------------------
#   GBD release:  GBD 2021
#   Cause:        Meningitis
#   Location:     South Sudan
#   Sex:          Both
#   Age:          <5 / 0 to 4 / Under 5 years, depending on the exported label
#   Metric:       Rate
#   Measures:     Incidence;
#                 Deaths;
#                 YLDs (Years Lived with Disability)
#   Years:        Every individual year from 1990 through 2021
#
# The folder names below are intentionally descriptive and reviewer-facing.
# They are not required to match IHME's default downloaded ZIP/CSV names.
# After downloading each GBD Results dataset, place the CSV file(s) into the
# corresponding folder name shown below.

PROJECT_DIR <- "D:/Meningitis_Joinpoint_Reproducibility_R3.3.3"

MAIN_RAW_DATA_FOLDER_NAME <- paste0(
  "Fig5_FigS3_FigS4_Meningitis_7SelectedLocations_BothSex_",
  "Under5_Incidence_Deaths_YLD_Rate_1990_2021"
)

SUPP7_RAW_DATA_FOLDER_NAME <- paste0(
  "SuppFig7_Meningitis_SouthSudan_BothSex_",
  "Under5_Incidence_Deaths_YLD_Rate_1990_2021"
)

MAIN_INPUT_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  MAIN_RAW_DATA_FOLDER_NAME
)

SUPP7_INPUT_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  SUPP7_RAW_DATA_FOLDER_NAME
)

OUTPUT_DIR <- file.path(
  PROJECT_DIR,
  "02_analysis_output"
)


# -----------------------------------------------------------------------------
# 3. Core analysis settings
# -----------------------------------------------------------------------------

CAUSE_NAME  <- "Meningitis"
SEX_NAME    <- "Both"
METRIC_NAME <- "Rate"

START_YEAR <- 1990
END_YEAR   <- 2021

MODEL_TYPE        <- "ln"
N_JOINPOINTS      <- 5
CALCULATE_CI      <- TRUE
CONSTANT_VARIANCE <- TRUE
ROUND_DIGITS      <- 5

WRITE_PDF <- FALSE
TIFF_DPI  <- 600


# -----------------------------------------------------------------------------
# 4. Location order and visual encoding
# -----------------------------------------------------------------------------

MAIN_LOCATION_ORDER <- c(
  "Low-middle SDI",
  "South Asia",
  "Central Sub-Saharan Africa",
  "Low SDI",
  "Oceania",
  "Eastern Sub-Saharan Africa",
  "Western Sub-Saharan Africa"
)

SUPP7_LOCATION_ORDER <- c("South Sudan")

LANCET_COLORS <- ggsci::pal_lancet("lanonc")(9)

MAIN_LOCATION_COLORS <- c(
  "Low-middle SDI" = LANCET_COLORS[1],
  "South Asia" = LANCET_COLORS[2],
  "Central Sub-Saharan Africa" = LANCET_COLORS[3],
  "Low SDI" = LANCET_COLORS[4],
  "Oceania" = LANCET_COLORS[5],
  "Eastern Sub-Saharan Africa" = LANCET_COLORS[6],
  "Western Sub-Saharan Africa" = LANCET_COLORS[7]
)

MAIN_LOCATION_SHAPES <- c(
  "Low-middle SDI" = 15,
  "South Asia" = 15,
  "Central Sub-Saharan Africa" = 16,
  "Low SDI" = 17,
  "Oceania" = 18,
  "Eastern Sub-Saharan Africa" = 16,
  "Western Sub-Saharan Africa" = 16
)

SUPP7_LOCATION_COLORS <- c(
  "South Sudan" = LANCET_COLORS[8]
)

SUPP7_LOCATION_SHAPES <- c(
  "South Sudan" = 16
)


# -----------------------------------------------------------------------------
# 5. Figure specifications
# -----------------------------------------------------------------------------

MAIN_FIGURE_SPECS <- list(
  list(
    figure_id = "Figure_5_Under5_YLD_rate",
    figure_file = "Figure 5.tif",
    figure_label = "Figure 5",
    measure_name = "YLDs (Years Lived with Disability)",
    outcome_label = "Under-five YLD rate",
    tiff_width_px = 4016,
    tiff_height_px = 3989
  ),
  list(
    figure_id = "Figure_S3_Under5_Incidence_rate",
    figure_file = "Additional file 1 Fig. S3.tif",
    figure_label = "Additional file 1 Fig. S3",
    measure_name = "Incidence",
    outcome_label = "Under-five incidence rate",
    tiff_width_px = 4017,
    tiff_height_px = 4016
  ),
  list(
    figure_id = "Figure_S4_Under5_Death_rate",
    figure_file = "Additional file 1 Fig. S4.tif",
    figure_label = "Additional file 1 Fig. S4",
    measure_name = "Deaths",
    outcome_label = "Under-five death rate",
    tiff_width_px = 4017,
    tiff_height_px = 3795
  )
)

SUPP7_FIGURE_SPECS <- list(
  list(
    panel_id = "a",
    figure_id = "Supplementary_Figure_7a_ASIR",
    measure_name = "Incidence",
    panel_label = "(a) ASIR",
    outcome_label = "Under-five incidence rate"
  ),
  list(
    panel_id = "b",
    figure_id = "Supplementary_Figure_7b_ASMR",
    measure_name = "Deaths",
    panel_label = "(b) ASMR",
    outcome_label = "Under-five mortality rate"
  ),
  list(
    panel_id = "c",
    figure_id = "Supplementary_Figure_7c_ASYR",
    measure_name = "YLDs (Years Lived with Disability)",
    panel_label = "(c) ASYR",
    outcome_label = "Under-five YLD rate"
  )
)

SUPP7_COMBINED_TIFF <- "Supplementary material Figure 7.tif"
SUPP7_COMBINED_PDF  <- "Supplementary material Figure 7.pdf"

SUPP7_PANEL_WIDTH_PX  <- 2400
SUPP7_PANEL_HEIGHT_PX <- 2400

SUPP7_TIFF_WIDTH_PX  <- 7200
SUPP7_TIFF_HEIGHT_PX <- 2400


# -----------------------------------------------------------------------------
# 6. Helper functions
# -----------------------------------------------------------------------------

create_folder <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  return(path)
}

print_raw_data_download_manifest <- function() {
  manifest <- data.frame(
    Analysis = c(
      "Figure 5, Additional file 1 Fig. S3, Additional file 1 Fig. S4",
      "Supplementary material Figure 7"
    ),
    Raw_data_folder = c(
      MAIN_RAW_DATA_FOLDER_NAME,
      SUPP7_RAW_DATA_FOLDER_NAME
    ),
    Locations = c(
      paste(MAIN_LOCATION_ORDER, collapse = "; "),
      paste(SUPP7_LOCATION_ORDER, collapse = "; ")
    ),
    Sex = c(SEX_NAME, SEX_NAME),
    Cause = c(CAUSE_NAME, CAUSE_NAME),
    Age_group = c(
      "<5 / 0 to 4 / Under 5 years",
      "<5 / 0 to 4 / Under 5 years"
    ),
    GBD_measure_metric = c(
      "YLDs Rate; Incidence Rate; Deaths Rate",
      "Incidence Rate; Deaths Rate; YLDs Rate"
    ),
    Years = c(
      "1990-2021, every individual year",
      "1990-2021, every individual year"
    ),
    Output_figures = c(
      "Figure 5.tif; Additional file 1 Fig. S3.tif; Additional file 1 Fig. S4.tif",
      "Supplementary material Figure 7.tif"
    ),
    stringsAsFactors = FALSE
  )

  cat("\n=================================================================\n")
  cat("Reviewer-facing raw GBD data download manifest\n")
  cat("Place downloaded IHME GBD 2021 CSV file(s) into these folders:\n")
  cat("Raw data root: ", normalizePath(file.path(PROJECT_DIR, "01_raw_GBD_data"), winslash = "/", mustWork = FALSE), "\n", sep = "")
  cat("=================================================================\n")
  print(manifest, row.names = FALSE)
  cat("=================================================================\n\n")

  invisible(manifest)
}

assert_columns <- function(data, required_columns) {
  missing_columns <- setdiff(required_columns, names(data))

  if (length(missing_columns) > 0) {
    stop(
      "The imported GBD data are missing required column(s): ",
      paste(missing_columns, collapse = ", "),
      "\nAvailable columns are: ",
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
      "\nAvailable values are:\n",
      paste(available_values, collapse = " | "),
      call. = FALSE
    )
  }
}

standardize_gbd_labels <- function(data) {
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

  # Harmonize common YLD label variants.
  data$measure[
    data$measure %in% c(
      "YLDs",
      "YLDs (Years lived with disability)",
      "YLDs (years lived with disability)"
    )
  ] <- "YLDs (Years Lived with Disability)"

  return(data)
}

resolve_under_five_label <- function(available_ages) {
  candidates <- c(
    "<5",
    "< 5",
    "0 to 4",
    "0-4",
    "0-4 years",
    "0 to 4 years",
    "Under 5",
    "Under 5 years",
    "Under 5 Years"
  )

  matched <- candidates[candidates %in% available_ages]

  if (length(matched) == 0) {
    stop(
      "Cannot identify the under-five age group.\n",
      "Expected one of: ",
      paste(candidates, collapse = " | "),
      "\nAvailable age values are:\n",
      paste(available_ages, collapse = " | "),
      call. = FALSE
    )
  }

  return(matched[1])
}

filter_figure_input_data <- function(
  data,
  measure_name,
  under_five_label,
  location_order,
  sex_name,
  cause_name,
  metric_name,
  start_year,
  end_year
) {
  include_row <- (
    as.character(data$location) %in% location_order &
      as.character(data$sex) == sex_name &
      as.character(data$cause) == cause_name &
      as.character(data$metric) == metric_name &
      as.character(data$measure) == measure_name &
      as.character(data$age) == under_five_label &
      as.numeric(data$year) >= start_year &
      as.numeric(data$year) <= end_year
  )

  selected_data <- data[include_row, , drop = FALSE]

  if (nrow(selected_data) == 0) {
    stop(
      "No data remained after filtering for measure: ",
      measure_name,
      call. = FALSE
    )
  }

  selected_data$location <- factor(
    as.character(selected_data$location),
    levels = location_order,
    ordered = TRUE
  )

  selected_data <- selected_data[
    order(
      selected_data$location,
      as.numeric(selected_data$year)
    ),
    ,
    drop = FALSE
  ]

  rownames(selected_data) <- NULL

  return(selected_data)
}

check_joinpoint_input <- function(
  data,
  location_order,
  analysis_label,
  start_year,
  end_year
) {
  if (!("val" %in% names(data))) {
    stop(
      "The GBD input data must contain a numeric column named 'val' for: ",
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

  observed_locations <- unique(as.character(data$location))
  absent_locations <- setdiff(location_order, observed_locations)

  if (length(absent_locations) > 0) {
    stop(
      "One or more required locations are absent after filtering for: ",
      analysis_label,
      "\nAbsent location(s): ",
      paste(absent_locations, collapse = ", "),
      call. = FALSE
    )
  }

  data$year <- as.numeric(as.character(data$year))
  expected_years <- seq(start_year, end_year)

  duplicate_identifier <- paste(
    as.character(data$location),
    data$year,
    sep = "___"
  )

  if (anyDuplicated(duplicate_identifier) > 0) {
    stop(
      "Duplicate location-year observations were found for: ",
      analysis_label,
      "\nCheck whether the GBD export contains more than one cause, metric, ",
      "sex, age, measure, or REI value after filtering.",
      call. = FALSE
    )
  }

  years_by_location <- split(
    data$year,
    as.character(data$location)
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
      "The following location(s) do not include every year from ",
      start_year,
      " through ",
      end_year,
      " for: ",
      analysis_label,
      "\n",
      paste(incomplete_locations, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

validate_joinpoint_result <- function(joinpoint_result, analysis_label) {
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

coerce_joinpoint_component_to_data_frame <- function(x, component_name, analysis_label) {
  if (is.null(x)) {
    return(
      data.frame(
        note = paste0(
          "Component result[['",
          component_name,
          "']] was NULL or was not returned for ",
          analysis_label,
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
          analysis_label,
          "."
        ),
        error_message = conditionMessage(e),
        stringsAsFactors = FALSE
      )
    }
  )

  return(out)
}

export_joinpoint_results <- function(
  joinpoint_result,
  figure_id,
  analysis_label,
  result_folder
) {
  result_components <- c("AAPC", "AAPC_Range", "APC", "data")

  for (component_name in result_components) {
    result_table <- coerce_joinpoint_component_to_data_frame(
      x = joinpoint_result[[component_name]],
      component_name = component_name,
      analysis_label = analysis_label
    )

    write.csv(
      result_table,
      file = file.path(
        result_folder,
        paste0(figure_id, "_", component_name, ".csv")
      ),
      row.names = FALSE
    )
  }
}

make_location_comparison_plot <- function(
  joinpoint_result,
  measure_name,
  under_five_label,
  location_order,
  location_colors,
  location_shapes,
  panel_label = NULL
) {
  p <- ggjoinpoint_compare(
    data = joinpoint_result,
    group_name = "location",
    measure_name = measure_name,
    cause_name = CAUSE_NAME,
    nudge_y = -0.5,
    sex_name = SEX_NAME,
    location_name = location_order,
    age_name = under_five_label,
    rei_name = NULL,
    facet_name = NULL,
    color_name = unname(location_colors[location_order]),
    shape_name = unname(location_shapes[location_order]),
    line_size = 1
  )

  if (!is.null(panel_label)) {
    p <- p +
      ggplot2::labs(title = panel_label) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(
          hjust = 0,
          face = "bold",
          size = 12
        )
      )
  }

  return(p)
}

save_plot_as_tiff <- function(
  plot_object,
  output_file,
  width_px,
  height_px,
  dpi
) {
  grDevices::tiff(
    filename = output_file,
    width = width_px,
    height = height_px,
    units = "px",
    res = dpi,
    compression = "lzw"
  )

  print(plot_object)
  grDevices::dev.off()
}

save_plot_as_pdf <- function(
  plot_object,
  output_file,
  width_px,
  height_px,
  dpi
) {
  grDevices::pdf(
    file = output_file,
    width = width_px / dpi,
    height = height_px / dpi
  )

  print(plot_object)
  grDevices::dev.off()
}

write_main_manifest <- function(output_folder, under_five_label) {
  manifest <- data.frame(
    item = c(
      "GBD release",
      "Raw data directory",
      "Cause",
      "Locations and plot order",
      "Sex",
      "Age",
      "Metric",
      "Measures",
      "Years",
      "Joinpoint model",
      "Core analysis calls",
      "Figure 5 output",
      "Additional file 1 Fig. S3 output",
      "Additional file 1 Fig. S4 output",
      "GBD query IDs"
    ),
    required_selection = c(
      "GBD 2021",
      MAIN_RAW_DATA_FOLDER_NAME,
      CAUSE_NAME,
      paste(MAIN_LOCATION_ORDER, collapse = "; "),
      SEX_NAME,
      under_five_label,
      METRIC_NAME,
      "YLDs (Years Lived with Disability); Incidence; Deaths",
      paste0(START_YEAR, "-", END_YEAR, " (every individual year)"),
      paste0(
        "model = ",
        MODEL_TYPE,
        "; maximum joinpoints = ",
        N_JOINPOINTS,
        "; constant_variance = ",
        CONSTANT_VARIANCE
      ),
      "Three direct GBDage_aapc() calls: Figure 5 YLDs; Fig. S3 Incidence; Fig. S4 Deaths",
      "Figure 5.tif: under-five YLD rate, seven locations",
      "Additional file 1 Fig. S3.tif: under-five incidence rate, seven locations",
      "Additional file 1 Fig. S4.tif: under-five death rate, seven locations",
      "Provided in the supplementary indicator table"
    ),
    stringsAsFactors = FALSE
  )

  write.csv(
    manifest,
    file = file.path(output_folder, "00_Main_Figures_GBD_download_manifest.csv"),
    row.names = FALSE
  )

  location_style <- data.frame(
    display_order = seq_along(MAIN_LOCATION_ORDER),
    location = MAIN_LOCATION_ORDER,
    color = unname(MAIN_LOCATION_COLORS[MAIN_LOCATION_ORDER]),
    shape = unname(MAIN_LOCATION_SHAPES[MAIN_LOCATION_ORDER]),
    stringsAsFactors = FALSE
  )

  write.csv(
    location_style,
    file = file.path(output_folder, "00_Main_location_order_and_style.csv"),
    row.names = FALSE
  )
}

write_supp7_manifest <- function(output_folder, under_five_label) {
  manifest <- data.frame(
    item = c(
      "GBD release",
      "Raw data directory",
      "Cause",
      "Location",
      "Sex",
      "Age",
      "Metric",
      "Measures",
      "Years",
      "Joinpoint model",
      "Core analysis calls",
      "Panel a",
      "Panel b",
      "Panel c",
      "GBD query IDs"
    ),
    required_selection = c(
      "GBD 2021",
      SUPP7_RAW_DATA_FOLDER_NAME,
      CAUSE_NAME,
      paste(SUPP7_LOCATION_ORDER, collapse = "; "),
      SEX_NAME,
      under_five_label,
      METRIC_NAME,
      "Incidence; Deaths; YLDs (Years Lived with Disability)",
      paste0(START_YEAR, "-", END_YEAR, " (every individual year)"),
      paste0(
        "model = ",
        MODEL_TYPE,
        "; maximum joinpoints = ",
        N_JOINPOINTS,
        "; constant_variance = ",
        CONSTANT_VARIANCE
      ),
      "Three direct GBDage_aapc() calls: panel a Incidence; panel b Deaths; panel c YLDs",
      "ASIR: under-five incidence rate in South Sudan",
      "ASMR: under-five mortality rate in South Sudan",
      "ASYR: under-five YLD rate in South Sudan",
      "Provided in the supplementary indicator table"
    ),
    stringsAsFactors = FALSE
  )

  write.csv(
    manifest,
    file = file.path(
      output_folder,
      "00_Supplementary_Figure_7_GBD_download_manifest.csv"
    ),
    row.names = FALSE
  )
}

write_readme <- function(output_folder) {
  readme_lines <- c(
    "Meningitis Joinpoint Reproducibility Package",
    "============================================",
    "",
    "This script reproduces:",
    "  Figure 5.tif",
    "    Under-five YLD rate by selected location/SDI group.",
    "",
    "  Additional file 1 Fig. S3.tif",
    "    Under-five incidence rate by selected location/SDI group.",
    "",
    "  Additional file 1 Fig. S4.tif",
    "    Under-five death rate by selected location/SDI group.",
    "",
    "  Supplementary material Figure 7.tif",
    "    Trends in ASIR(a), ASMR(b), and ASYR(c) of meningitis among children",
    "    under 5 years of age in South Sudan from 1990 to 2021.",
    "",
    "Reviewer-facing raw data folder names:",
    paste0("  ", MAIN_RAW_DATA_FOLDER_NAME),
    paste0("  ", SUPP7_RAW_DATA_FOLDER_NAME),
    "",
    "Required GBD 2021 Results selections for Figure 5, Fig. S3, and Fig. S4:",
    paste0("  Cause: ", CAUSE_NAME),
    paste0("  Locations: ", paste(MAIN_LOCATION_ORDER, collapse = "; ")),
    paste0("  Sex: ", SEX_NAME),
    "  Age: under-five, exported as <5 / 0 to 4 / Under 5 years depending on GBD label",
    paste0("  Metric: ", METRIC_NAME),
    "  Measures: Incidence; Deaths; YLDs (Years Lived with Disability)",
    paste0("  Years: every year from ", START_YEAR, " to ", END_YEAR),
    "",
    "Required GBD 2021 Results selections for Supplementary material Figure 7:",
    paste0("  Cause: ", CAUSE_NAME),
    "  Location: South Sudan",
    paste0("  Sex: ", SEX_NAME),
    "  Age: under-five, exported as <5 / 0 to 4 / Under 5 years depending on GBD label",
    paste0("  Metric: ", METRIC_NAME),
    "  Measures: Incidence; Deaths; YLDs (Years Lived with Disability)",
    paste0("  Years: every year from ", START_YEAR, " to ", END_YEAR),
    "",
    "Joinpoint transparency:",
    "  The script performs six direct easyGBDR::GBDage_aapc() calls:",
    "    1. Figure 5: YLDs (Years Lived with Disability)",
    "    2. Additional file 1 Fig. S3: Incidence",
    "    3. Additional file 1 Fig. S4: Deaths",
    "    4. Supplementary Figure 7 panel a: Incidence",
    "    5. Supplementary Figure 7 panel b: Deaths",
    "    6. Supplementary Figure 7 panel c: YLDs (Years Lived with Disability)",
    "",
    "The corresponding GBD cause ID, measure IDs, metric ID, age-group ID,",
    "location IDs, and other query IDs are provided in the supplementary",
    "indicator table.",
    "",
    "Output folders:",
    "  01_model_input_data: exact filtered GBD data used for each figure/panel",
    "  02_joinpoint_results: exported AAPC, APC, AAPC-range, and fitted data",
    "  03_figures: final TIFF files and optional PDF files",
    "  04_model_objects: saved R objects for model input data and Joinpoint results",
    "",
    "Terminology note:",
    "  These are under-five age-specific rates. They should not be described as",
    "  age-standardized rates unless the downloaded GBD age selection is",
    "  Age-standardized."
  )

  writeLines(
    readme_lines,
    con = file.path(output_folder, "00_README_reproducibility.txt")
  )
}


# -----------------------------------------------------------------------------
# 7. Create output folders
# -----------------------------------------------------------------------------

print_raw_data_download_manifest()

create_folder(OUTPUT_DIR)

MODEL_INPUT_DIR <- create_folder(
  file.path(OUTPUT_DIR, "01_model_input_data")
)

RESULT_TABLE_DIR <- create_folder(
  file.path(OUTPUT_DIR, "02_joinpoint_results")
)

FIGURE_DIR <- create_folder(
  file.path(OUTPUT_DIR, "03_figures")
)

MODEL_OBJECT_DIR <- create_folder(
  file.path(OUTPUT_DIR, "04_model_objects")
)


# -----------------------------------------------------------------------------
# 8. Read main raw GBD data for Figure 5, Fig. S3, and Fig. S4
# -----------------------------------------------------------------------------

if (!dir.exists(MAIN_INPUT_FOLDER)) {
  stop(
    "MAIN_INPUT_FOLDER does not exist:\n",
    MAIN_INPUT_FOLDER,
    "\n\nCreate this reviewer-facing folder, place the downloaded IHME GBD CSV file(s) inside ",
    "it, then run the script again.",
    call. = FALSE
  )
}

fig5_figs3_figs4_7locations_under5_raw_data <- GBDread(
  folder = TRUE,
  foldername = MAIN_INPUT_FOLDER
)

fig5_figs3_figs4_7locations_under5_raw_data <- standardize_gbd_labels(
  fig5_figs3_figs4_7locations_under5_raw_data
)

main_available_labels <- list(
  location = unique(fig5_figs3_figs4_7locations_under5_raw_data$location),
  sex = unique(fig5_figs3_figs4_7locations_under5_raw_data$sex),
  age = unique(fig5_figs3_figs4_7locations_under5_raw_data$age),
  cause = unique(fig5_figs3_figs4_7locations_under5_raw_data$cause),
  measure = unique(fig5_figs3_figs4_7locations_under5_raw_data$measure),
  metric = unique(fig5_figs3_figs4_7locations_under5_raw_data$metric)
)

saveRDS(
  main_available_labels,
  file = file.path(OUTPUT_DIR, "00_available_GBD_labels_main_data.rds")
)

cat("\nAvailable age labels in the main downloaded data:\n")
print(main_available_labels$age)

assert_values_exist(
  fig5_figs3_figs4_7locations_under5_raw_data,
  "location",
  MAIN_LOCATION_ORDER
)

assert_values_exist(
  fig5_figs3_figs4_7locations_under5_raw_data,
  "sex",
  SEX_NAME
)

assert_values_exist(
  fig5_figs3_figs4_7locations_under5_raw_data,
  "cause",
  CAUSE_NAME
)

assert_values_exist(
  fig5_figs3_figs4_7locations_under5_raw_data,
  "metric",
  METRIC_NAME
)

main_requested_measures <- vapply(
  MAIN_FIGURE_SPECS,
  function(specification) specification$measure_name,
  character(1)
)

assert_values_exist(
  fig5_figs3_figs4_7locations_under5_raw_data,
  "measure",
  main_requested_measures
)

MAIN_UNDER_FIVE_AGE_LABEL <- resolve_under_five_label(
  available_ages = main_available_labels$age
)

write_main_manifest(
  output_folder = OUTPUT_DIR,
  under_five_label = MAIN_UNDER_FIVE_AGE_LABEL
)


# -----------------------------------------------------------------------------
# 9. Reproduce Figure 5, Additional file 1 Fig. S3, and Additional file 1 Fig. S4
# -----------------------------------------------------------------------------

main_input_data_by_figure <- list()
main_joinpoint_results_by_figure <- list()

for (figure_index in seq_along(MAIN_FIGURE_SPECS)) {
  current_figure <- MAIN_FIGURE_SPECS[[figure_index]]

  cat("\n=================================================================\n")
  cat("Reproducing ", current_figure$figure_label, "\n", sep = "")
  cat("Outcome: ", current_figure$outcome_label, "\n", sep = "")
  cat("Measure: ", current_figure$measure_name, "\n", sep = "")
  cat("=================================================================\n")

  figure_input_data <- filter_figure_input_data(
    data = fig5_figs3_figs4_7locations_under5_raw_data,
    measure_name = current_figure$measure_name,
    under_five_label = MAIN_UNDER_FIVE_AGE_LABEL,
    location_order = MAIN_LOCATION_ORDER,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    metric_name = METRIC_NAME,
    start_year = START_YEAR,
    end_year = END_YEAR
  )

  main_input_data_by_figure[[current_figure$figure_id]] <- figure_input_data

  write.csv(
    figure_input_data,
    file = file.path(
      MODEL_INPUT_DIR,
      paste0(current_figure$figure_id, "_model_input_data.csv")
    ),
    row.names = FALSE
  )

  current_joinpoint_label <- paste(
    current_figure$figure_label,
    current_figure$outcome_label,
    sep = " - "
  )

  check_joinpoint_input(
    data = figure_input_data,
    location_order = MAIN_LOCATION_ORDER,
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
  # Core Joinpoint analysis step for Figure 5 / Fig. S3 / Fig. S4
  # ---------------------------------------------------------------------------
  # This explicit GBDage_aapc() call runs once for each main figure:
  #   Figure 5: YLDs (Years Lived with Disability)
  #   Additional file 1 Fig. S3: Incidence
  #   Additional file 1 Fig. S4: Deaths
  # ---------------------------------------------------------------------------

  result_main_figure_joinpoint_current <- GBDage_aapc(
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

  validate_joinpoint_result(
    joinpoint_result = result_main_figure_joinpoint_current,
    analysis_label = current_joinpoint_label
  )

  figure_joinpoint_result <- result_main_figure_joinpoint_current

  main_joinpoint_results_by_figure[[current_figure$figure_id]] <-
    figure_joinpoint_result

  export_joinpoint_results(
    joinpoint_result = figure_joinpoint_result,
    figure_id = current_figure$figure_id,
    analysis_label = current_joinpoint_label,
    result_folder = RESULT_TABLE_DIR
  )

  location_comparison_plot <- make_location_comparison_plot(
    joinpoint_result = figure_joinpoint_result,
    measure_name = current_figure$measure_name,
    under_five_label = MAIN_UNDER_FIVE_AGE_LABEL,
    location_order = MAIN_LOCATION_ORDER,
    location_colors = MAIN_LOCATION_COLORS,
    location_shapes = MAIN_LOCATION_SHAPES,
    panel_label = NULL
  )

  figure_tiff_path <- file.path(
    FIGURE_DIR,
    current_figure$figure_file
  )

  save_plot_as_tiff(
    plot_object = location_comparison_plot,
    output_file = figure_tiff_path,
    width_px = current_figure$tiff_width_px,
    height_px = current_figure$tiff_height_px,
    dpi = TIFF_DPI
  )

  if (WRITE_PDF) {
    figure_pdf_path <- file.path(
      FIGURE_DIR,
      paste0(
        tools::file_path_sans_ext(current_figure$figure_file),
        ".pdf"
      )
    )

    save_plot_as_pdf(
      plot_object = location_comparison_plot,
      output_file = figure_pdf_path,
      width_px = current_figure$tiff_width_px,
      height_px = current_figure$tiff_height_px,
      dpi = TIFF_DPI
    )
  }

  cat(
    "Saved final figure: ",
    normalizePath(figure_tiff_path, winslash = "/", mustWork = FALSE),
    "\n",
    sep = ""
  )
}

saveRDS(
  main_input_data_by_figure,
  file = file.path(
    MODEL_OBJECT_DIR,
    "Main_figures_model_input_data_by_figure.rds"
  )
)

saveRDS(
  main_joinpoint_results_by_figure,
  file = file.path(
    MODEL_OBJECT_DIR,
    "Main_figures_Joinpoint_results_by_figure.rds"
  )
)


# -----------------------------------------------------------------------------
# 10. Read Supplementary Figure 7 raw GBD data
# -----------------------------------------------------------------------------

if (!dir.exists(SUPP7_INPUT_FOLDER)) {
  stop(
    "SUPP7_INPUT_FOLDER does not exist:\n",
    SUPP7_INPUT_FOLDER,
    "\n\nCreate this reviewer-facing folder, place the South Sudan downloaded IHME GBD CSV ",
    "file(s) inside it, then run the script again.",
    call. = FALSE
  )
}

suppfig7_south_sudan_under5_raw_data <- GBDread(
  folder = TRUE,
  foldername = SUPP7_INPUT_FOLDER
)

suppfig7_south_sudan_under5_raw_data <- standardize_gbd_labels(
  suppfig7_south_sudan_under5_raw_data
)

supp7_available_labels <- list(
  location = unique(suppfig7_south_sudan_under5_raw_data$location),
  sex = unique(suppfig7_south_sudan_under5_raw_data$sex),
  age = unique(suppfig7_south_sudan_under5_raw_data$age),
  cause = unique(suppfig7_south_sudan_under5_raw_data$cause),
  measure = unique(suppfig7_south_sudan_under5_raw_data$measure),
  metric = unique(suppfig7_south_sudan_under5_raw_data$metric)
)

saveRDS(
  supp7_available_labels,
  file = file.path(OUTPUT_DIR, "00_available_GBD_labels_supp7_data.rds")
)

cat("\nAvailable age labels in the Supplementary Figure 7 downloaded data:\n")
print(supp7_available_labels$age)

assert_values_exist(
  suppfig7_south_sudan_under5_raw_data,
  "location",
  SUPP7_LOCATION_ORDER
)

assert_values_exist(
  suppfig7_south_sudan_under5_raw_data,
  "sex",
  SEX_NAME
)

assert_values_exist(
  suppfig7_south_sudan_under5_raw_data,
  "cause",
  CAUSE_NAME
)

assert_values_exist(
  suppfig7_south_sudan_under5_raw_data,
  "metric",
  METRIC_NAME
)

supp7_requested_measures <- vapply(
  SUPP7_FIGURE_SPECS,
  function(specification) specification$measure_name,
  character(1)
)

assert_values_exist(
  suppfig7_south_sudan_under5_raw_data,
  "measure",
  supp7_requested_measures
)

SUPP7_UNDER_FIVE_AGE_LABEL <- resolve_under_five_label(
  available_ages = supp7_available_labels$age
)

write_supp7_manifest(
  output_folder = OUTPUT_DIR,
  under_five_label = SUPP7_UNDER_FIVE_AGE_LABEL
)


# -----------------------------------------------------------------------------
# 11. Reproduce Supplementary material Figure 7
# -----------------------------------------------------------------------------

supp7_input_data_by_panel <- list()
supp7_joinpoint_results_by_panel <- list()
supp7_panel_plots <- list()

for (panel_index in seq_along(SUPP7_FIGURE_SPECS)) {
  current_panel <- SUPP7_FIGURE_SPECS[[panel_index]]

  cat("\n=================================================================\n")
  cat(
    "Reproducing Supplementary material Figure 7",
    current_panel$panel_id,
    "\n",
    sep = ""
  )
  cat("Outcome: ", current_panel$outcome_label, "\n", sep = "")
  cat("Measure: ", current_panel$measure_name, "\n", sep = "")
  cat("=================================================================\n")

  supp7_panel_input_data <- filter_figure_input_data(
    data = suppfig7_south_sudan_under5_raw_data,
    measure_name = current_panel$measure_name,
    under_five_label = SUPP7_UNDER_FIVE_AGE_LABEL,
    location_order = SUPP7_LOCATION_ORDER,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    metric_name = METRIC_NAME,
    start_year = START_YEAR,
    end_year = END_YEAR
  )

  supp7_input_data_by_panel[[current_panel$figure_id]] <-
    supp7_panel_input_data

  write.csv(
    supp7_panel_input_data,
    file = file.path(
      MODEL_INPUT_DIR,
      paste0(current_panel$figure_id, "_model_input_data.csv")
    ),
    row.names = FALSE
  )

  current_joinpoint_label <- paste(
    "Supplementary material Figure 7",
    current_panel$panel_id,
    current_panel$outcome_label,
    sep = " - "
  )

  check_joinpoint_input(
    data = supp7_panel_input_data,
    location_order = SUPP7_LOCATION_ORDER,
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
  # Core Joinpoint analysis step for Supplementary material Figure 7
  # ---------------------------------------------------------------------------
  # This explicit GBDage_aapc() call runs once for each panel:
  #   Panel a: Incidence / ASIR
  #   Panel b: Deaths / ASMR
  #   Panel c: YLDs / ASYR
  # ---------------------------------------------------------------------------

  result_supp7_panel_joinpoint_current <- GBDage_aapc(
    data = supp7_panel_input_data,
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
    joinpoint_result = result_supp7_panel_joinpoint_current,
    analysis_label = current_joinpoint_label
  )

  supp7_joinpoint_result <- result_supp7_panel_joinpoint_current

  supp7_joinpoint_results_by_panel[[current_panel$figure_id]] <-
    supp7_joinpoint_result

  export_joinpoint_results(
    joinpoint_result = supp7_joinpoint_result,
    figure_id = current_panel$figure_id,
    analysis_label = current_joinpoint_label,
    result_folder = RESULT_TABLE_DIR
  )

  supp7_panel_plot <- make_location_comparison_plot(
    joinpoint_result = supp7_joinpoint_result,
    measure_name = current_panel$measure_name,
    under_five_label = SUPP7_UNDER_FIVE_AGE_LABEL,
    location_order = SUPP7_LOCATION_ORDER,
    location_colors = SUPP7_LOCATION_COLORS,
    location_shapes = SUPP7_LOCATION_SHAPES,
    panel_label = current_panel$panel_label
  )

  supp7_panel_plots[[panel_index]] <- supp7_panel_plot

  panel_tiff_path <- file.path(
    FIGURE_DIR,
    paste0(current_panel$figure_id, ".tif")
  )

  save_plot_as_tiff(
    plot_object = supp7_panel_plot,
    output_file = panel_tiff_path,
    width_px = SUPP7_PANEL_WIDTH_PX,
    height_px = SUPP7_PANEL_HEIGHT_PX,
    dpi = TIFF_DPI
  )

  if (WRITE_PDF) {
    panel_pdf_path <- file.path(
      FIGURE_DIR,
      paste0(current_panel$figure_id, ".pdf")
    )

    save_plot_as_pdf(
      plot_object = supp7_panel_plot,
      output_file = panel_pdf_path,
      width_px = SUPP7_PANEL_WIDTH_PX,
      height_px = SUPP7_PANEL_HEIGHT_PX,
      dpi = TIFF_DPI
    )
  }
}


# -----------------------------------------------------------------------------
# 12. Save combined three-panel Supplementary material Figure 7
# -----------------------------------------------------------------------------

supp7_combined_grob <- gridExtra::arrangeGrob(
  grobs = supp7_panel_plots,
  ncol = 3
)

supp7_combined_tiff_path <- file.path(
  FIGURE_DIR,
  SUPP7_COMBINED_TIFF
)

grDevices::tiff(
  filename = supp7_combined_tiff_path,
  width = SUPP7_TIFF_WIDTH_PX,
  height = SUPP7_TIFF_HEIGHT_PX,
  units = "px",
  res = TIFF_DPI,
  compression = "lzw"
)

grid::grid.draw(supp7_combined_grob)
grDevices::dev.off()

if (WRITE_PDF) {
  supp7_combined_pdf_path <- file.path(
    FIGURE_DIR,
    SUPP7_COMBINED_PDF
  )

  grDevices::pdf(
    file = supp7_combined_pdf_path,
    width = SUPP7_TIFF_WIDTH_PX / TIFF_DPI,
    height = SUPP7_TIFF_HEIGHT_PX / TIFF_DPI
  )

  grid::grid.draw(supp7_combined_grob)
  grDevices::dev.off()
}

saveRDS(
  supp7_input_data_by_panel,
  file = file.path(
    MODEL_OBJECT_DIR,
    "Supplementary_Figure_7_model_input_data_by_panel.rds"
  )
)

saveRDS(
  supp7_joinpoint_results_by_panel,
  file = file.path(
    MODEL_OBJECT_DIR,
    "Supplementary_Figure_7_Joinpoint_results_by_panel.rds"
  )
)


# -----------------------------------------------------------------------------
# 13. README and session information
# -----------------------------------------------------------------------------

write_readme(OUTPUT_DIR)

capture.output(
  sessionInfo(),
  file = file.path(OUTPUT_DIR, "00_R_sessionInfo.txt")
)


# -----------------------------------------------------------------------------
# 14. Completion message
# -----------------------------------------------------------------------------

cat("\n=================================================================\n")
cat("All requested figures were generated successfully.\n")
cat("Raw data folders used:\n")
cat("  Main figures raw data folder name: ", MAIN_RAW_DATA_FOLDER_NAME, "\n", sep = "")
cat("  Supplementary Figure 7 raw data folder name: ", SUPP7_RAW_DATA_FOLDER_NAME, "\n", sep = "")
cat("\nFigures reproduced:\n")
cat("  Figure 5.tif\n")
cat("  Additional file 1 Fig. S3.tif\n")
cat("  Additional file 1 Fig. S4.tif\n")
cat("  Supplementary material Figure 7.tif\n")
cat("\n")
cat("Joinpoint analyses completed and validated:\n")
cat("  Figure 5: YLD rate; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Additional file 1 Fig. S3: Incidence rate; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Additional file 1 Fig. S4: Death rate; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Supplementary Figure 7a: ASIR / Incidence; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Supplementary Figure 7b: ASMR / Deaths; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("  Supplementary Figure 7c: ASYR / YLDs; direct GBDage_aapc() call with AAPCrange = NULL\n")
cat("\n")
cat(
  "Main raw data folder: ",
  normalizePath(MAIN_INPUT_FOLDER, winslash = "/", mustWork = FALSE),
  "\n",
  sep = ""
)
cat(
  "Supplementary Figure 7 raw data folder: ",
  normalizePath(SUPP7_INPUT_FOLDER, winslash = "/", mustWork = FALSE),
  "\n",
  sep = ""
)
cat(
  "Output folder: ",
  normalizePath(OUTPUT_DIR, winslash = "/", mustWork = FALSE),
  "\n",
  sep = ""
)
cat(
  "Model input data: ",
  normalizePath(MODEL_INPUT_DIR, winslash = "/", mustWork = FALSE),
  "\n",
  sep = ""
)
cat(
  "Joinpoint result tables: ",
  normalizePath(RESULT_TABLE_DIR, winslash = "/", mustWork = FALSE),
  "\n",
  sep = ""
)
cat(
  "Final figures: ",
  normalizePath(FIGURE_DIR, winslash = "/", mustWork = FALSE),
  "\n",
  sep = ""
)
cat("=================================================================\n")

# =============================================================================
# End of script
# =============================================================================
