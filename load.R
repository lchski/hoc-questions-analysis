library(tidyverse)
library(xml2)
library(lubridate)

library(helpers)

## NB: This file just loads existing data from disk.
##
## To create the files loaded here, run:
##   source("scripts/load/update-questions-responses-from-xml.R")
##   source("scripts/load/update-question-details-from-web.R")
##   source("scripts/load/update-verbal-responses-from-web.R")

## helper function to check if a file exists and bail gracefully if not
run_if_file_exists <- function(file, func) {
  if (fs::file_exists(file)) {
    func
  } else {
    message(paste0("Could not find `", file, "`"))
  }
}

## load the questions from Status of House Business XML files
run_if_file_exists(
  "data/out/questions_by_parliament.csv",
  questions_by_parliament <- read_csv("data/out/questions_by_parliament.csv", col_types = cols(
    question_uid = col_character(),
    parliament = col_double(),
    session = col_double(),
    question_number = col_double(),
    question_sitting_day = col_double(),
    question_date = col_date(format = ""),
    question_title = col_character(),
    asker_name = col_character(),
    asker_riding = col_character(),
    number_of_responses = col_double()
  ))
)

## load the detailed questions from notice papers
run_if_file_exists(
  "data/out/detailed_questions_by_parliament.csv",
  detailed_questions_by_parliament <- read_csv("data/out/detailed_questions_by_parliament.csv", col_types = cols(
    question_uid = col_character(),
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

## load the responses from Status of House Business XML files
run_if_file_exists(
  "data/out/responses_by_parliament.csv",
  responses_by_parliament <- read_csv("data/out/responses_by_parliament.csv", col_types = cols(
    question_uid = col_character(),
    parliament = col_double(),
    session = col_double(),
    question_number = col_double(),
    response_date = col_date(format = ""),
    response_sitting_day = col_double(),
    response_type = col_character(),
    response_detail = col_character(),
    response_details_full = col_character()
  ))
)

## load the questions from Status of House Business XML files
run_if_file_exists(
  "data/out/verbal_responses.csv",
  verbal_responses <- read_csv("data/out/verbal_responses.csv", col_types = cols(
    question_uid = col_character(),
    parliament = col_double(),
    session = col_double(),
    response_sitting_day = col_double(),
    question_number = col_double(),
    asker_name = col_character(),
    responder_name = col_character(),
    response_content = col_character()
  ))
)

## clean up our helper function
rm(run_if_file_exists)

## get a list of questions with detailed content and responses merged in
questions_and_responses <- questions_by_parliament %>%
  left_join(
    detailed_questions_by_parliament %>%
      select(question_uid:session, question_number, asker_name, asker_riding, question_content) %>%
      distinct()
  ) %>%
  select(question_uid:question_title, question_content, asker_name:number_of_responses) %>%
  distinct() %>%
  left_join(
    responses_by_parliament %>%
      left_join(verbal_responses) %>%
      select(-asker_name)
  ) %>%
  nest(
    responses = c(
      response_date,
      response_sitting_day,
      response_type,
      response_detail,
      response_details_full,
      responder_name,
      response_content
    )
  )

questions_and_responses %>%
  unnest(c(responses)) %>%
  write_csv("data/out/questions_and_responses.csv")
