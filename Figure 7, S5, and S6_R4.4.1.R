# =============================================================================
# Reproducible R script for Figure 7, Supplementary Figure 5, and Supplementary Figure 6
#
# Topic:
# Global distribution of age-specific rates of meningitis burden among children
# under 5 years of age in 2021 across 204 countries and territories.
#
# Figure 7:
# ASYR of meningitis among children under 5 years of age in 2021
# Measure: YLDs (Years Lived with Disability)
# Metric: Rate
#
# Supplementary Figure 5:
# ASIR of meningitis among children under 5 years of age in 2021
# Measure: Incidence
# Metric: Rate
#
# Supplementary Figure 6:
# ASMR of meningitis among children under 5 years of age in 2021
# Measure: Deaths
# Metric: Rate
#
# Recommended abbreviation note:
# ASYR, age-specific years-lived-with-disability rate
# ASIR, age-specific incidence rate
# ASMR, age-specific mortality rate
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Load required packages
# -----------------------------------------------------------------------------

required_packages <- c(
    "easyGBDR",
    "gR",
    "ggplot2",
    "tidyverse",
    "ggsci"
)

for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(
            paste0(
                "Package '", pkg, "' is required but not installed. ",
                "Please install it before running this script."
            ),
            call. = FALSE
        )
    }
}

suppressPackageStartupMessages({
    library(easyGBDR)
    library(gR)
    library(ggplot2)
    library(tidyverse)
    library(ggsci)
})


# -----------------------------------------------------------------------------
# 2. Set input and output paths
# -----------------------------------------------------------------------------

# Please modify this path to the main project folder.
PROJECT_DIR <- "C:/Users/Rensh/Desktop/xiaominggbdstudy/世界地图"

# Please modify this path to the folder containing the downloaded GBD 2021 data.
#
# The downloaded GBD data should include:
# cause   = Meningitis
# age     = <5
# sex     = Both
# year    = 2021
# metric  = Rate
# measure = Incidence, Deaths, YLDs (Years Lived with Disability)
# location = 204 countries and territories
GBD_2021_MENINGITIS_UNDER5_DATA_DIR <- "C:/Users/Rensh/Desktop/yll/205 5间隔"

# Output folder for reviewer reproducibility.
REPRODUCIBLE_OUTPUT_DIR <- file.path(
    PROJECT_DIR,
    "Reproducible_outputs_Fig7_SuppFig5_SuppFig6"
)

PLOT_DATA_DIR <- file.path(
    REPRODUCIBLE_OUTPUT_DIR,
    "01_plot_data_for_reviewers"
)

FINAL_FIGURE_DIR <- file.path(
    REPRODUCIBLE_OUTPUT_DIR,
    "02_final_figures"
)

R_OBJECT_DIR <- file.path(
    REPRODUCIBLE_OUTPUT_DIR,
    "03_r_objects"
)

CHECK_FILE_DIR <- file.path(
    REPRODUCIBLE_OUTPUT_DIR,
    "04_data_checks"
)

