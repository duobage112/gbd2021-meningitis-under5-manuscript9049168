# ==============================================================================
# REPRODUCTION SCRIPT FOR BAPC PREDICTION (1990-2021 to 2022-2045)
# Target Population: Age group 0-4 years (Both sexes)
# ==============================================================================

# ------------------------------------------------------------------------------
# [Step 1] Environment Setup & Package Dependencies
# ------------------------------------------------------------------------------
# Please ensure the 'gR' package and its dependencies are installed before running.
# If 'gR' is not installed, please follow the developer's instructions or run:
# remotes::install_github("username/gR") # Replace with the correct repository path if needed
#Data Availability & Replication Note for Reviewers:
    
#To replicate the prediction results and figures presented in the manuscript, please retrieve the raw dataset from the Global Health Data Exchange (GHDx) registry (https://ghdx.healthdata.org/gbd-2021-data-input-sources) using the following specifications:
    
#File 1 (Deaths & Incidence Data):
    
# Context / Tool: GBD Results Tool

#Cause: Meningitis (B.1.1)

#Measure: Deaths, Incidence

#Metric: Number, Rate

#Location: Global, South Asia, Oceania, and Sub-Saharan African regions.

#Age / Sex: All age groups (5-year intervals), Both sexes.

#Year: 1990–2021.

#Save as: GBD2021_Meningitis_All_Ages_Deaths_Incidence.csv

#File 2 (YLDs Data):
    
#Measure: YLDs (Years Lived with Disability)

#Location: 21 GBD Regions + Global

#Save as: GBD2021_Meningitis_All_Ages_YLDs_5YearIntervals.csv

#Place these two .csv files into the same directory as the R script and run the script. It will automatically generate Table_Predicted_Meningitis_Data_0_4_AgeGroup.xlsx and the full vector PDF figures.
library(gR)
library(tidyverse)
library(writexl)
library(openxlsx)
library(ggplot2)

# Set your working directory to the folder containing this script and the data files
# Example: setwd("path/to/your/reproduction_folder")
# For peer-review convenience, we assume all files are in the current working directory.

# Initialize/Verify BAPC standalone package dependencies
bapc_install_pkg()

# Define Global Prediction Configuration
PRED_YEARS <- 24  # Historical (1990-2021) -> Projection (2022-2045)

# ------------------------------------------------------------------------------
# [Step 2] Data Loading Notes for Reviewers
# ------------------------------------------------------------------------------
# The raw datasets are extracted from the Global Burden of Disease (GBD) 2021 Study 
# via the Global Health Data Exchange (GHDx) registry (https://ghdx.healthdata.org/).
#
# File 1 (Deaths & Incidence): 
#   - Name: "GBD2021_Meningitis_All_Ages_Deaths_Incidence.csv"
#   - Content: Number & Rate for Deaths and Incidence, all age groups, Both sexes.
# File 2 (YLDs): 
#   - Name: "GBD2021_Meningitis_All_Ages_YLDs_5YearIntervals.csv"
#   - Content: Number & Rate for YLDs, 5-year age intervals, Both sexes.

DATA_PATH_DEATH_INC <- "GBD2021_Meningitis_All_Ages_Deaths_Incidence.csv"
DATA_PATH_YLDS      <- "GBD2021_Meningitis_All_Ages_YLDs_5YearIntervals.csv"

# ------------------------------------------------------------------------------
# [Step 3] Pipeline I: Deaths Analysis & Projection
# ------------------------------------------------------------------------------
message("Processing Deaths Data...")
df_deaths <- read_GBD(DATA_PATH_DEATH_INC)

df_deaths <- select_metric(df_deaths, "Number", "Rate", "---ignore---")
df_deaths <- select_measure(df_deaths, "Deaths", "---ignore---")
df_deaths <- select_location(df_deaths,
                             "1-->Global",
                             "159-->South Asia",
                             "21-->Oceania",
                             "167-->Central Sub-Saharan Africa",
                             "174-->Eastern Sub-Saharan Africa",
                             "199-->Western Sub-Saharan Africa",
                             "----ignore----")
df_deaths <- select_year(df_deaths, "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","---ignore---")
df_deaths <- select_age(df_deaths, "<5 years::","5-9 years::","10-14 years::","15-19 years::","20-24 years::","25-29 years::","30-34 years::","35-39 years::","40-44 years::","45-49 years::","50-54 years::","55-59 years::","60-64 years::","65-69 years::","70-74 years::","75-79 years::","80-84 years::","85-89 years::","90-94 years::","95+ years::","---ignore---")
df_deaths <- select_sex(df_deaths, "Both", "---ignore---")

res_deaths <- bapc(df_deaths, nyears = PRED_YEARS, drop0number = FALSE)
res_deaths_df <- res_deaths$agespec_rate

