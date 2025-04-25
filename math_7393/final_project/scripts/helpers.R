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