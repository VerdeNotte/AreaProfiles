## ---------------------------
##
## Script name: ons-pop-estimates.R
##
## Purpose of script: Get ONS population estimates
##
## Author: Laurie Platt
##
## Date Created: 2018-12-13
##
## Email: laurie.platt@sheffield.gov.uk
##
## ---------------------------
##
## Notes:
##  1. TODO(Laurie Platt): complete
##  2. TODO(Laurie Platt): do the same but use the ‘Filter a dataset’ service
##     which supports the front end user journeys for CMD
##
## ---------------------------

# A suite of useful functions
library(tidyverse) ; 

# Not core tidyverse
library(httr) ; library(jsonlite)

# Load the functions from another script in the project
source("ons-datasets-beta.R")

# The first part of the request for the mid-year population
# estimate dataset is a URL to the API endpoint 
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2/observations"
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions"
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2"
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2/observations?time=*&aggregate=*&geography=E08000019"
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2/dimensions"
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2/observations?time=2016&geography=E08000019&sex=0&age=*"


# Check the editions
# editions_path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions"
# editions_tib <- getONSTibble(editions_path)
# # TODO(Laurie Platt): Check assumption that only one row is returned
# latest_version <- select(editions_tib, items.links.latest_version.id)[[1,1]]

# # The first part of the request for the mid-year population
# # estimate dataset is a URL to the API endpoint 
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2/observations"
# path <- "https://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2"



# # Create a few variables for the request options
# sex_all = 0
# sex_male = 1
# sex_female = 2
# sheffield_code = "E08000019"
# latest_year_option = 2016
# ages_all = "*"  # One dimension value can be replaced by a wildcard  
# 
# # # The second part of the request is a query
# # # containing the parameters of the request 
# request <- GET(url = path,
#                query = list(
#                         time = latest_year_option,
#                         geography = sheffield_code,
#                         sex = sex_all,
#                         age = ages_all)
# )

# versions?
# dimensions?
# time?

# # Check the status of the last HTTP response 
# http_status_code <- request$status_code
# 
# # A non-200 code means the request has failed
# if (http_status_code != 200) {
#   
#   # Provide some feedback
#   print("Population estimate dataset not returned!", quote = FALSE)
#   
# } else { 
#   
#   # Parse the content returned from the server as text
#   response <- content(request, as = "text", encoding = "UTF-8")
#   
#   # Parse the JSON content and convert it to a data frame
#   df <- fromJSON(response, flatten = TRUE) %>% 
#     data.frame()
#   
#   # Coerce the dataframe to a tibble
#   tib <- as_tibble(df)
# }