# ------------------------------------------------------------------------------
# [Step 4] Pipeline II: Incidence Analysis & Projection
# ------------------------------------------------------------------------------
message("Processing Incidence Data...")
df_inc <- read_GBD(DATA_PATH_DEATH_INC)

df_inc <- select_metric(df_inc, "Number", "Rate", "---ignore---")
df_inc <- select_measure(df_inc, "Incidence", "---ignore---")
df_inc <- select_location(df_inc,
                          "1-->Global",
                          "159-->South Asia",
                          "21-->Oceania",
                          "167-->Central Sub-Saharan Africa",
                          "174-->Eastern Sub-Saharan Africa",
                          "199-->Western Sub-Saharan Africa",
                          "----ignore----")
df_inc <- select_year(df_inc, "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","---ignore---")
df_inc <- select_age(df_inc, "<5 years::","5-9 years::","10-14 years::","15-19 years::","20-24 years::","25-29 years::","30-34 years::","35-39 years::","40-44 years::","45-49 years::","50-54 years::","55-59 years::","60-64 years::","65-69 years::","70-74 years::","75-79 years::","80-84 years::","85-89 years::","90-94 years::","95+ years::","---ignore---")
df_inc <- select_sex(df_inc, "Both", "---ignore---")

res_inc <- bapc(df_inc, nyears = PRED_YEARS, drop0number = FALSE)
res_inc_df <- res_inc$agespec_rate

# ------------------------------------------------------------------------------
# [Step 5] Pipeline III: YLDs Analysis & Projection
# ------------------------------------------------------------------------------
message("Processing YLDs Data...")
df_ylds <- read_GBD(DATA_PATH_YLDS)

df_ylds <- select_metric(df_ylds, "Number", "Rate", "---ignore---")
df_ylds <- select_measure(df_ylds, "YLDs", "---ignore---")
df_ylds <- select_location(df_ylds,
                           "1-->Global",
                           "138-->North Africa and Middle East",
                           "159-->South Asia",
                           "32-->Central Asia",
                           "42-->Central Europe",
                           "56-->Eastern Europe",
                           "70-->Australasia",
                           "65-->High-income Asia Pacific",
                           "100-->High-income North America",
                           "96-->Southern Latin America",
                           "73-->Western Europe",
                           "120-->Andean Latin America",
                           "104-->Caribbean",
                           "124-->Central Latin America",
                           "134-->Tropical Latin America",
                           "5-->East Asia",
                           "21-->Oceania",
                           "9-->Southeast Asia",
                           "167-->Central Sub-Saharan Africa",
                           "174-->Eastern Sub-Saharan Africa",
                           "192-->Southern Sub-Saharan Africa",
                           "199-->Western Sub-Saharan Africa",
                           "----ignore----")
df_ylds <- select_year(df_ylds, "1990","1991","1992","1993","1994","1995","1996","1997","1998","1999","2000","2001","2002","2003","2004","2005","2006","2007","2008","2009","2010","2011","2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","---ignore---")
df_ylds <- select_age(df_ylds, "<5 years::","5-9 years::","10-14 years::","15-19 years::","20-24 years::","25-29 years::","30-34 years::","35-39 years::","40-44 years::","45-49 years::","50-54 years::","55-59 years::","60-64 years::","65-69 years::","70-74 years::","75-79 years::","80-84 years::","85-89 years::","90-94 years::","95+ years::","---ignore---")
df_ylds <- select_sex(df_ylds, "Both", "---ignore---")

res_ylds <- bapc(df_ylds, nyears = PRED_YEARS, drop0number = FALSE)
res_ylds_df <- res_ylds$agespec_rate


# ------------------------------------------------------------------------------
# [Step 6] Data Integration and Excel Export (0-4 Age Group)
# ------------------------------------------------------------------------------
message("Integrating and Exporting Predicted Data...")

# Subset to extract 0-4 age categories across all pipelines
res0_deaths_sub <- subset(res_deaths_df, age %in% c("0-4", "0 to 4")) %>% mutate(measure = "Deaths")
res0_inc_sub    <- subset(res_inc_df,    age %in% c("0-4", "0 to 4")) %>% mutate(measure = "Incidence")
res0_ylds_sub   <- subset(res_ylds_df,   age %in% c("0-4", "0 to 4")) %>% mutate(measure = "YLDs")

# Combine into a master dataframe
res0_all <- bind_rows(res0_deaths_sub, res0_inc_sub, res0_ylds_sub)

# Clean numeric values to 2 decimal places for presentation
res0_export <- as.data.frame(lapply(res0_all, function(x) if(is.numeric(x)) round(x, 2) else x))

# Save output file with a structured, clear academic name
write_xlsx(list(res0_prediction = res0_export), path = "Table_Predicted_Meningitis_Data_0_4_AgeGroup.xlsx")


