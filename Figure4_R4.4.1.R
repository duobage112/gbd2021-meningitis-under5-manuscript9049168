# =============================================================================
# Figure 4 Reproducibility Script
#
# Health inequality regression and concentration curves for under-five
# incidence rate (A, B), mortality rate (C, D), and YLD rate (E, F)
# of meningitis, 1990 and 2021.
#
# R version: 4.4.1 compatible
#
# Final output:
#   Figure 4.tif
#
# METHOD CLARIFICATION
# --------------------
# easyGBDR inequality tools read estimates from rows coded as:
#   age = "Age-standardized"
#   metric = "Rate"
#
# This analysis concerns a single age band: children under 5 years.
# Therefore, the directly downloaded under-five Rate is copied unchanged
# into the field age = "Age-standardized" only for tool compatibility.
# No cross-age aggregation, weighting, or age standardisation is applied.
# The original under-five age label and original value are preserved in
# source_age and source_rate_value for reviewer verification.
#
# Required downloaded GBD data:
#   GBD release: GBD 2021
#   Cause:       Meningitis
#   Locations:   204 countries and territories
#   Sex:         Both
#   Age:         <5 / 0 to 4 / Under 5 years
#   Metric:      Rate
#   Measures:    Incidence; Deaths; YLDs (Years Lived with Disability)
#   Years:       1990 and 2021
#
# Reviewer-facing raw-data folder:
#   Figure4_Meningitis_204Countries_BothSex_Under5_Incidence_Deaths_YLD_Rate_1990_2021
# =============================================================================

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. Required packages
# -----------------------------------------------------------------------------

required_packages <- c(
  "easyGBDR",
  "ggplot2",
  "dplyr",
  "splines",
  "MASS",
  "RStata"
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
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(splines))
suppressPackageStartupMessages(library(MASS))
suppressPackageStartupMessages(library(RStata))
suppressPackageStartupMessages(library(grid))

if ("GBD_edition" %in% getNamespaceExports("easyGBDR")) {
  GBD_edition(edition = 2021)
}

# -----------------------------------------------------------------------------
# 2. Optional Stata configuration
# -----------------------------------------------------------------------------

CONFIGURE_STATA <- FALSE
STATA_PATH <- "D:/Stata17"
STATA_VERSION <- 17
STATA_TYPE <- "MP"

if (CONFIGURE_STATA) {
  if ("config_stata" %in% getNamespaceExports("RStata")) {
    RStata::config_stata(
      path = STATA_PATH,
      version = STATA_VERSION,
      stata_type = STATA_TYPE
    )
  }
}

# -----------------------------------------------------------------------------
# 3. Project folders and reviewer-facing raw-data name
# -----------------------------------------------------------------------------

PROJECT_DIR <- "D:/Figure4_Meningitis_Under5_Inequality_Reproducibility"

RAW_GBD_FOLDER_NAME <- paste0(
  "Figure4_Meningitis_204Countries_BothSex_Under5_",
  "Incidence_Deaths_YLD_Rate_1990_2021"
)

RAW_GBD_FOLDER <- file.path(
  PROJECT_DIR,
  "01_raw_GBD_data",
  RAW_GBD_FOLDER_NAME
)

OUTPUT_DIR <- file.path(
  PROJECT_DIR,
  "02_Figure4_outputs"
)

# -----------------------------------------------------------------------------
# 4. Analysis settings
# -----------------------------------------------------------------------------

CAUSE_NAME <- "Meningitis"
SEX_NAME <- "Both"

SOURCE_METRIC_NAME <- "Rate"
TOOL_COMPATIBLE_AGE_NAME <- "Age-standardized"
TOOL_COMPATIBLE_METRIC_NAME <- "Rate"

FIGURE4_YEARS <- c(1990, 2021)

UNDER_FIVE_AGE_CANDIDATES <- c(
  "<5", "< 5", "<5 years",
  "0 to 4", "0 to 4 years",
  "0-4", "0-4 years",
  "Under 5", "Under 5 years", "Under 5 Years"
)

SLOPE_MODEL <- "rlm"
COLOR_BY_YEAR <- c("#6699FF", "#990000")
POPULATION_COUNT <- 1e+06
CONCENTRATION_LINE_TYPE <- c("geom_smooth")

TIFF_WIDTH_PX <- 3891
TIFF_HEIGHT_PX <- 4434
TIFF_DPI <- 600

WRITE_PANEL_FILES <- TRUE
WRITE_FINAL_PDF <- FALSE

