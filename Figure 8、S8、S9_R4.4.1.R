# =============================================================================
# Reproducible code for:
# Figure 8
# Supplementary Figure 8
# Supplementary Figure 9
#
# Etiology-specific ASYR of meningitis among children under 5 years
# and neonatal meningitis, 1990 and 2021
# =============================================================================

# -----------------------------
# 0. Packages
# -----------------------------
library(tidyverse)
library(ggplot2)

# -----------------------------
# 1. User settings
# -----------------------------
# Reviewer only needs to modify these paths.
input_dir  <- "C:/Users/Rensh/Desktop/病原/伤残病原体"
output_dir <- "C:/Users/Rensh/Desktop/病原/Fig8_reproducible_output"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

fig_dir   <- file.path(output_dir, "figures")
data_dir  <- file.path(output_dir, "source_data")
check_dir <- file.path(output_dir, "data_checks")

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(check_dir, recursive = TRUE, showWarnings = FALSE)

# TRUE: 1990 and 2021 use the same x-axis scale.
# FALSE: x-axis scales differ between the two panels.
same_x_axis <- TRUE


# -----------------------------
# 2. Read GBD CSV files
# -----------------------------
# This avoids dependence on non-standard local functions such as GBDread().
read_gbd_folder <- function(folder) {
    csv_files <- list.files(
        folder,
        pattern = "\\.csv$",
        recursive = TRUE,
        full.names = TRUE
    )
    
    if (length(csv_files) == 0) {
        stop("No CSV files were found in input_dir. Please check the input path.")
    }
    
    data <- purrr::map_dfr(
        csv_files,
        ~ readr::read_csv(.x, show_col_types = FALSE)
    )
    
    return(data)
}

df0 <- read_gbd_folder(input_dir)

write.csv(
    df0,
    file.path(data_dir, "raw_merged_GBD_data.csv"),
    row.names = FALSE
)


# -----------------------------
# 3. Required columns check
# -----------------------------
required_cols <- c(
    "location", "year", "measure", "sex",
    "age", "metric", "rei", "val"
)

missing_cols <- setdiff(required_cols, names(df0))

if (length(missing_cols) > 0) {
    stop(
        paste0(
            "The following required columns are missing: ",
            paste(missing_cols, collapse = ", ")
        )
    )
}


# -----------------------------
# 4. Standardize labels
# -----------------------------
df0 <- df0 %>%
    mutate(
        year = as.integer(year),
        rei = recode(
            rei,
            "Other bacterial pathogens" = "Other bacterial pathogen"
        ),
        location = recode(
            location,
            "Democratic Republic of Congo" = "Democratic Republic of the Congo",
            "Guinea Bissau" = "Guinea-Bissau"
        )
    )

if ("cause" %in% names(df0)) {
    if ("Meningitis" %in% unique(df0$cause)) {
        df0 <- df0 %>% filter(cause == "Meningitis")
    }
}

pick_value <- function(x, candidates, item_name) {
    out <- candidates[candidates %in% unique(x)]
    
    if (length(out) == 0) {
        stop(
            paste0(
                "Cannot find ", item_name, ". Candidate values were: ",
                paste(candidates, collapse = ", "),
                ". Please check the data."
            )
        )
    }
    
    out[1]
}

ylds_measure <- pick_value(
    df0$measure,
    candidates = c(
        "YLDs (Years Lived with Disability)",
        "YLDs",
        "YLDs (Years lived with disability)"
    ),
    item_name = "YLDs measure"
)

rate_metric <- pick_value(
    df0$metric,
    candidates = c("Rate", "rate"),
    item_name = "Rate metric"
)

both_sex <- pick_value(
    df0$sex,
    candidates = c("Both", "both"),
    item_name = "Both sex category"
)

age_under5 <- pick_value(
    df0$age,
    candidates = c("<5", "0 to 4", "Under 5", "Under 5 years"),
    item_name = "under-5 age group"
)

age_neonatal <- pick_value(
    df0$age,
    candidates = c("Neonatal", "neonatal"),
    item_name = "neonatal age group"
)


# -----------------------------
# 5. Fixed order of etiologies
# -----------------------------
rei_levels <- c(
    "Neisseria meningitidis",
    "Streptococcus pneumoniae",
    "Klebsiella pneumoniae",
    "Viral etiologies of meningitis",
    "Other bacterial pathogen",
    "Escherichia coli",
    "Group B streptococcus",
    "Haemophilus influenzae",
    "Staphylococcus aureus",
    "Listeria monocytogenes"
)