# ------------------------------------------------------------------------------
# [Step 7] Visualization Engine (9-layer Fan/Ribbon Plot)
# ------------------------------------------------------------------------------
fill_col <- "#00008B"
point_col  <- "#040404"
alpha_levels <- seq(0.4, 0.05, length.out = 9)

plot_bapc_ribbon <- function(data_sub, title_name) {
    ggplot(data_sub, aes(x = year)) +
        geom_ribbon(aes(ymin = x_0.45Q, ymax = x_0.55Q), fill = fill_col, alpha = alpha_levels[1]) +
        geom_ribbon(aes(ymin = x_0.4Q,  ymax = x_0.6Q),  fill = fill_col, alpha = alpha_levels[2]) +
        geom_ribbon(aes(ymin = x_0.35Q, ymax = x_0.65Q), fill = fill_col, alpha = alpha_levels[3]) +
        geom_ribbon(aes(ymin = x_0.3Q,  ymax = x_0.7Q),  fill = fill_col, alpha = alpha_levels[4]) +
        geom_ribbon(aes(ymin = x_0.25Q, ymax = x_0.75Q), fill = fill_col, alpha = alpha_levels[5]) +
        geom_ribbon(aes(ymin = x_0.2Q,  ymax = x_0.8Q),  fill = fill_col, alpha = alpha_levels[6]) +
        geom_ribbon(aes(ymin = x_0.15Q, ymax = x_0.85Q), fill = fill_col, alpha = alpha_levels[7]) +
        geom_ribbon(aes(ymin = x_0.1Q,  ymax = x_0.9Q),  fill = fill_col, alpha = alpha_levels[8]) +
        geom_ribbon(aes(ymin = x_0.05Q, ymax = x_0.95Q), fill = fill_col, alpha = alpha_levels[9]) +
        geom_line(aes(y = x_0.5Q), color = fill_col, linewidth = 1.1) +
        labs(title = title_name, x = "Year", y = "Age-Specific Rate (per 100,000)") +
        theme_bw(base_size = 10) +
        geom_point(aes(y = x_0.5Q), shape = 16, size = 1.6, color = point_col) +
        theme(
            plot.title = element_text(size = 11, face = "bold", hjust = 0.5),
            axis.text = element_text(size = 9, color = "black"),
            axis.title = element_text(size = 10),
            panel.grid.major = element_line(color = "grey85", linewidth = 0.3),
            panel.grid.minor = element_blank(),
            legend.position = "none",
            plot.margin = margin(10, 10, 10, 10)
        )
}

# ------------------------------------------------------------------------------
# [Step 8] Batch Figure Generation & Academic File Export
# ------------------------------------------------------------------------------
message("Generating Figures...")

# Mapping list for structured filenames
target_locations <- list(
    "Western Sub-Saharan Africa" = "Western_Sub_Saharan_Africa",
    "Oceania"                    = "Oceania",
    "Central Sub-Saharan Africa" = "Central_Sub_Saharan_Africa",
    "Eastern Sub-Saharan Africa" = "Eastern_Sub_Saharan_Africa",
    "South Asia"                 = "South_Asia",
    "Global"                     = "Global"
)

# 1. Output Figures for Incidence
for (loc in names(target_locations)) {
    df_plot <- subset(res0_inc_sub, location == loc)
    if(nrow(df_plot) > 0) {
        p <- plot_bapc_ribbon(df_plot, loc)
        ggsave(paste0("Figure_Incidence_", target_locations[[loc]], "_Under5.pdf"), plot = p, width = 6, height = 6, dpi = 900)
    }
}

# 2. Output Figures for Deaths
for (loc in names(target_locations)) {
    df_plot <- subset(res0_deaths_sub, location == loc)
    if(nrow(df_plot) > 0) {
        p <- plot_bapc_ribbon(df_plot, loc)
        ggsave(paste0("Figure_Deaths_", target_locations[[loc]], "_Under5.pdf"), plot = p, width = 6, height = 6, dpi = 900)
    }
}

# 3. Output Figures for YLDs
for (loc in names(target_locations)) {
    df_plot <- subset(res0_ylds_sub, location == loc)
    if(nrow(df_plot) > 0) {
        p <- plot_bapc_ribbon(df_plot, loc)
        # Special nomenclature handler for Global/Regional consistency if required
        # Keeping the original conditional filename logic but making it reviewer-friendly:
        suffix <- if(loc == "Global") "" else "_Under5"
        ggsave(paste0("Figure_YLDs_", target_locations[[loc]], suffix, ".pdf"), plot = p, width = 6, height = 6, dpi = 900)
    }
}

message("All tasks completed successfully. Output files and figures are ready for review.")