FIGURE4_MEASURE_SPECS <- list(
  list(
    measure_name = "Incidence",
    metric_short = "ASIR",
    slope_panel_id = "Figure4A_ASIR_slope_index",
    concentration_panel_id = "Figure4B_ASIR_concentration_curve",
    slope_panel_label = "A",
    concentration_panel_label = "B",
    slope_y_axis_title = "Under-five incidence rate (per 100,000)",
    concentration_y_axis_title = "Cumulative fraction of incidence",
    raw_input_file = "Figure4A_B_ASIR_rawUnder5Rate_204Countries_1990_2021.csv",
    model_input_file = "Figure4A_B_ASIR_toolCompatibleAgeField_Under5Rate_204Countries_1990_2021.csv",
    slope_panel_pdf = "Figure4A_ASIR_slopeIndex_panel.pdf",
    concentration_panel_pdf = "Figure4B_ASIR_concentrationCurve_panel.pdf"
  ),
  list(
    measure_name = "Deaths",
    metric_short = "ASMR",
    slope_panel_id = "Figure4C_ASMR_slope_index",
    concentration_panel_id = "Figure4D_ASMR_concentration_curve",
    slope_panel_label = "C",
    concentration_panel_label = "D",
    slope_y_axis_title = "Under-five mortality rate (per 100,000)",
    concentration_y_axis_title = "Cumulative fraction of mortality",
    raw_input_file = "Figure4C_D_ASMR_rawUnder5Rate_204Countries_1990_2021.csv",
    model_input_file = "Figure4C_D_ASMR_toolCompatibleAgeField_Under5Rate_204Countries_1990_2021.csv",
    slope_panel_pdf = "Figure4C_ASMR_slopeIndex_panel.pdf",
    concentration_panel_pdf = "Figure4D_ASMR_concentrationCurve_panel.pdf"
  ),
  list(
    measure_name = "YLDs (Years Lived with Disability)",
    metric_short = "ASYR",
    slope_panel_id = "Figure4E_ASYR_slope_index",
    concentration_panel_id = "Figure4F_ASYR_concentration_curve",
    slope_panel_label = "E",
    concentration_panel_label = "F",
    slope_y_axis_title = "Under-five YLD rate (per 100,000)",
    concentration_y_axis_title = "Cumulative fraction of YLDs",
    raw_input_file = "Figure4E_F_ASYR_rawUnder5Rate_204Countries_1990_2021.csv",
    model_input_file = "Figure4E_F_ASYR_toolCompatibleAgeField_Under5Rate_204Countries_1990_2021.csv",
    slope_panel_pdf = "Figure4E_ASYR_slopeIndex_panel.pdf",
    concentration_panel_pdf = "Figure4F_ASYR_concentrationCurve_panel.pdf"
  )
)

# -----------------------------------------------------------------------------
# 5. Helper functions
# -----------------------------------------------------------------------------

create_folder <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  return(path)
}

