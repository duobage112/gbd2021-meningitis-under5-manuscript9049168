# =============================================================================
# Reproducibility Script:
# Supplementary Figure 10
#
# Prevalence of epilepsy attributed to meningitis among children under
# 5 years of age by region in 1990 and 2021
#
# R version: compatible with R 3.3.3
# =============================================================================

rm(list = ls())
options(stringsAsFactors = FALSE)

# -----------------------------------------------------------------------------
# 1. Required packages
# -----------------------------------------------------------------------------

required_packages <- c("ggplot2", "gridExtra")

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

suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(gridExtra))
suppressPackageStartupMessages(library(grid))

# -----------------------------------------------------------------------------
# 2. Project paths and GBD download specification
# -----------------------------------------------------------------------------
#
# Recommended folder structure:
#
# D:/Meningitis_SuppFig10_Reproducibility/
# ├── 01_raw_GBD_data/
# │   └── IHME_GBD2021_EpilepsyAttributedToMeningitis_BothSex_Under5_PrevalenceRate_1990_2021/
# │       └── IHME-GBD_2021_DATA-xxxxxxxx.csv
# └── 02_analysis_output/       # Created automatically
#
# Required GBD Results selections:
#   GBD release:  GBD 2021
#   Outcome:      Epilepsy attributed to meningitis
#   Measure:      Prevalence
#   Metric:       Rate
#   Sex:          Both
#   Age:          <5, <5 years, or 0 to 4 depending on the exported GBD label
#   Years:        1990 and 2021
#   Locations:    Global, five SDI quintiles, and 21 GBD regions
#
# The corresponding GBD cause/sequela ID, measure ID, metric ID, age-group ID,
# sex ID, location IDs, and any other query IDs are provided in the
# supplementary indicator table.

PROJECT_DIR <- "D:/Meningitis_SuppFig10_Reproducibility"

RAW_DATA_FOLDER_NAME <- paste0(
    "IHME_GBD2021_EpilepsyAttributedToMeningitis_BothSex_",
    "Under5_PrevalenceRate_1990_2021"
)

INPUT_FOLDER <- file.path(
    PROJECT_DIR,
    "01_raw_GBD_data",
    RAW_DATA_FOLDER_NAME
)

OUTPUT_DIR <- file.path(
    PROJECT_DIR,
    "02_analysis_output"
)

SOURCE_DATA_DIR <- file.path(OUTPUT_DIR, "01_source_data")
FIGURE_DIR <- file.path(OUTPUT_DIR, "02_figures")
CHECK_DIR <- file.path(OUTPUT_DIR, "03_data_checks")

dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(SOURCE_DATA_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIGURE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(CHECK_DIR, recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# 3. Core GBD selections
# -----------------------------------------------------------------------------

SEX_NAME <- "Both"
MEASURE_NAME <- "Prevalence"
METRIC_NAME <- "Rate"

YEARS_TO_PLOT <- c(1990, 2021)

# If the GBD export contains a specific column for the sequela/cause name,
# this script will try to identify it using the following candidates.
# Please adjust TARGET_LABEL_CANDIDATES according to the label shown in your
# GBD export and the supplementary indicator table.

TARGET_COLUMN_CANDIDATES <- c("sequela", "cause", "rei")

TARGET_LABEL_CANDIDATES <- c(
    "Epilepsy attributed to meningitis",
    "Epilepsy attributable to meningitis",
    "Epilepsy due to meningitis"
)

# If your downloaded file has already been restricted to epilepsy attributed
# to meningitis and does not contain a separate cause/sequela label, set this
# to FALSE.
APPLY_TARGET_FILTER <- TRUE

# -----------------------------------------------------------------------------
# 4. Location order
# -----------------------------------------------------------------------------
# This order follows the uploaded Supplementary Figure 10.

LOCATION_ORDER_TOP_TO_BOTTOM <- c(
    "Southern Sub-Saharan Africa",
    "Central Sub-Saharan Africa",
    "Eastern Sub-Saharan Africa",
    "Western Sub-Saharan Africa",
    "Oceania",
    "East Asia",
    "Southeast Asia",
    "South Asia",
    "North Africa and Middle East",
    "Central Asia",
    "Eastern Europe",
    "Central Europe",
    "Caribbean",
    "Southern Latin America",
    "Central Latin America",
    "Tropical Latin America",
    "Andean Latin America",
    "Australasia",
    "Western Europe",
    "High-income North America",
    "High-income Asia Pacific",
    "Low SDI",
    "Low-middle SDI",
    "Middle SDI",
    "High-middle SDI",
    "High SDI",
    "Global"
)

# -----------------------------------------------------------------------------
# 5. Figure settings
# -----------------------------------------------------------------------------

COLOR_1990 <- "#990000"
COLOR_2021 <- "#2F86D6"

PANEL_BACKGROUND <- "#CAD7D9"

# These limits are close to the submitted figure.
# If your updated GBD data exceed these limits, the script will automatically
# expand the axis to avoid clipping bars.
REFERENCE_XMAX_1990 <- 30
REFERENCE_XMAX_2021 <- 10

TIFF_WIDTH_PX <- 2009
TIFF_HEIGHT_PX <- 1017
TIFF_DPI <- 300

WRITE_PDF <- TRUE
WRITE_PNG <- TRUE

# -----------------------------------------------------------------------------
# 6. Helper functions
# -----------------------------------------------------------------------------

read_gbd_folder <- function(folder) {
    csv_files <- list.files(
        folder,
        pattern = "\\.csv$",
        recursive = TRUE,
        full.names = TRUE
    )
    
    if (length(csv_files) == 0) {
        stop(
            "No CSV files were found in INPUT_FOLDER:\n",
            folder,
            call. = FALSE
        )
    }
    
    data_list <- lapply(csv_files, function(file) {
        read.csv(file, header = TRUE, stringsAsFactors = FALSE)
    })
    
    data <- do.call(rbind, data_list)
    
    return(data)
}

assert_columns <- function(data, required_columns) {
    missing_columns <- setdiff(required_columns, names(data))
    
    if (length(missing_columns) > 0) {
        stop(
            "The imported GBD data are missing required column(s): ",
            paste(missing_columns, collapse = ", "),
            "\nAvailable columns are:\n",
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
            "\nAvailable values are:\n",
            paste(available_values, collapse = " | "),
            call. = FALSE
        )
    }
}

resolve_under_five_label <- function(available_ages) {
    candidates <- c(
        "<5",
        "<5 years",
        "< 5",
        "< 5 years",
        "0 to 4",
        "Under 5",
        "Under 5 years"
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

apply_target_filter <- function(data) {
    if (!APPLY_TARGET_FILTER) {
        return(data)
    }
    
    for (column_name in TARGET_COLUMN_CANDIDATES) {
        if (column_name %in% names(data)) {
            available_values <- unique(as.character(data[[column_name]]))
            matched_values <- TARGET_LABEL_CANDIDATES[
                TARGET_LABEL_CANDIDATES %in% available_values
            ]
            
            if (length(matched_values) > 0) {
                filtered_data <- data[
                    as.character(data[[column_name]]) %in% matched_values,
                    ,
                    drop = FALSE
                ]
                
                attr(filtered_data, "target_filter_column") <- column_name
                attr(filtered_data, "target_filter_value") <- matched_values[1]
                
                return(filtered_data)
            }
        }
    }
    
    stop(
        "Could not identify epilepsy attributed to meningitis in the downloaded data.\n",
        "Please check whether the GBD export contains one of the following labels:\n",
        paste(TARGET_LABEL_CANDIDATES, collapse = " | "),
        "\n\nAvailable candidate columns are:\n",
        paste(intersect(TARGET_COLUMN_CANDIDATES, names(data)), collapse = " | "),
        "\n\nIf the downloaded CSV has already been restricted to this outcome, ",
        "set APPLY_TARGET_FILTER <- FALSE.",
        call. = FALSE
    )
}

make_nice_xmax <- function(values, reference_xmax) {
    max_value <- max(values, na.rm = TRUE)
    
    if (!is.finite(max_value)) {
        stop("Cannot determine x-axis limit because all values are missing.")
    }
    
    if (max_value <= reference_xmax) {
        return(reference_xmax)
    }
    
    if (max_value <= 10) {
        return(ceiling(max_value / 2) * 2)
    }
    
    return(ceiling(max_value / 5) * 5)
}

make_panel_plot <- function(plot_data, year_value, fill_color, x_max, show_y_axis) {
    panel_data <- plot_data[
        plot_data$year == year_value,
        ,
        drop = FALSE
    ]
    
    panel_data$legend_year <- as.character(year_value)
    
    p <- ggplot(
        panel_data,
        aes(x = location_factor, y = val, fill = legend_year)
    ) +
        geom_bar(
            stat = "identity",
            width = 0.68,
            color = fill_color,
            size = 0.05
        ) +
        coord_flip() +
        scale_x_discrete(drop = FALSE) +
        scale_y_continuous(
            expand = c(0, 0),
            limits = c(0, x_max)
        ) +
        scale_fill_manual(
            values = setNames(fill_color, as.character(year_value)),
            name = NULL
        ) +
        labs(
            x = NULL,
            y = NULL
        ) +
        theme_bw(base_size = 8) +
        theme(
            panel.background = element_rect(fill = PANEL_BACKGROUND, colour = NA),
            panel.grid.major = element_line(colour = "white", size = 0.35),
            panel.grid.minor = element_line(colour = "white", size = 0.20),
            panel.border = element_blank(),
            axis.line = element_line(colour = "black", size = 0.25),
            axis.text.x = element_text(size = 8, colour = "black"),
            axis.text.y = element_text(size = 8, colour = "black"),
            axis.ticks = element_line(colour = "black", size = 0.25),
            legend.position = c(0.93, 0.97),
            legend.justification = c(1, 1),
            legend.background = element_blank(),
            legend.key = element_blank(),
            legend.key.size = unit(0.25, "cm"),
            legend.text = element_text(size = 9)
        )
    
    if (!show_y_axis) {
        p <- p +
            theme(
                axis.text.y = element_blank(),
                axis.ticks.y = element_blank()
            )
    }
    
    return(p)
}

write_manifest <- function(
        output_folder,
        under_five_label,
        target_column,
        target_value
) {
    manifest <- data.frame(
        item = c(
            "GBD release",
            "Raw data directory",
            "Outcome",
            "Target filter column",
            "Target filter value",
            "Measure",
            "Metric",
            "Sex",
            "Age",
            "Years",
            "Locations",
            "GBD query IDs"
        ),
        required_selection = c(
            "GBD 2021",
            RAW_DATA_FOLDER_NAME,
            "Epilepsy attributed to meningitis",
            target_column,
            target_value,
            MEASURE_NAME,
            METRIC_NAME,
            SEX_NAME,
            under_five_label,
            paste(YEARS_TO_PLOT, collapse = "; "),
            paste(LOCATION_ORDER_TOP_TO_BOTTOM, collapse = "; "),
            "Provided in the supplementary indicator table"
        ),
        stringsAsFactors = FALSE
    )
    
    write.csv(
        manifest,
        file = file.path(output_folder, "00_Supplementary_Figure_10_GBD_download_manifest.csv"),
        row.names = FALSE
    )
    
    readme_lines <- c(
        "Supplementary Figure 10 Reproducibility Package",
        "================================================",
        "",
        "This script reproduces Supplementary Figure 10:",
        "Prevalence of epilepsy attributed to meningitis among children under",
        "5 years of age by region in 1990 and 2021.",
        "",
        "Required GBD 2021 Results selections:",
        "  Outcome: Epilepsy attributed to meningitis",
        paste0("  Measure: ", MEASURE_NAME),
        paste0("  Metric: ", METRIC_NAME),
        paste0("  Sex: ", SEX_NAME),
        paste0("  Age: ", under_five_label),
        paste0("  Years: ", paste(YEARS_TO_PLOT, collapse = " and ")),
        "  Locations: Global, five SDI quintiles, and 21 GBD regions",
        "",
        "The corresponding GBD cause/sequela ID, measure ID, metric ID, age-group ID,",
        "sex ID, location IDs, and other query IDs are provided in the supplementary",
        "indicator table.",
        "",
        "Output files:",
        "  01_source_data/Supplementary_Figure_10_source_data.csv",
        "  02_figures/Supplementary material Figure 10.tif",
        "  02_figures/Supplementary material Figure 10.pdf, if WRITE_PDF = TRUE",
        "  02_figures/Supplementary material Figure 10.png, if WRITE_PNG = TRUE"
    )
    
    writeLines(
        readme_lines,
        con = file.path(output_folder, "00_README_Supplementary_Figure_10.txt")
    )
}

# -----------------------------------------------------------------------------
# 7. Read and validate raw data
# -----------------------------------------------------------------------------

if (!dir.exists(INPUT_FOLDER)) {
    stop(
        "INPUT_FOLDER does not exist:\n",
        INPUT_FOLDER,
        "\n\nCreate this folder, place the downloaded IHME GBD CSV file(s) inside it, ",
        "then run the script again.",
        call. = FALSE
    )
}

gbd_raw <- read_gbd_folder(INPUT_FOLDER)

required_columns <- c(
    "location", "sex", "age", "measure", "metric", "year", "val"
)

assert_columns(gbd_raw, required_columns)

gbd_raw$location <- as.character(gbd_raw$location)
gbd_raw$sex <- as.character(gbd_raw$sex)
gbd_raw$age <- as.character(gbd_raw$age)
gbd_raw$measure <- as.character(gbd_raw$measure)
gbd_raw$metric <- as.character(gbd_raw$metric)
gbd_raw$year <- as.numeric(as.character(gbd_raw$year))
gbd_raw$val <- as.numeric(as.character(gbd_raw$val))

if ("cause" %in% names(gbd_raw)) {
    gbd_raw$cause <- as.character(gbd_raw$cause)
}

if ("sequela" %in% names(gbd_raw)) {
    gbd_raw$sequela <- as.character(gbd_raw$sequela)
}

if ("rei" %in% names(gbd_raw)) {
    gbd_raw$rei <- as.character(gbd_raw$rei)
}

available_labels <- list(
    location = unique(gbd_raw$location),
    sex = unique(gbd_raw$sex),
    age = unique(gbd_raw$age),
    measure = unique(gbd_raw$measure),
    metric = unique(gbd_raw$metric)
)

if ("cause" %in% names(gbd_raw)) {
    available_labels$cause <- unique(gbd_raw$cause)
}

if ("sequela" %in% names(gbd_raw)) {
    available_labels$sequela <- unique(gbd_raw$sequela)
}

if ("rei" %in% names(gbd_raw)) {
    available_labels$rei <- unique(gbd_raw$rei)
}

saveRDS(
    available_labels,
    file = file.path(CHECK_DIR, "00_available_GBD_labels.rds")
)

assert_values_exist(gbd_raw, "location", LOCATION_ORDER_TOP_TO_BOTTOM)
assert_values_exist(gbd_raw, "sex", SEX_NAME)
assert_values_exist(gbd_raw, "measure", MEASURE_NAME)
assert_values_exist(gbd_raw, "metric", METRIC_NAME)

UNDER_FIVE_AGE_LABEL <- resolve_under_five_label(
    available_ages = unique(gbd_raw$age)
)

gbd_target <- apply_target_filter(gbd_raw)

target_filter_column <- attr(gbd_target, "target_filter_column")
target_filter_value <- attr(gbd_target, "target_filter_value")

if (is.null(target_filter_column)) {
    target_filter_column <- "Not applied"
}

if (is.null(target_filter_value)) {
    target_filter_value <- "The raw GBD export was assumed to already contain only the target outcome"
}

write_manifest(
    output_folder = OUTPUT_DIR,
    under_five_label = UNDER_FIVE_AGE_LABEL,
    target_column = target_filter_column,
    target_value = target_filter_value
)

# -----------------------------------------------------------------------------
# 8. Filter source data for Supplementary Figure 10
# -----------------------------------------------------------------------------

supp10_data <- gbd_target[
    gbd_target$location %in% LOCATION_ORDER_TOP_TO_BOTTOM &
        gbd_target$sex == SEX_NAME &
        gbd_target$age == UNDER_FIVE_AGE_LABEL &
        gbd_target$measure == MEASURE_NAME &
        gbd_target$metric == METRIC_NAME &
        gbd_target$year %in% YEARS_TO_PLOT,
    ,
    drop = FALSE
]

if (nrow(supp10_data) == 0) {
    stop(
        "No data remained after filtering for Supplementary Figure 10.",
        call. = FALSE
    )
}

supp10_data$key <- paste(
    supp10_data$location,
    supp10_data$year,
    sep = "___"
)

if (anyDuplicated(supp10_data$key) > 0) {
    duplicated_keys <- unique(supp10_data$key[duplicated(supp10_data$key)])
    
    write.csv(
        supp10_data[supp10_data$key %in% duplicated_keys, ],
        file = file.path(CHECK_DIR, "Supplementary_Figure_10_duplicated_rows.csv"),
        row.names = FALSE
    )
    
    stop(
        "Duplicate location-year rows were found after filtering. ",
        "Please narrow the GBD export using the exact query IDs in the ",
        "supplementary indicator table. Duplicated rows were exported to ",
        "03_data_checks/Supplementary_Figure_10_duplicated_rows.csv.",
        call. = FALSE
    )
}

expected_grid <- expand.grid(
    location = LOCATION_ORDER_TOP_TO_BOTTOM,
    year = YEARS_TO_PLOT,
    stringsAsFactors = FALSE
)

expected_grid$key <- paste(
    expected_grid$location,
    expected_grid$year,
    sep = "___"
)

missing_keys <- setdiff(expected_grid$key, supp10_data$key)

if (length(missing_keys) > 0) {
    missing_table <- expected_grid[expected_grid$key %in% missing_keys, ]
    
    write.csv(
        missing_table,
        file = file.path(CHECK_DIR, "Supplementary_Figure_10_missing_location_years.csv"),
        row.names = FALSE
    )
    
    stop(
        "Some required location-year combinations are missing. ",
        "See 03_data_checks/Supplementary_Figure_10_missing_location_years.csv.",
        call. = FALSE
    )
}

supp10_plot_data <- supp10_data[
    ,
    c("location", "year", "measure", "metric", "sex", "age", "val"),
    drop = FALSE
]

supp10_plot_data$location_factor <- factor(
    supp10_plot_data$location,
    levels = rev(LOCATION_ORDER_TOP_TO_BOTTOM),
    ordered = TRUE
)

supp10_plot_data <- supp10_plot_data[
    order(
        match(supp10_plot_data$location, LOCATION_ORDER_TOP_TO_BOTTOM),
        supp10_plot_data$year
    ),
    ,
    drop = FALSE
]

write.csv(
    supp10_plot_data,
    file = file.path(SOURCE_DATA_DIR, "Supplementary_Figure_10_source_data.csv"),
    row.names = FALSE
)

# -----------------------------------------------------------------------------
# 9. Generate Supplementary Figure 10
# -----------------------------------------------------------------------------

xmax_1990 <- make_nice_xmax(
    values = supp10_plot_data$val[supp10_plot_data$year == 1990],
    reference_xmax = REFERENCE_XMAX_1990
)

xmax_2021 <- make_nice_xmax(
    values = supp10_plot_data$val[supp10_plot_data$year == 2021],
    reference_xmax = REFERENCE_XMAX_2021
)

plot_1990 <- make_panel_plot(
    plot_data = supp10_plot_data,
    year_value = 1990,
    fill_color = COLOR_1990,
    x_max = xmax_1990,
    show_y_axis = TRUE
)

plot_2021 <- make_panel_plot(
    plot_data = supp10_plot_data,
    year_value = 2021,
    fill_color = COLOR_2021,
    x_max = xmax_2021,
    show_y_axis = FALSE
)

combined_plot <- gridExtra::arrangeGrob(
    plot_1990,
    plot_2021,
    ncol = 2,
    widths = c(1, 1),
    left = grid::textGrob(
        "Location",
        rot = 90,
        gp = grid::gpar(fontsize = 12)
    ),
    bottom = grid::textGrob(
        "Prevalence rate (per 100,000)",
        gp = grid::gpar(fontsize = 12)
    )
)

supp10_tiff_path <- file.path(
    FIGURE_DIR,
    "Supplementary material Figure 10.tif"
)

grDevices::tiff(
    filename = supp10_tiff_path,
    width = TIFF_WIDTH_PX,
    height = TIFF_HEIGHT_PX,
    units = "px",
    res = TIFF_DPI,
    compression = "lzw"
)

grid::grid.draw(combined_plot)
grDevices::dev.off()

if (WRITE_PDF) {
    supp10_pdf_path <- file.path(
        FIGURE_DIR,
        "Supplementary material Figure 10.pdf"
    )
    
    grDevices::pdf(
        file = supp10_pdf_path,
        width = TIFF_WIDTH_PX / TIFF_DPI,
        height = TIFF_HEIGHT_PX / TIFF_DPI
    )
    
    grid::grid.draw(combined_plot)
    grDevices::dev.off()
}

if (WRITE_PNG) {
    supp10_png_path <- file.path(
        FIGURE_DIR,
        "Supplementary material Figure 10.png"
    )
    
    grDevices::png(
        filename = supp10_png_path,
        width = TIFF_WIDTH_PX,
        height = TIFF_HEIGHT_PX,
        units = "px",
        res = TIFF_DPI
    )
    
    grid::grid.draw(combined_plot)
    grDevices::dev.off()
}

capture.output(
    sessionInfo(),
    file = file.path(OUTPUT_DIR, "00_R_sessionInfo.txt")
)

cat("\n=================================================================\n")
cat("Supplementary Figure 10 was generated successfully.\n")
cat(
    "Source data: ",
    normalizePath(
        file.path(SOURCE_DATA_DIR, "Supplementary_Figure_10_source_data.csv"),
        winslash = "/",
        mustWork = FALSE
    ),
    "\n",
    sep = ""
)
cat(
    "Final TIFF:  ",
    normalizePath(supp10_tiff_path, winslash = "/", mustWork = FALSE),
    "\n",
    sep = ""
)
cat(
    "Output dir:  ",
    normalizePath(OUTPUT_DIR, winslash = "/", mustWork = FALSE),
    "\n",
    sep = ""
)
cat("=================================================================\n")

# =============================================================================
# End of script
# =============================================================================
