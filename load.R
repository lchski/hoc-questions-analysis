library(tidyverse)
library(xml2)
library(lubridate)

library(helpers)

## NB: This file just loads existing data from disk.
##
## To create the files loaded here, run:
##   source("scripts/load-updated-stored.R")
##   source("scripts/load-question-details-for-each-parliament.R")

run_if_file_exists <- function(file, func) {
  if (fs::file_exists(file)) {
    func
  } else {
    message(paste0("Could not find `", file, "`"))
  }
}

run_if_file_exists(
  "data/out/questions_by_parliament.csv",
  questions_by_parliament <- read_csv("data/out/questions_by_parliament.csv", col_types = cols(
    parliament = col_double(),
    session = col_double(),
    question_number = col_double(),
    question_sitting_day = col_double(),
    question_date = col_date(format = ""),
    question_title = col_character(),
    asker_name = col_character(),
    asker_riding = col_character(),
    number_of_responses = col_double()
  )) %>%
    mutate(question_uid = paste0(parliament, "-", session, "-", question_number))
)

run_if_file_exists(
  "data/out/responses_by_parliament.csv",
  responses_by_parliament <- read_csv("data/out/responses_by_parliament.csv", col_types = cols(
    parliament = col_double(),
    session = col_double(),
    question_number = col_double(),
    response_date = col_date(format = ""),
    response_sitting_day = col_double(),
    response_type = col_character(),
    response_detail = col_character(),
    response_details_full = col_character()
  )) %>%
    mutate(question_uid = paste0(parliament, "-", session, "-", question_number))
)

run_if_file_exists(
  "data/out/detailed_questions_by_parliament.csv",
  detailed_questions_by_parliament <- read_csv("data/out/detailed_questions_by_parliament.csv", col_types = cols(
    parliament = col_double(),
    session = col_double(),
    question_sitting_day = col_double(),
    question_number = col_double(),
    question_date = col_date(format = ""),
    asker_name = col_character(),
    asker_riding = col_character(),
    question_content = col_character()
  ))
)
