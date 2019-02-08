## ---------------------------
##
## Script name: factsheet-data.R
##
## Purpose of script: Get the data we need for the Sheffield Factsheet   
##
## Author: Laurie Platt
##
## Date Created: 2018-12-12
##
## Email: laurie.platt@sheffield.gov.uk
##
## ---------------------------
##
## Notes:
##  1. TODO(Laurie): Complete notes
##
## ---------------------------

# A suite of useful functions
library(tidyverse)

# Not core tidyverse
library(httr) ; library(jsonlite)

# Not part of the tidyverse
library(writexl)

# Load functions from another script in the project
source("libraries/ons-datasets-beta.R")

ExplorePopEstimateAPI <- function(latest_version_href){
  # Description:  Get the dimensions of an ONS dataset.
  #
  # Args:
  #   latest_version_href:  Needs to be a value in the "items.links.latest_version.href"
  #                         column that's returned from getListOfONSBetaDatasets().
  # Returns:
  #   Tibble describing the dimensions of the ONS dataset if successful
  
  # I want to use the mid-year population estimates
  # for the "People" section of the factsheet.
  # So I need to explore the API using the URL from
  # the "items.links.latest_version.href" column.
  latest_version_href <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2"
  
  # What are the API dimensions (parameters) for this dataset?
  dimensions_tib = GetDimensions(latest_version_href)
  View(dimensions_tib)
  
  # What are the options (possible parameter values)?
  options_tib = GetDimensionsAndOptions(latest_version_href)
  View(options_tib)
}  

GetPeopleData <- function(){
  # Description:  Get and summarise the Mid Year Population Estimate from ONS.
  #
  # Args:
  #   latest_version_href:  Needs to be a value in the "items.links.latest_version.href"
  #                         column that's returned from getListOfONSBetaDatasets().
  # Returns:
  #   Tibble with summarised Mid Year Population Estimate data

  # # What datasets are available via the ONS beta API?
  # all_ons_tib = GetListOfONSBetaDatasets()
  # View(all_ons_tib)
  
  # # Uncomment if you want to export it to a spreadsheet in the project directory
  # write_xlsx(all_ons_tib, "ONS_Datasets_Beta.xlsx")
  
  # I want to use the mid-year population estimates
  # for the "People" section of the factsheet.
  # To do this I need the URL from the "items.links.latest_version.href" column.
  latest_version_href <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2"
  #TODO(Laurie Platt): Get latest version href
  
  # # What are the API dimensions (parameters) and
  # # options (possible parameter values) for this dataset API?
  # ExplorePopEstimateAPI(latest_version_href)
  
  # The first part of the request for the observations (dataset)
  observations_href <- paste(latest_version_href, "/observations", sep="")
  
  # By looking at the dimensions and options tibble
  # we can create a set of variables for the second
  # part of the request

  sex_all = 0
  sex_male = 1
  sex_female = 2
  sheffield_code = "E08000019"
  latest_year_option = 2016
  ages_all = "*"  # One dimension value can be replaced by a wildcard
  
  # **Get the total male population of Sheffield**
  # Build our query as a list
  male_query_list <- list(
    time = latest_year_option,
    geography = sheffield_code,
    sex = 0,
    age = ages_all)

  # Make the request
  male_sheff_pop <- GetONSBetaTibble(observations_href, male_query_list)
  # View(male_sheff_pop)

  # Some re-organisation of the tibble
  male_sheff_pop_prep <- male_sheff_pop %>%
    select(people = observations.observation) %>%
    sapply(as.numeric) %>%  # Coerce columns to type numeric
    as.tibble()

  # Do the sum
  total_male_pop <- sum(male_sheff_pop_prep$people)
  print(toString(total_male_pop))
  
  # Build our query as a list
  query_list <- list(
              time = latest_year_option,
              geography = sheffield_code,
              sex = sex_all,
              age = ages_all)
  
  # Make the request
  sheff_pop <- GetONSBetaTibble(observations_href, query_list)
  View(sheff_pop)

  # Some re-organisation of the tibble
  sheff_pop_prep <- sheff_pop %>%
    select(people = observations.observation, age = observations.dimensions.Age.id) %>%
    sapply(as.numeric) %>%  # Coerce columns to type numeric
    as.tibble() %>% # Coerce to tibble
    mutate(group = "") %>% # New column to include group labels
    mutate(order = 0) # New column to order the rows

  # TODO(Laurie Platt): **Total Population
  total_pop <- sum(sheff_pop_prep$people)
    
  # TODO(Laurie Platt): Ensure that the tibble is ordered by age,
  #                     ready for the loop
  
  # TODO(Laurie Platt): Use Factors() instead of strings for the group column
  #                     and to do without order column
  
  # View(sheff_pop_prep)
  
  # Prep some variables for the loop
  age_counter <- 0
  ages_interval <- 5
  age_group <- ""
  order <- 0
  over_75_flag <- FALSE

  # TODO(Laurie Platt): **Percentage ages
  
  # Loop through each row in the pop tibble
  for (i in 1:nrow(sheff_pop_prep)) {
  
    # Resest age counter to allow us to
    # label age groups spanning 5 years
    if (age_counter > 4) {
      age_counter <- 0
      age_group <- ""
    }
    
    # Cater for missing age values
    if (is.na(sheff_pop_prep[i, 2])) {
      is.na <- age_group
    }
    else {
      
      # Get the age value as a number
      age <- as.integer(sheff_pop_prep[i, 2])
    
      # Create an age group label for 75 and over
      if (age > 74) {
        if (!over_75_flag) {
          age_group <- "Residents aged 75 and over"  
          order <- order + 1
          over_75_flag <- TRUE
        }
      }
      # Create 5 year age group labels
      else { 
        
        # Create a new 5 year age group label
        if (age_counter == 0) {
        
        # One label per group
        age_group <- age_group %>%
          paste("Residents aged ", sep="") %>% 
          paste(toString(sheff_pop_prep[i, 2]), sep="") %>%
          paste(" to ") %>% 
          paste(toString((sheff_pop_prep[i, 2]) + ages_interval - 1), sep="")
        
        # One order value per group
        order <- order + 1
        }
        
        # This increment is for the 5 year age groupings
        age_counter <- age_counter + 1
      }
    
    # Insert to the age group label
    sheff_pop_prep[i, 3] <- age_group
    
    # Insert the order of the age group label
    sheff_pop_prep[i, 4] <- order
    }
  }
    
  by_age_group <- sheff_pop_prep %>%
    select(-age) %>% 
    group_by(group, order)
  # View(by_age_group)
  
  by_age_group <- by_age_group %>% 
    summarise(people = sum(people)) %>% 
    arrange(order, .by_group = FALSE) %>%  #TODO(Laurie Platt): Is this needed? Check after markdown
    select(-order)
    # View(by_age_group)
  
  # TODO(Laurie Platt): **Filter out NA  
  # TODO(Laurie Platt): **Total Males 
  # TODO(Laurie Platt): **Total Females
  
  return (by_age_group)
}

tib <- GetPeopleData()
View(tib)