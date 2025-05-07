library(dplyr)
library(tidycensus)
library(readr)
library(forcats)

# Convert FIPS state codes to state abbreviations
add_state_abbreviations <- function(df) {
    fips_to_state <- tidycensus::fips_codes %>%
        select(state, state_code) %>%
        distinct() %>%
        mutate(state_code = as.numeric(state_code))
    
    df %>%
        rename(state_code = st) %>%
        left_join(fips_to_state, join_by(state_code))
}


# Add census region based on state abbreviation
add_region <- function(df) {
    northeast_states <- c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA")
    midwest_states   <- c("IL", "IN", "MI", "OH", "WI", "IA", "KS", "MN", "MO", "NE", "ND", "SD")
    south_states     <- c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "DC", "WV",
                          "AL", "KY", "MS", "TN", "AR", "LA", "OK", "TX")
    west_states      <- c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "AK",
                          "CA", "HI", "OR", "WA")
    
    df %>%
        mutate(region = case_when(
            state %in% northeast_states ~ "Northeast",
            state %in% midwest_states   ~ "Midwest",
            state %in% south_states     ~ "South",
            state %in% west_states      ~ "West",
            TRUE ~ NA_character_
        ))
}


# Convert coded variables to factors with labels
apply_factor_labels <- function(df) {
    
    # Specify these here cause its too long and annoys me.
    # level 0 is "Not in universe" according to data dictionary, include it as NA. 
    edu_labels <- c(NA, "Less than a HS degree", "HS degree", "Some college", "College degree")
    
    df %>%
        mutate(
            education = factor(education,  levels = 0:4, labels = edu_labels, exclude = NULL),
            sex = factor(sex, levels = 1:2, labels = c("male", "female")),
            race = factor(race, levels = 1:4, labels = c("white", "black", "asian", "other")),
            #mar = factor(mar, levels = 1:5, labels = c("married", "widowed", "divorced", "separated", "never married")),
            region = factor(region)
        )
}


# Perform stratified sampling across multiple categorical variables
stratified_sample <- function(df, cat_columns, prop = 0.2) {
    df %>%
        group_by(across(all_of(cat_columns))) %>%
        slice_sample(prop = prop) %>%
        ungroup()
}


load_and_install_packages <- function(packages) {
    for (pkg in packages) {
        if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
            install.packages(pkg, repos = "https://cran.rstudio.com/")
            library(pkg, character.only = TRUE)
        }
    }
}

# This function allows us to get a list of columns within a dummy variable using regex
# Cause this is really annoying to do over and over again
extract_dummies <- function(names) {
    
}


load_final_dataset <- function(prop=0.005) {
    # Seed represents the 100% speedrun of Baten Kaitos which took 338 hours, 43 minutes and 26 seconds
    set.seed(3384326)
    
    # Used for stratified sampling 
    cat_columns <- c("hispanic", "spm_poor", "sex", "education", "race", "region", "married")
    
    # Used for dummy variable creation
    factor_columns <- setdiff(cat_columns, c("hispanic", "spm_poor", "married"))
    
    df <- readr::read_csv("../data/poverty_data.csv.gz") %>%
        # --- SOME DATA CLEANING HERE ---
        # turn mar into 0/1 married or not married to make use of unbalanced categories
        mutate(married = (mar == 1) + 0) %>%
        add_state_abbreviations() %>%
        add_region() %>%
        # Remove NA education rows
        filter(education != 0) %>%
        apply_factor_labels() %>%
        select(-c(state, state_code, wt, mar)) %>%
        # --- SCALE NUMERIC COLUMNS ---
        mutate(
            agi = scale(agi),
            spm_povthreshold = scale(spm_povthreshold)
        ) %>%
        # --- STRATIFICATION AND DUMMY VARIABLE CREATION ---
        stratified_sample(cat_columns = cat_columns, prop=0.005) %>%
        # Save dummies for after stratification as they greatly increase dimensionality
        fastDummies::dummy_cols(
            select_columns = factor_columns,
            remove_selected_columns = TRUE,
            remove_first_dummy = TRUE,
            ignore_na = TRUE
        ) %>%
        clean_names() %>%
        select(-c(sex_female, hispanic, moop_other, hi_premium, age))
}