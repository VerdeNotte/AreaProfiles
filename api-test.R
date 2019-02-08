## ---------------------------
##
## Script name: api-test.R
##
## Purpose of script: fix problem connecting to ONS API from Council internet   
##
## Author: Laurie Platt
##
## Date Created: 2018-12-21
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
library(tidyverse) ; 

# Not core tidyverse
library(httr) ; library(jsonlite)

# Not part of the tidyverse
# library(writexl)

# Load functions from another script in the project
source("libraries/ons-datasets-beta.R")

# # Open the /Renviron file
# file.edit('~/.Renviron')

# Test ONS API call
path <- "http://api.beta.ons.gov.uk/v1/datasets/mid-year-pop-est/editions/time-series/versions/2/dimensions"
dimensions_tib = GetONSBetaTibble(path)
View(dimensions_tib)

# # Test Police data API call
# path <- "https://data.police.uk/api/crimes-street/burglary?"
# list(
#   lat = 53.421813,
#   lng = -2.330251,
#   date = "2018-05")
# police_tib = getONSBetaTibble(path)