rei_colors <- c(
    "Neisseria meningitidis"         = "#3182bd",
    "Streptococcus pneumoniae"       = "#9ecae1",
    "Klebsiella pneumoniae"          = "#6baed6",
    "Viral etiologies of meningitis" = "#fd8d3c",
    "Other bacterial pathogen"       = "#fdae6b",
    "Escherichia coli"               = "#fdd0a2",
    "Group B streptococcus"          = "#31a354",
    "Haemophilus influenzae"         = "#c6dbef",
    "Staphylococcus aureus"          = "#a1d99b",
    "Listeria monocytogenes"         = "#74c476"
)


# -----------------------------
# 6. Location order
# -----------------------------
# Figure 8 and Supplementary Figure 9:
# Global + 5 SDI quintiles + 21 GBD regions.
regional_location_levels <- c(
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

# Supplementary Figure 8:
# 15 countries with the largest effective ASYR difference from the frontier.
frontier15_country_levels <- c(
    "Uganda",
    "South Sudan",
    "Sierra Leone",
    "Nigeria",
    "Mozambique",
    "Malawi",
    "Guinea-Bissau",
    "Guinea",
    "Ethiopia",
    "Democratic Republic of the Congo",
    "Comoros",
    "Chad",
    "Central African Republic",
    "Cameroon",
    "Benin"
)


# -----------------------------
# 7. Theme
# -----------------------------
theme_asy_bar <- function() {
    theme_bw(base_size = 8) +
        theme(
            strip.background = element_blank(),
            strip.text = element_text(size = 9, face = "bold"),
            axis.title.x = element_text(size = 9),
            axis.title.y = element_blank(),
            axis.text.x = element_text(size = 8),
            axis.text.y = element_text(size = 7),
            legend.position = "top",
            legend.title = element_text(size = 8),
            legend.text = element_text(size = 7),
            legend.key.size = unit(0.25, "cm"),
            legend.margin = margin(b = 2),
            panel.grid.major.y = element_blank(),
            panel.grid.minor = element_blank(),
            plot.title = element_text(size = 10, face = "bold", hjust = 0.5)
        )
}


# -----------------------------
# 8. Prepare plotting data
# -----------------------------
prepare_asy_data <- function(data, age_group, location_levels, figure_name) {
    
    plot_data <- data %>%
        filter(
            year %in% c(1990, 2021),
            measure == ylds_measure,
            metric == rate_metric,
            sex == both_sex,
            age == age_group,
            location %in% location_levels,
            rei %in% rei_levels
        ) %>%
        group_by(year, location, rei) %>%
        summarise(
            val = sum(val, na.rm = TRUE),
            .groups = "drop"
        ) %>%
        mutate(
            year = factor(year, levels = c(1990, 2021)),
            location = factor(location, levels = rev(location_levels)),
            rei = factor(rei, levels = rei_levels)
        ) %>%
        tidyr::complete(
            year,
            location,
            rei,
            fill = list(val = 0)
        )
    
    if (nrow(plot_data) == 0) {
        stop(paste0("No plotting data were found for ", figure_name, "."))
    }
    
    missing_locations <- setdiff(location_levels, unique(as.character(plot_data$location)))
    
    if (length(missing_locations) > 0) {
        write.csv(
            data.frame(missing_location = missing_locations),
            file.path(
                check_dir,
                paste0(gsub("[^A-Za-z0-9]+", "_", figure_name), "_missing_locations.csv")
            ),
            row.names = FALSE
        )
    }
    
    total_check <- plot_data %>%
        group_by(year, location) %>%
        summarise(
            total_ASYR = sum(val, na.rm = TRUE),
            .groups = "drop"
        )
    
    write.csv(
        total_check,
        file.path(
            check_dir,
            paste0(gsub("[^A-Za-z0-9]+", "_", figure_name), "_total_ASYR_check.csv")
        ),
        row.names = FALSE
    )
    
    return(plot_data)
}


# -----------------------------
# 9. Plotting function
# -----------------------------
make_stacked_asy_plot <- function(data,
                                  age_group,
                                  location_levels,
                                  figure_name,
                                  x_lab,
                                  output_prefix,
                                  width = 12,
                                  height = 8) {
    
    plot_data <- prepare_asy_data(
        data = data,
        age_group = age_group,
        location_levels = location_levels,
        figure_name = figure_name
    )
    
    write.csv(
        plot_data,
        file.path(data_dir, paste0(output_prefix, "_source_data.csv")),
        row.names = FALSE
    )
    
    facet_scales <- ifelse(same_x_axis, "fixed", "free_x")
    
    p <- ggplot(
        plot_data,
        aes(x = val, y = location, fill = rei)
    ) +
        geom_col(width = 0.72) +
        facet_wrap(
            ~ year,
            ncol = 2,
            scales = facet_scales
        ) +
        scale_fill_manual(
            values = rei_colors,
            breaks = rei_levels,
            drop = FALSE,
            name = "Etiology"
        ) +
        scale_x_continuous(
            expand = expansion(mult = c(0, 0.04))
        ) +
        guides(
            fill = guide_legend(
                nrow = 2,
                byrow = TRUE
            )
        ) +
        labs(
            title = figure_name,
            x = x_lab,
            y = NULL
        ) +
        theme_asy_bar()
    
    ggsave(
        filename = file.path(fig_dir, paste0(output_prefix, ".pdf")),
        plot = p,
        width = width,
        height = height,
        units = "in",
        dpi = 300
    )
    
    ggsave(
        filename = file.path(fig_dir, paste0(output_prefix, ".tiff")),
        plot = p,
        width = width,
        height = height,
        units = "in",
        dpi = 300,
        compression = "lzw"
    )
    
    ggsave(
        filename = file.path(fig_dir, paste0(output_prefix, ".png")),
        plot = p,
        width = width,
        height = height,
        units = "in",
        dpi = 300
    )
    
    return(p)
}


# -----------------------------
# 10. Generate figures
# -----------------------------

# Figure 8:
# Under-5 meningitis ASYR by etiology across GBD regions and SDI quintiles.
fig8 <- make_stacked_asy_plot(
    data = df0,
    age_group = age_under5,
    location_levels = regional_location_levels,
    figure_name = "Figure 8",
    x_lab = "ASYR per 100,000 population",
    output_prefix = "Figure_8_under5_ASYR_by_etiology_region_1990_2021",
    width = 12,
    height = 8
)

# Supplementary Figure 8:
# Under-5 meningitis ASYR by etiology in the 15 countries with the largest
# effective ASYR difference from the frontier.
supp_fig8 <- make_stacked_asy_plot(
    data = df0,
    age_group = age_under5,
    location_levels = frontier15_country_levels,
    figure_name = "Supplementary Figure 8",
    x_lab = "ASYR per 100,000 population",
    output_prefix = "Supplementary_Figure_8_under5_ASYR_frontier15_by_etiology_1990_2021",
    width = 12,
    height = 8
)

# Supplementary Figure 9:
# Neonatal meningitis ASYR by etiology across GBD regions and SDI quintiles.
supp_fig9 <- make_stacked_asy_plot(
    data = df0,
    age_group = age_neonatal,
    location_levels = regional_location_levels,
    figure_name = "Supplementary Figure 9",
    x_lab = "Neonatal ASYR per 100,000 population",
    output_prefix = "Supplementary_Figure_9_neonatal_ASYR_by_etiology_region_1990_2021",
    width = 12,
    height = 8
)


# -----------------------------
# 11. Export figure specification and session info
# -----------------------------
figure_spec <- tibble::tribble(
    ~figure, ~age_group, ~measure, ~metric, ~sex, ~locations,
    "Figure 8",
    age_under5,
    ylds_measure,
    rate_metric,
    both_sex,
    "Global, SDI quintiles, and 21 GBD regions",
    
    "Supplementary Figure 8",
    age_under5,
    ylds_measure,
    rate_metric,
    both_sex,
    "15 countries with the largest effective ASYR difference from the frontier",
    
    "Supplementary Figure 9",
    age_neonatal,
    ylds_measure,
    rate_metric,
    both_sex,
    "Global, SDI quintiles, and 21 GBD regions"
)

write.csv(
    figure_spec,
    file.path(data_dir, "figure_specification.csv"),
    row.names = FALSE
)

sink(file.path(output_dir, "sessionInfo.txt"))
print(sessionInfo())
sink()

readme_text <- c(
    "Reproducible output for Figure 8, Supplementary Figure 8, and Supplementary Figure 9.",
    "",
    "Input data:",
    paste0("input_dir = ", normalizePath(input_dir, winslash = "/", mustWork = FALSE)),
    "",
    "Filters:",
    paste0("measure = ", ylds_measure),
    paste0("metric = ", rate_metric),
    paste0("sex = ", both_sex),
    "years = 1990 and 2021",
    "",
    "Figure 8:",
    "Under-5 meningitis ASYR by etiology across Global, SDI quintiles, and 21 GBD regions.",
    "",
    "Supplementary Figure 8:",
    "Under-5 meningitis ASYR by etiology in the 15 countries with the largest effective ASYR difference from the frontier.",
    "",
    "Supplementary Figure 9:",
    "Neonatal meningitis ASYR by etiology across Global, SDI quintiles, and 21 GBD regions.",
    "",
    "Note:",
    ifelse(
        same_x_axis,
        "The 1990 and 2021 panels use the same x-axis scale.",
        "The 1990 and 2021 panels use different x-axis scales."
    )
)

writeLines(
    readme_text,
    con = file.path(output_dir, "README_reproduce_Fig8_SuppFig8_SuppFig9.txt")
)

cat("Finished.\n")
cat("Figures saved to: ", fig_dir, "\n")
cat("Source data saved to: ", data_dir, "\n")
cat("Data checks saved to: ", check_dir, "\n")