dir.create(REPRODUCIBLE_OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(PLOT_DATA_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FINAL_FIGURE_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(R_OBJECT_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(CHECK_FILE_DIR, recursive = TRUE, showWarnings = FALSE)


# -----------------------------------------------------------------------------
# 3. Define common GBD filters
# -----------------------------------------------------------------------------

GBD_CAUSE <- "Meningitis"
GBD_SEX <- "Both"
GBD_AGE <- "<5"
GBD_YEAR <- 2021
GBD_METRIC <- "Rate"

# Low burden = blue; high burden = red.
MAP_COLORS_LOW_TO_HIGH <- c(
    "#4393C3",
    "#92C5DE",
    "#D1E5F0",
    "#FDDBC7",
    "#F4A582",
    "#D6604D",
    "#B2182B"
)

MAP_COLOR_SCALE <- paste0(
    "scale_fill_manual(values = c('",
    paste(MAP_COLORS_LOW_TO_HIGH, collapse = "','"),
    "')) + ",
    "scale_color_manual(values = c('",
    paste(MAP_COLORS_LOW_TO_HIGH, collapse = "','"),
    "'))"
)


# -----------------------------------------------------------------------------
# 4. Define figure-specific settings
# -----------------------------------------------------------------------------

figure_specs <- list(
    
    list(
        figure_id = "Figure 7",
        short_id = "Fig7",
        abbreviation = "ASYR",
        full_indicator_name = "Age-specific years-lived-with-disability rate",
        measure = "YLDs (Years Lived with Disability)",
        metric = "Rate",
        output_file_stem = "Fig7_ASYR_YLDsRate_Meningitis_Under5_204Countries_2021",
        breaks = c(0.15, 0.50, 1.00, 2.50, 5.00, 10.00, 20.00, Inf),
        labels = c(
            "0.15 to <0.50",
            "0.50 to <1.00",
            "1.00 to <2.50",
            "2.50 to <5.00",
            "5.00 to <10.00",
            "10.00 to <20.00",
            "20.00 to <47.02"
        )
    ),
    
    list(
        figure_id = "Supplementary Figure 5",
        short_id = "SuppFig5",
        abbreviation = "ASIR",
        full_indicator_name = "Age-specific incidence rate",
        measure = "Incidence",
        metric = "Rate",
        output_file_stem = "SuppFig5_ASIR_IncidenceRate_Meningitis_Under5_204Countries_2021",
        breaks = c(4.44, 15.00, 30.00, 40.00, 60.00, 100.00, 250.00, Inf),
        labels = c(
            "4.44 to <15.00",
            "15.00 to <30.00",
            "30.00 to <40.00",
            "40.00 to <60.00",
            "60.00 to <100.00",
            "100.00 to <250.00",
            "250.00 to <910.82"
        )
    ),
    
    list(
        figure_id = "Supplementary Figure 6",
        short_id = "SuppFig6",
        abbreviation = "ASMR",
        full_indicator_name = "Age-specific mortality rate",
        measure = "Deaths",
        metric = "Rate",
        output_file_stem = "SuppFig6_ASMR_DeathsRate_Meningitis_Under5_204Countries_2021",
        breaks = c(-Inf, 0.60, 1.20, 2.00, 5.00, 15.00, 25.00, Inf),
        labels = c(
            "0.03 to <0.60",
            "0.60 to <1.20",
            "1.20 to <2.00",
            "2.00 to <5.00",
            "5.00 to <15.00",
            "15.00 to <25.00",
            "25.00 to <87.86"
        )
    )
)


# -----------------------------------------------------------------------------
# 5. Save GBD download parameters for reviewers
# -----------------------------------------------------------------------------

reviewer_download_parameters <- purrr::map_dfr(
    figure_specs,
    function(spec) {
        data.frame(
            figure_id = spec$figure_id,
            output_file_stem = spec$output_file_stem,
            cause = GBD_CAUSE,
            measure = spec$measure,
            metric = spec$metric,
            sex = GBD_SEX,
            age = GBD_AGE,
            year = GBD_YEAR,
            location = "204 countries and territories",
            stringsAsFactors = FALSE
        )
    }
)

write.csv(
    reviewer_download_parameters,
    file = file.path(
        REPRODUCIBLE_OUTPUT_DIR,
        "00_GBD_download_parameters_for_reviewers.csv"
    ),
    row.names = FALSE
)


# -----------------------------------------------------------------------------
# 6. Read GBD data
# -----------------------------------------------------------------------------

read_gbd_input_data <- function(input_path) {
    
    if (dir.exists(input_path)) {
        
        message("Reading GBD data from folder: ", input_path)
        
        gbd_data <- GBDread(
            folder = TRUE,
            foldername = input_path
        )
        
    } else if (file.exists(input_path)) {
        
        message("Reading GBD data from file: ", input_path)
        
        gbd_data <- read_GBD(input_path)
        
    } else {
        
        stop(
            paste0(
                "The specified GBD input path does not exist:\n",
                input_path,
                "\nPlease check GBD_2021_MENINGITIS_UNDER5_DATA_DIR."
            ),
            call. = FALSE
        )
    }
    
    gbd_data
}

gbd_2021_meningitis_under5_country_data_raw <- read_gbd_input_data(
    GBD_2021_MENINGITIS_UNDER5_DATA_DIR
)

required_columns <- c(
    "measure", "location", "sex", "age", "cause",
    "metric", "year", "val"
)

missing_columns <- setdiff(
    required_columns,
    names(gbd_2021_meningitis_under5_country_data_raw)
)

if (length(missing_columns) > 0) {
    stop(
        paste0(
            "The following required columns are missing from the GBD data: ",
            paste(missing_columns, collapse = ", ")
        ),
        call. = FALSE
    )
}

gbd_2021_meningitis_under5_country_data <- 
    gbd_2021_meningitis_under5_country_data_raw %>%
    dplyr::mutate(
        year = as.integer(as.character(year))
    )

write.csv(
    gbd_2021_meningitis_under5_country_data,
    file = file.path(
        REPRODUCIBLE_OUTPUT_DIR,
        "00_raw_GBD_2021_meningitis_under5_country_data_used_for_maps.csv"
    ),
    row.names = FALSE
)


# -----------------------------------------------------------------------------
# 7. Define 204 countries and territories
# -----------------------------------------------------------------------------

data("GBDRegion2021")

gbd_204_country_territory_names <- GBDRegion2021$location

cat(
    "Number of countries and territories in GBDRegion2021: ",
    length(gbd_204_country_territory_names),
    "\n",
    sep = ""
)

if (length(gbd_204_country_territory_names) != 204) {
    warning(
        paste0(
            "GBDRegion2021 contains ",
            length(gbd_204_country_territory_names),
            " locations, not 204. Please check the package version."
        ),
        call. = FALSE
    )
}

write.csv(
    data.frame(location = gbd_204_country_territory_names),
    file = file.path(
        REPRODUCIBLE_OUTPUT_DIR,
        "00_GBD_2021_204_country_territory_list.csv"
    ),
    row.names = FALSE
)


# -----------------------------------------------------------------------------
# 8. Helper function: prepare plot data
# -----------------------------------------------------------------------------

prepare_country_map_plot_data <- function(gbd_data, spec) {
    
    plot_data <- gbd_data %>%
        dplyr::filter(
            cause == GBD_CAUSE,
            measure == spec$measure,
            metric == spec$metric,
            sex == GBD_SEX,
            age == GBD_AGE,
            year == GBD_YEAR,
            location %in% gbd_204_country_territory_names
        )
    
    if (nrow(plot_data) == 0) {
        stop(
            paste0(
                "No data were found for ",
                spec$figure_id,
                ". Please check the GBD download parameters."
            ),
            call. = FALSE
        )
    }
    
    duplicated_locations <- plot_data %>%
        dplyr::count(location) %>%
        dplyr::filter(n > 1)
    
    if (nrow(duplicated_locations) > 0) {
        write.csv(
            duplicated_locations,
            file = file.path(
                CHECK_FILE_DIR,
                paste0(spec$output_file_stem, "_duplicated_locations.csv")
            ),
            row.names = FALSE
        )
        
        stop(
            paste0(
                "Duplicated country/territory rows were found for ",
                spec$figure_id,
                ". Please check the file in 04_data_checks."
            ),
            call. = FALSE
        )
    }
    
    missing_locations <- setdiff(
        gbd_204_country_territory_names,
        unique(plot_data$location)
    )
    
    if (length(missing_locations) > 0) {
        write.csv(
            data.frame(missing_location = missing_locations),
            file = file.path(
                CHECK_FILE_DIR,
                paste0(spec$output_file_stem, "_missing_locations.csv")
            ),
            row.names = FALSE
        )
        
        warning(
            paste0(
                spec$figure_id,
                " contains ",
                dplyr::n_distinct(plot_data$location),
                " countries/territories after filtering, not 204."
            ),
            call. = FALSE
        )
    }
    
    plot_data <- plot_data %>%
        dplyr::mutate(
            figure_id = spec$figure_id,
            abbreviation = spec$abbreviation,
            full_indicator_name = spec$full_indicator_name,
            legend_group = cut(
                val,
                breaks = spec$breaks,
                labels = spec$labels,
                right = FALSE,
                include.lowest = TRUE
            ),
            legend_group = factor(
                legend_group,
                levels = spec$labels
            )
        )
    
    unclassified_values <- plot_data %>%
        dplyr::filter(is.na(legend_group))
    
    if (nrow(unclassified_values) > 0) {
        write.csv(
            unclassified_values,
            file = file.path(
                CHECK_FILE_DIR,
                paste0(spec$output_file_stem, "_unclassified_values.csv")
            ),
            row.names = FALSE
        )
        
        warning(
            paste0(
                "Some values were not classified into legend intervals for ",
                spec$figure_id,
                ". Please check the file in 04_data_checks."
            ),
            call. = FALSE
        )
    }
    
    plot_data_for_reviewers <- plot_data %>%
        dplyr::select(
            dplyr::any_of(c(
                "figure_id",
                "abbreviation",
                "full_indicator_name",
                "location",
                "year",
                "sex",
                "age",
                "cause",
                "measure",
                "metric",
                "val",
                "lower",
                "upper",
                "legend_group"
            ))
        ) %>%
        dplyr::arrange(location)
    
    write.csv(
        plot_data_for_reviewers,
        file = file.path(
            PLOT_DATA_DIR,
            paste0(spec$output_file_stem, "_plot_data_for_reviewers.csv")
        ),
        row.names = FALSE
    )
    
    legend_count_table <- plot_data_for_reviewers %>%
        dplyr::count(legend_group, name = "number_of_countries_or_territories") %>%
        dplyr::arrange(legend_group)
    
    write.csv(
        legend_count_table,
        file = file.path(
            CHECK_FILE_DIR,
            paste0(spec$output_file_stem, "_legend_group_counts.csv")
        ),
        row.names = FALSE
    )
    
    value_range_check <- data.frame(
        figure_id = spec$figure_id,
        abbreviation = spec$abbreviation,
        measure = spec$measure,
        metric = spec$metric,
        number_of_locations = dplyr::n_distinct(plot_data$location),
        minimum_value = min(plot_data$val, na.rm = TRUE),
        maximum_value = max(plot_data$val, na.rm = TRUE),
        stringsAsFactors = FALSE
    )
    
    write.csv(
        value_range_check,
        file = file.path(
            CHECK_FILE_DIR,
            paste0(spec$output_file_stem, "_value_range_check.csv")
        ),
        row.names = FALSE
    )
    
    plot_data
}


# -----------------------------------------------------------------------------
# 9. Helper function: create map
# -----------------------------------------------------------------------------

create_country_map <- function(plot_data, spec) {
    
    map_plot <- ggGBDmap(
        plot_data,
        variable = "legend_group",
        color = MAP_COLOR_SCALE,
        guide_name = NULL
    ) +
        labs(
            fill = NULL,
            color = NULL
        ) +
        theme(
            legend.position = "bottom",
            legend.title = element_blank()
        )
    
    map_plot
}


# -----------------------------------------------------------------------------
# 10. Helper function: save figure outputs
# -----------------------------------------------------------------------------

save_country_map_outputs <- function(map_plot, plot_data, spec) {
    
    pdf_path <- file.path(
        FINAL_FIGURE_DIR,
        paste0(spec$output_file_stem, ".pdf")
    )
    
    tif_path <- file.path(
        FINAL_FIGURE_DIR,
        paste0(spec$output_file_stem, ".tif")
    )
    
    png_path <- file.path(
        FINAL_FIGURE_DIR,
        paste0(spec$output_file_stem, ".png")
    )
    
    rds_path <- file.path(
        R_OBJECT_DIR,
        paste0(spec$output_file_stem, "_ggplot_object.rds")
    )
    
    ggsave(
        filename = pdf_path,
        plot = map_plot,
        width = 12,
        height = 8
    )
    
    ggsave(
        filename = tif_path,
        plot = map_plot,
        width = 12,
        height = 8,
        dpi = 900,
        compression = "lzw"
    )
    
    ggsave(
        filename = png_path,
        plot = map_plot,
        width = 12,
        height = 8,
        dpi = 900
    )
    
    saveRDS(
        map_plot,
        file = rds_path
    )
    
    cat("\nSaved outputs for ", spec$figure_id, ":\n", sep = "")
    cat("  Plot data: ",
        normalizePath(
            file.path(PLOT_DATA_DIR, paste0(spec$output_file_stem, "_plot_data_for_reviewers.csv")),
            winslash = "/",
            mustWork = FALSE
        ),
        "\n",
        sep = ""
    )
    cat("  PDF: ", normalizePath(pdf_path, winslash = "/", mustWork = FALSE), "\n", sep = "")
    cat("  TIFF: ", normalizePath(tif_path, winslash = "/", mustWork = FALSE), "\n", sep = "")
    cat("  PNG: ", normalizePath(png_path, winslash = "/", mustWork = FALSE), "\n", sep = "")
}


# -----------------------------------------------------------------------------
# 11. Generate all maps
# -----------------------------------------------------------------------------

all_plot_data_for_maps <- list()
all_ggplot_map_objects <- list()

for (spec in figure_specs) {
    
    cat("\n============================================================\n")
    cat("Generating ", spec$figure_id, ": ", spec$abbreviation, "\n", sep = "")
    cat("Indicator: ", spec$full_indicator_name, "\n", sep = "")
    cat("Measure: ", spec$measure, "\n", sep = "")
    cat("Metric: ", spec$metric, "\n", sep = "")
    cat("============================================================\n")
    
    country_map_plot_data <- prepare_country_map_plot_data(
        gbd_data = gbd_2021_meningitis_under5_country_data,
        spec = spec
    )
    
    country_map_plot <- create_country_map(
        plot_data = country_map_plot_data,
        spec = spec
    )
    
    save_country_map_outputs(
        map_plot = country_map_plot,
        plot_data = country_map_plot_data,
        spec = spec
    )
    
    all_plot_data_for_maps[[spec$output_file_stem]] <- country_map_plot_data
    all_ggplot_map_objects[[spec$output_file_stem]] <- country_map_plot
}


# -----------------------------------------------------------------------------
# 12. Save R objects and reproducibility information
# -----------------------------------------------------------------------------

saveRDS(
    all_plot_data_for_maps,
    file = file.path(
        R_OBJECT_DIR,
        "all_plot_data_Fig7_SuppFig5_SuppFig6.rds"
    )
)

saveRDS(
    all_ggplot_map_objects,
    file = file.path(
        R_OBJECT_DIR,
        "all_ggplot_objects_Fig7_SuppFig5_SuppFig6.rds"
    )
)

capture.output(
    sessionInfo(),
    file = file.path(
        REPRODUCIBLE_OUTPUT_DIR,
        "00_R_sessionInfo_for_reproducibility.txt"
    )
)

readme_text <- c(
    "Reproducibility files for Figure 7, Supplementary Figure 5, and Supplementary Figure 6",
    "",
    "Input GBD data requirements:",
    "cause   = Meningitis",
    "age     = <5",
    "sex     = Both",
    "year    = 2021",
    "metric  = Rate",
    "measure = YLDs (Years Lived with Disability), Incidence, Deaths",
    "location = 204 countries and territories",
    "",
    "Main output folders:",
    "01_plot_data_for_reviewers: country-level data used for each map",
    "02_final_figures: final PDF, TIFF, and PNG figures",
    "03_r_objects: saved R objects",
    "04_data_checks: missing locations, duplicated locations, legend counts, and value range checks",
    "",
    "Figure-specific output file stems:",
    "Fig7_ASYR_YLDsRate_Meningitis_Under5_204Countries_2021",
    "SuppFig5_ASIR_IncidenceRate_Meningitis_Under5_204Countries_2021",
    "SuppFig6_ASMR_DeathsRate_Meningitis_Under5_204Countries_2021",
    "",
    "Recommended abbreviation definitions:",
    "ASYR, age-specific years-lived-with-disability rate",
    "ASIR, age-specific incidence rate",
    "ASMR, age-specific mortality rate"
)

writeLines(
    readme_text,
    con = file.path(
        REPRODUCIBLE_OUTPUT_DIR,
        "README_reproduce_Fig7_SuppFig5_SuppFig6.txt"
    )
)

cat("\n============================================================\n")
cat("All maps were generated successfully.\n")
cat("Output folder: ",
    normalizePath(REPRODUCIBLE_OUTPUT_DIR, winslash = "/", mustWork = FALSE),
    "\n",
    sep = ""
)
cat("============================================================\n")


# =============================================================================
# End of script
# =============================================================================