print_raw_data_download_manifest <- function() {
  manifest <- data.frame(
    Analysis = "Figure 4 cross-country health inequality analysis",
    Raw_data_folder = RAW_GBD_FOLDER_NAME,
    GBD_release = "GBD 2021",
    Cause = CAUSE_NAME,
    Locations = "204 countries and territories",
    Sex = SEX_NAME,
    Age = "<5 / 0 to 4 / Under 5 years",
    Measures = "Incidence; Deaths; YLDs (Years Lived with Disability)",
    Metric = SOURCE_METRIC_NAME,
    Years = "1990 and 2021",
    Cross_age_standardisation = "Not applied",
    Tool_compatibility_rule = paste(
      "Direct under-five Rate copied unchanged into age =",
      TOOL_COMPATIBLE_AGE_NAME
    ),
    stringsAsFactors = FALSE
  )

  cat("\n============================================================\n")
  cat("Reviewer-facing Figure 4 raw-data download manifest\n")
  cat("Raw data folder:\n")
  cat(
    "  ",
    normalizePath(RAW_GBD_FOLDER, winslash = "/", mustWork = FALSE),
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

write_if_dataframe <- function(object, output_file) {
  if (is.data.frame(object)) {
    write.csv(object, file = output_file, row.names = FALSE)
  }
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

resolve_under_five_label <- function(available_ages) {
  matched <- UNDER_FIVE_AGE_CANDIDATES[
    UNDER_FIVE_AGE_CANDIDATES %in% available_ages
  ]

  if (length(matched) == 0) {
    stop(
      "Cannot identify the under-five age group.\n",
      "Expected one of: ",
      paste(UNDER_FIVE_AGE_CANDIDATES, collapse = " | "),
      "\nAvailable age values are:\n",
      paste(available_ages, collapse = " | "),
      call. = FALSE
    )
  }

  return(matched[1])
}

read_raw_gbd_data <- function(raw_folder) {
  if (!dir.exists(raw_folder)) {
    stop(
      "RAW_GBD_FOLDER does not exist:\n",
      raw_folder,
      "\n\nCreate this reviewer-facing folder and place the downloaded IHME GBD ",
      "2021 CSV file(s) inside it.",
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
  country_locations,
  under_five_label
) {
  required_measures <- vapply(
    FIGURE4_MEASURE_SPECS,
    function(x) x$measure_name,
    character(1)
  )

  assert_values_exist(raw_data, "location", country_locations)
  assert_values_exist(raw_data, "sex", SEX_NAME)
  assert_values_exist(raw_data, "age", under_five_label)
  assert_values_exist(raw_data, "cause", CAUSE_NAME)
  assert_values_exist(raw_data, "metric", SOURCE_METRIC_NAME)
  assert_values_exist(raw_data, "measure", required_measures)

  selected_data <- raw_data[
    as.character(raw_data$location) %in% country_locations &
      as.character(raw_data$sex) == SEX_NAME &
      as.character(raw_data$age) == under_five_label &
      as.character(raw_data$cause) == CAUSE_NAME &
      as.character(raw_data$metric) == SOURCE_METRIC_NAME &
      as.character(raw_data$measure) %in% required_measures &
      as.numeric(raw_data$year) %in% FIGURE4_YEARS,
    ,
    drop = FALSE
  ]

  if (nrow(selected_data) == 0) {
    stop(
      "No under-five Rate rows remain after applying Figure 4 filters.",
      call. = FALSE
    )
  }

  observed_country_count <- length(
    unique(as.character(selected_data$location))
  )

  expected_country_count <- length(country_locations)

  if (observed_country_count != expected_country_count) {
    stop(
      "The selected data contain ",
      observed_country_count,
      " countries/territories, but the reference vector contains ",
      expected_country_count,
      ". Please check location names and the downloaded location selection.",
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
  return(selected_data)
}

check_direct_under5_rate_data <- function(
  under5_rate_data,
  country_locations
) {
  required_measures <- vapply(
    FIGURE4_MEASURE_SPECS,
    function(x) x$measure_name,
    character(1)
  )

  if (any(is.na(under5_rate_data$val)) ||
      any(!is.finite(under5_rate_data$val))) {
    stop(
      "The direct under-five Rate data contain missing or non-finite values.",
      call. = FALSE
    )
  }

  expected_years <- sort(FIGURE4_YEARS)

  for (current_measure in required_measures) {
    current_data <- under5_rate_data[
      as.character(under5_rate_data$measure) == current_measure,
      ,
      drop = FALSE
    ]

    missing_locations <- setdiff(
      country_locations,
      unique(as.character(current_data$location))
    )

    if (length(missing_locations) > 0) {
      stop(
        "The following countries/territories are missing for ",
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
        "Duplicate country-year rows were found for ",
        current_measure,
        ". Confirm that the raw file contains one under-five Rate row per ",
        "country-year.",
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
          !identical(sort(unique(years)), expected_years)
        },
        logical(1)
      )
    ]

    if (length(incomplete_locations) > 0) {
      stop(
        "The following countries/territories do not include both 1990 and ",
        "2021 for ", current_measure, ":\n",
        paste(incomplete_locations, collapse = "\n"),
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

create_tool_compatible_inequality_data <- function(
  under5_rate_data,
  source_under_five_label
) {
  model_data <- under5_rate_data

  model_data$source_age <- as.character(model_data$age)
  model_data$source_metric <- as.character(model_data$metric)
  model_data$source_rate_value <- as.numeric(model_data$val)

  # Compatibility-only recoding. The rate values are not recalculated.
  model_data$age <- TOOL_COMPATIBLE_AGE_NAME
  model_data$metric <- TOOL_COMPATIBLE_METRIC_NAME

  model_data$analysis_age_band <- "Children under 5 years"
  model_data$cross_age_standardisation_applied <- "No"
  model_data$tool_compatibility_note <- paste0(
    "Original under-five Rate (source age label: ",
    source_under_five_label,
    ") copied unchanged into age='",
    TOOL_COMPATIBLE_AGE_NAME,
    "' for easyGBDR inequality-tool compatibility."
  )

  if (!isTRUE(all.equal(
    as.numeric(model_data$val),
    as.numeric(model_data$source_rate_value),
    check.attributes = FALSE
  ))) {
    stop(
      "The Rate values changed while creating the tool-compatible dataset.",
      call. = FALSE
    )
  }

  model_data <- model_data[
    order(
      model_data$measure,
      model_data$location,
      model_data$year
    ),
    ,
    drop = FALSE
  ]

  rownames(model_data) <- NULL
  return(model_data)
}

check_measure_model_data <- function(
  model_data,
  measure_name,
  country_locations
) {
  current_data <- model_data[
    as.character(model_data$measure) == measure_name &
      as.character(model_data$age) == TOOL_COMPATIBLE_AGE_NAME &
      as.character(model_data$metric) == TOOL_COMPATIBLE_METRIC_NAME,
    ,
    drop = FALSE
  ]

  if (nrow(current_data) == 0) {
    stop(
      "No tool-compatible under-five Rate rows found for measure: ",
      measure_name,
      call. = FALSE
    )
  }

  if (!isTRUE(all.equal(
    as.numeric(current_data$val),
    as.numeric(current_data$source_rate_value),
    check.attributes = FALSE
  ))) {
    stop(
      "The model values differ from the original under-five Rate for ",
      measure_name,
      call. = FALSE
    )
  }

  expected_years <- sort(FIGURE4_YEARS)

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
      "The following countries/territories do not include both 1990 and 2021 ",
      "for ", measure_name, ":\n",
      paste(incomplete_locations, collapse = "\n"),
      call. = FALSE
    )
  }

  missing_locations <- setdiff(
    country_locations,
    unique(as.character(current_data$location))
  )

  if (length(missing_locations) > 0) {
    stop(
      "The following countries/territories are missing for ",
      measure_name,
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
      "Duplicate country-year model rows were found for ",
      measure_name,
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

make_slope_panel <- function(slope_result, panel_spec) {
  panel_plot <- ggslope_index(
    data = slope_result,
    model = SLOPE_MODEL,
    color_name = COLOR_BY_YEAR,
    group_name = "year",
    region_name = "All included",
    measure_name = panel_spec$measure_name,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    rei_name = NULL,
    age_name = TOOL_COMPATIBLE_AGE_NAME,
    year_name = FIGURE4_YEARS,
    country_label = NULL,
    population_count = POPULATION_COUNT
  )

  panel_plot <- remove_repel_label_layers(panel_plot)

  panel_plot <- panel_plot +
    labs(
      title = panel_spec$slope_panel_label,
      x = "Relative rank by SDI",
      y = panel_spec$slope_y_axis_title
    ) +
    scale_x_continuous(
      limits = c(0, 1.2),
      breaks = seq(0, 1.0, by = 0.1)
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
      axis.text.y = element_text(size = 8),
      axis.title.x = element_text(size = 10),
      axis.title.y = element_text(size = 10),
      plot.title = element_text(face = "bold", size = 14, hjust = 0),
      legend.text = element_text(size = 6),
      legend.title = element_text(size = 7),
      legend.key.width = unit(0.45, "cm"),
      legend.key.height = unit(0.35, "cm")
    )

  return(panel_plot)
}

make_concentration_panel <- function(concentration_result, panel_spec) {
  panel_plot <- ggconcentration_index(
    data = concentration_result,
    color_name = COLOR_BY_YEAR,
    group_name = "year",
    region_name = "All included",
    measure_name = panel_spec$measure_name,
    sex_name = SEX_NAME,
    cause_name = CAUSE_NAME,
    rei_name = NULL,
    age_name = TOOL_COMPATIBLE_AGE_NAME,
    year_name = FIGURE4_YEARS,
    country_label = NULL,
    population_count = POPULATION_COUNT,
    line_type = CONCENTRATION_LINE_TYPE
  )

  panel_plot <- remove_repel_label_layers(panel_plot)

  panel_plot <- panel_plot +
    labs(
      title = panel_spec$concentration_panel_label,
      x = "Cumulative fraction of population ranked by SDI",
      y = panel_spec$concentration_y_axis_title
    ) +
    scale_x_continuous(
      limits = c(0, 1.2),
      breaks = seq(0, 1.0, by = 0.1)
    ) +
    scale_size_area(
      name = "Population (millions)"
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
      axis.text.y = element_text(size = 8),
      axis.title.x = element_text(size = 10),
      axis.title.y = element_text(size = 10),
      plot.title = element_text(face = "bold", size = 14, hjust = 0),
      legend.text = element_text(size = 6),
      legend.title = element_text(size = 7),
      legend.key.width = unit(0.45, "cm"),
      legend.key.height = unit(0.35, "cm")
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

write_reproducibility_files <- function(
  output_folder,
  country_locations,
  source_under_five_label
) {
  manifest <- data.frame(
    item = c(
      "Figure",
      "GBD release",
      "Cause",
      "Downloaded locations",
      "Model locations",
      "Sex",
      "Downloaded age",
      "Downloaded metric",
      "Measures",
      "Years",
      "Cross-age standardisation",
      "Tool-compatible age field",
      "Value transformation",
      "Core functions",
      "Raw data folder name",
      "Final TIFF"
    ),
    required_selection = c(
      "Figure 4",
      "GBD 2021",
      CAUSE_NAME,
      "204 countries and territories; aggregate rows may be present but are filtered out",
      paste0(length(country_locations), " countries/territories from GBDRegion2021$location"),
      SEX_NAME,
      source_under_five_label,
      SOURCE_METRIC_NAME,
      "Incidence; Deaths; YLDs (Years Lived with Disability)",
      paste(FIGURE4_YEARS, collapse = "; "),
      "Not applied; one age interval only",
      TOOL_COMPATIBLE_AGE_NAME,
      "Under-five Rate copied unchanged into the tool-compatible age field",
      "GBDslope_index(); GBDconcentration_index(); ggslope_index(); ggconcentration_index()",
      RAW_GBD_FOLDER_NAME,
      "Figure 4.tif"
    ),
    stringsAsFactors = FALSE
  )

  write.csv(
    manifest,
    file = file.path(
      output_folder,
      "00_Figure4_data_download_and_method_manifest.csv"
    ),
    row.names = FALSE
  )

  write.csv(
    data.frame(
      country_order = seq_along(country_locations),
      location = country_locations,
      stringsAsFactors = FALSE
    ),
    file = file.path(
      output_folder,
      "00_Figure4_204_country_and_territory_locations_used.csv"
    ),
    row.names = FALSE
  )

  readme_lines <- c(
    "Figure 4 reproducibility package",
    "================================",
    "",
    "Final figure:",
    "  Figure 4.tif",
    "",
    "Panels:",
    "  Figure 4A: ASIR, slope index of inequality",
    "  Figure 4B: ASIR, concentration curve and concentration index",
    "  Figure 4C: ASMR, slope index of inequality",
    "  Figure 4D: ASMR, concentration curve and concentration index",
    "  Figure 4E: ASYR, slope index of inequality",
    "  Figure 4F: ASYR, concentration curve and concentration index",
    "",
    "Raw input data folder:",
    paste0("  ", RAW_GBD_FOLDER_NAME),
    "",
    "Required GBD data selections:",
    "  GBD 2021; cause = Meningitis; sex = Both;",
    "  locations = 204 countries and territories;",
    paste0("  age = ", source_under_five_label, ";"),
    "  metric = Rate;",
    "  measures = Incidence, Deaths, YLDs;",
    "  years = 1990 and 2021.",
    "",
    "Method clarification:",
    "  This analysis concerns one age band only: children under 5 years.",
    "  The downloaded under-five Rate is used directly.",
    "  No cross-age aggregation or age standardisation is performed.",
    "",
    "Tool-interface compatibility:",
    "  The easyGBDR inequality tools read estimates only from rows coded as",
    "  age = Age-standardized and metric = Rate. Therefore the original",
    "  under-five Rate is copied unchanged into that age field.",
    "  The original age label is retained in source_age and the original value",
    "  is retained in source_rate_value for reviewer verification.",
    "",
    "Interpretation:",
    "  The resulting estimate remains the rate for the under-five population.",
    "  It is not a conventional all-age age-standardised rate.",
    "",
    "Main outputs:",
    "  01_raw_under5_rate_used: exact downloaded under-five Rate rows",
    "  02_tool_compatible_model_input: identical rates with compatibility age field",
    "  03_Figure4_slope_index_outputs: slope-index outputs",
    "  04_Figure4_concentration_index_outputs: concentration-index outputs",
    "  05_Figure4_panel_figures: Figure 4A-F single-panel PDFs",
    "  06_final_Figure4: final six-panel TIFF",
    "  07_saved_R_objects: saved data and ggplot objects"
  )

  writeLines(
    readme_lines,
    con = file.path(
      output_folder,
      "00_README_Figure4_reproducibility.txt"
    )
  )
}

# -----------------------------------------------------------------------------
# 6. Create output folders
# -----------------------------------------------------------------------------

print_raw_data_download_manifest()

RAW_USED_DIR <- create_folder(
  file.path(OUTPUT_DIR, "01_raw_under5_rate_used")
)

MODEL_INPUT_DIR <- create_folder(
  file.path(OUTPUT_DIR, "02_tool_compatible_model_input")
)

SLOPE_OUTPUT_DIR <- create_folder(
  file.path(OUTPUT_DIR, "03_Figure4_slope_index_outputs")
)

CONCENTRATION_OUTPUT_DIR <- create_folder(
  file.path(OUTPUT_DIR, "04_Figure4_concentration_index_outputs")
)

PANEL_FIGURE_DIR <- create_folder(
  file.path(OUTPUT_DIR, "05_Figure4_panel_figures")
)

FINAL_FIGURE_DIR <- create_folder(
  file.path(OUTPUT_DIR, "06_final_Figure4")
)

OBJECT_DIR <- create_folder(
  file.path(OUTPUT_DIR, "07_saved_R_objects")
)

# -----------------------------------------------------------------------------
# 7. Read direct under-five Rate data and prepare model data
# -----------------------------------------------------------------------------

country_locations <- load_country_location_vector()

if (length(country_locations) != 204) {
  warning(
    "GBDRegion2021$location contains ",
    length(country_locations),
    " locations, not 204. The script will still use this vector as the ",
    "country/territory reference.",
    call. = FALSE
  )
}

figure4_under5_rate_raw_data <- read_raw_gbd_data(
  raw_folder = RAW_GBD_FOLDER
)

available_labels_raw <- list(
  location = unique(figure4_under5_rate_raw_data$location),
  sex = unique(figure4_under5_rate_raw_data$sex),
  age = unique(figure4_under5_rate_raw_data$age),
  cause = unique(figure4_under5_rate_raw_data$cause),
  measure = unique(figure4_under5_rate_raw_data$measure),
  metric = unique(figure4_under5_rate_raw_data$metric),
  year = sort(unique(figure4_under5_rate_raw_data$year))
)

saveRDS(
  available_labels_raw,
  file = file.path(
    OUTPUT_DIR,
    "00_available_GBD_labels_in_raw_Figure4_data.rds"
  )
)

cat("\nAvailable labels in the raw Figure 4 data:\n")
cat("Locations: ", length(available_labels_raw$location), "\n", sep = "")
cat("Sex: ", paste(available_labels_raw$sex, collapse = " | "), "\n", sep = "")
cat("Age: ", paste(available_labels_raw$age, collapse = " | "), "\n", sep = "")
cat("Cause: ", paste(available_labels_raw$cause, collapse = " | "), "\n", sep = "")
cat("Measure: ", paste(available_labels_raw$measure, collapse = " | "), "\n", sep = "")
cat("Metric: ", paste(available_labels_raw$metric, collapse = " | "), "\n", sep = "")
cat("Years: ", paste(available_labels_raw$year, collapse = " | "), "\n", sep = "")

SOURCE_UNDER_FIVE_AGE_LABEL <- resolve_under_five_label(
  available_ages = available_labels_raw$age
)

figure4_direct_under5_rate_data <- prepare_direct_under5_rate_data(
  raw_data = figure4_under5_rate_raw_data,
  country_locations = country_locations,
  under_five_label = SOURCE_UNDER_FIVE_AGE_LABEL
)

check_direct_under5_rate_data(
  under5_rate_data = figure4_direct_under5_rate_data,
  country_locations = country_locations
)

write.csv(
  figure4_direct_under5_rate_data,
  file = file.path(
    RAW_USED_DIR,
    "Figure4_allPanels_directUnder5Rate_204Countries_Incidence_Deaths_YLD_1990_2021.csv"
  ),
  row.names = FALSE
)

for (measure_index in seq_along(FIGURE4_MEASURE_SPECS)) {
  current_spec <- FIGURE4_MEASURE_SPECS[[measure_index]]

  current_raw_input <- figure4_direct_under5_rate_data[
    as.character(figure4_direct_under5_rate_data$measure) ==
      current_spec$measure_name,
    ,
    drop = FALSE
  ]

  write.csv(
    current_raw_input,
    file = file.path(
      RAW_USED_DIR,
      current_spec$raw_input_file
    ),
    row.names = FALSE
  )
}

figure4_model_data <- create_tool_compatible_inequality_data(
  under5_rate_data = figure4_direct_under5_rate_data,
  source_under_five_label = SOURCE_UNDER_FIVE_AGE_LABEL
)

write.csv(
  figure4_model_data,
  file = file.path(
    MODEL_INPUT_DIR,
    "Figure4_allPanels_toolCompatibleAgeField_directUnder5Rate_204Countries_1990_2021.csv"
  ),
  row.names = FALSE
)

for (measure_index in seq_along(FIGURE4_MEASURE_SPECS)) {
  current_spec <- FIGURE4_MEASURE_SPECS[[measure_index]]

  check_measure_model_data(
    model_data = figure4_model_data,
    measure_name = current_spec$measure_name,
    country_locations = country_locations
  )

  current_measure_model_input <- figure4_model_data[
    as.character(figure4_model_data$measure) ==
      current_spec$measure_name,
    ,
    drop = FALSE
  ]

  write.csv(
    current_measure_model_input,
    file = file.path(
      MODEL_INPUT_DIR,
      current_spec$model_input_file
    ),
    row.names = FALSE
  )
}

write_reproducibility_files(
  output_folder = OUTPUT_DIR,
  country_locations = country_locations,
  source_under_five_label = SOURCE_UNDER_FIVE_AGE_LABEL
)

# -----------------------------------------------------------------------------
# 8. Run slope-index and concentration-index models
# -----------------------------------------------------------------------------

cat("\n============================================================\n")
cat("Running GBDslope_index() for Figure 4\n")
cat("Input: direct under-five Rates copied unchanged into\n")
cat("age = 'Age-standardized' for tool compatibility.\n")
cat("Cross-age standardisation applied: No\n")
cat("============================================================\n")

SI_country <- GBDslope_index(
  data = figure4_model_data,
  all_age_range = NULL,
  SDI = FALSE,
  GBDregion = FALSE,
  SuperGBDregion = FALSE
)

saveRDS(
  SI_country,
  file = file.path(
    SLOPE_OUTPUT_DIR,
    "Figure4_GBDslopeIndex_country_result.rds"
  )
)

write_if_dataframe(
  SI_country[["slope"]],
  file.path(
    SLOPE_OUTPUT_DIR,
    "Figure4_slopeIndex_country_slope_table.csv"
  )
)

write_if_dataframe(
  SI_country[["intercept"]],
  file.path(
    SLOPE_OUTPUT_DIR,
    "Figure4_slopeIndex_country_intercept_table.csv"
  )
)

if ("weigted_order" %in% names(SI_country)) {
  write_if_dataframe(
    SI_country[["weigted_order"]],
    file.path(
      SLOPE_OUTPUT_DIR,
      "Figure4_slopeIndex_country_weighted_order_table.csv"
    )
  )
}

if ("weighted_order" %in% names(SI_country)) {
  write_if_dataframe(
    SI_country[["weighted_order"]],
    file.path(
      SLOPE_OUTPUT_DIR,
      "Figure4_slopeIndex_country_weighted_order_table.csv"
    )
  )
}

write_if_dataframe(
  SI_country[["data"]],
  file.path(
    SLOPE_OUTPUT_DIR,
    "Figure4_slopeIndex_country_model_data.csv"
  )
)

capture.output(
  str(SI_country),
  file = file.path(
    SLOPE_OUTPUT_DIR,
    "Figure4_GBDslopeIndex_result_structure.txt"
  )
)

cat("\n============================================================\n")
cat("Running GBDconcentration_index() for Figure 4\n")
cat("Input: direct under-five Rates copied unchanged into\n")
cat("age = 'Age-standardized' for tool compatibility.\n")
cat("Cross-age standardisation applied: No\n")
cat("============================================================\n")

CI_country <- GBDconcentration_index(
  data = figure4_model_data,
  all_age_range = NULL,
  SDI = FALSE,
  GBDregion = FALSE,
  SuperGBDregion = FALSE
)

saveRDS(
  CI_country,
  file = file.path(
    CONCENTRATION_OUTPUT_DIR,
    "Figure4_GBDconcentrationIndex_country_result.rds"
  )
)

if ("Concentration_index" %in% names(CI_country)) {
  write_if_dataframe(
    CI_country[["Concentration_index"]],
    file.path(
      CONCENTRATION_OUTPUT_DIR,
      "Figure4_concentrationIndex_country_table.csv"
    )
  )
}

if ("data" %in% names(CI_country)) {
  write_if_dataframe(
    CI_country[["data"]],
    file.path(
      CONCENTRATION_OUTPUT_DIR,
      "Figure4_concentrationIndex_country_model_data.csv"
    )
  )
}

capture.output(
  str(CI_country),
  file = file.path(
    CONCENTRATION_OUTPUT_DIR,
    "Figure4_GBDconcentrationIndex_result_structure.txt"
  )
)

CI_compare_by_measure <- list()

for (measure_index in seq_along(FIGURE4_MEASURE_SPECS)) {
  current_spec <- FIGURE4_MEASURE_SPECS[[measure_index]]

  CI_compare_by_measure[[current_spec$metric_short]] <-
    GBDconcentration_compare(
      data = CI_country,
      group_name = "year",
      region_name = "All included",
      measure_name = current_spec$measure_name,
      sex_name = SEX_NAME,
      cause_name = CAUSE_NAME,
      rei_name = NULL,
      age_name = TOOL_COMPATIBLE_AGE_NAME,
      year_name = FIGURE4_YEARS,
      digits = 2
    )

  if (is.data.frame(
    CI_compare_by_measure[[current_spec$metric_short]]
  )) {
    write.csv(
      CI_compare_by_measure[[current_spec$metric_short]],
      file = file.path(
        CONCENTRATION_OUTPUT_DIR,
        paste0(
          "Figure4_",
          current_spec$metric_short,
          "_concentrationIndex_1990_vs_2021_compare.csv"
        )
      ),
      row.names = FALSE
    )
  }
}

saveRDS(
  CI_compare_by_measure,
  file = file.path(
    CONCENTRATION_OUTPUT_DIR,
    "Figure4_concentrationIndex_compare_by_measure.rds"
  )
)

# -----------------------------------------------------------------------------
# 9. Generate Figure 4A-F panels
# -----------------------------------------------------------------------------

figure4_panels <- list()

for (measure_index in seq_along(FIGURE4_MEASURE_SPECS)) {
  current_spec <- FIGURE4_MEASURE_SPECS[[measure_index]]

  cat("\n============================================================\n")
  cat(
    "Generating Figure 4 panels for ",
    current_spec$metric_short,
    "\n",
    sep = ""
  )
  cat("Measure: ", current_spec$measure_name, "\n", sep = "")
  cat("============================================================\n")

  slope_panel <- make_slope_panel(
    slope_result = SI_country,
    panel_spec = current_spec
  )

  concentration_panel <- make_concentration_panel(
    concentration_result = CI_country,
    panel_spec = current_spec
  )

  figure4_panels[[current_spec$slope_panel_id]] <- slope_panel
  figure4_panels[[current_spec$concentration_panel_id]] <-
    concentration_panel

  if (WRITE_PANEL_FILES) {
    ggsave(
      filename = file.path(
        PANEL_FIGURE_DIR,
        current_spec$slope_panel_pdf
      ),
      plot = slope_panel,
      width = 6,
      height = 5,
      dpi = 600
    )

    ggsave(
      filename = file.path(
        PANEL_FIGURE_DIR,
        current_spec$concentration_panel_pdf
      ),
      plot = concentration_panel,
      width = 6,
      height = 5,
      dpi = 600
    )
  }
}

# -----------------------------------------------------------------------------
# 10. Save final six-panel Figure 4
# -----------------------------------------------------------------------------

figure4_tiff_path <- file.path(
  FINAL_FIGURE_DIR,
  "Figure 4.tif"
)

save_six_panel_tiff(
  panel_a = figure4_panels[["Figure4A_ASIR_slope_index"]],
  panel_b = figure4_panels[["Figure4B_ASIR_concentration_curve"]],
  panel_c = figure4_panels[["Figure4C_ASMR_slope_index"]],
  panel_d = figure4_panels[["Figure4D_ASMR_concentration_curve"]],
  panel_e = figure4_panels[["Figure4E_ASYR_slope_index"]],
  panel_f = figure4_panels[["Figure4F_ASYR_concentration_curve"]],
  output_file = figure4_tiff_path
)

if (WRITE_FINAL_PDF) {
  figure4_pdf_path <- file.path(
    FINAL_FIGURE_DIR,
    "Figure 4.pdf"
  )

  save_six_panel_pdf(
    panel_a = figure4_panels[["Figure4A_ASIR_slope_index"]],
    panel_b = figure4_panels[["Figure4B_ASIR_concentration_curve"]],
    panel_c = figure4_panels[["Figure4C_ASMR_slope_index"]],
    panel_d = figure4_panels[["Figure4D_ASMR_concentration_curve"]],
    panel_e = figure4_panels[["Figure4E_ASYR_slope_index"]],
    panel_f = figure4_panels[["Figure4F_ASYR_concentration_curve"]],
    output_file = figure4_pdf_path
  )
}

saveRDS(
  figure4_panels,
  file = file.path(
    OBJECT_DIR,
    "Figure4_panel_ggplot_objects_A_to_F.rds"
  )
)

saveRDS(
  figure4_direct_under5_rate_data,
  file = file.path(
    OBJECT_DIR,
    "Figure4_direct_under5_rate_data.rds"
  )
)

saveRDS(
  figure4_model_data,
  file = file.path(
    OBJECT_DIR,
    "Figure4_tool_compatible_model_input_direct_under5_rate.rds"
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
cat("Figure 4 inequality analysis completed successfully.\n")
cat(
  "Final figure: ",
  normalizePath(figure4_tiff_path, winslash = "/", mustWork = FALSE),
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
  "Raw data folder name: ",
  RAW_GBD_FOLDER_NAME,
  "\n",
  sep = ""
)
cat(
  "Countries/territories used: ",
  length(country_locations),
  "\n",
  sep = ""
)
cat(
  "Original downloaded age label: ",
  SOURCE_UNDER_FIVE_AGE_LABEL,
  "\n",
  sep = ""
)
cat(
  "Tool-compatible age field: ",
  TOOL_COMPATIBLE_AGE_NAME,
  "\n",
  sep = ""
)
cat(
  "Metric used: ",
  TOOL_COMPATIBLE_METRIC_NAME,
  "\n",
  sep = ""
)
cat("Cross-age standardisation applied: No\n")
cat("Value transformation: none; original under-five Rate copied unchanged.\n")
cat(
  "Years used: ",
  paste(FIGURE4_YEARS, collapse = ", "),
  "\n",
  sep = ""
)
cat("============================================================\n")

# =============================================================================
# Suggested Figure 4 caption
# =============================================================================
#
# Figure 4. Health inequality regression and concentration curves for the
# under-five incidence rate (A, B), mortality rate (C, D), and YLD rate
# (E, F) of meningitis. Panels A, C, and E show the slope index of inequality
# according to the relative SDI rank. Panels B, D, and F show concentration
# curves and concentration indices. Blue indicates 1990 and red indicates 2021.
#
# For compatibility with the easyGBDR inequality-analysis interface, the
# directly downloaded under-five Rate was supplied in the field labelled
# "Age-standardized". No cross-age standardisation was applied because the
# analysis concerns one age interval only. The values therefore represent
# rates in the under-five population rather than conventional all-age
# age-standardised rates.
#
# Abbreviations: ASIR, under-five age-specific incidence rate; ASMR,
# under-five age-specific mortality rate; ASYR, under-five age-specific
# YLD rate; YLD, years lived with disability; SDI, Socio-demographic Index.
#
# =============================================================================
# End of script
# =============================================================================
