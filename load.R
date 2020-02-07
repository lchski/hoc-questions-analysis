library(tidyverse)
library(xml2)
library(lubridate)

library(helpers)

questions_raw <- read_xml("data/source/42-1.XML") %>% xml_find_all(xpath = ".//ReviewItem")

extract_question_information <- function(question) {
  extract_sitting_day <- function(component) {
    component  %>% 
      xml_attr("NodeTitle") %>%
      str_extract("[^0-9]*([0-9]+)") %>%
      str_remove("[^0-9]*") %>%
      as.integer
  }
  
  has_response <- question %>% xml_length() > 1
  
  entry_components <- question %>% xml_children()
  
  question_components <- entry_components[[1]]
  
  question_number <- question_components %>%
    xml_find_first(".//ReviewItemNumber/Document[@Desc='Number']") %>%
    xml_text() %>%
    str_remove("Q-") %>%
    as.integer
  
  question_sitting_day <- question_components %>%
    extract_sitting_day
  
  question_date <- question_components %>%
    xml_find_first(".//ReviewItemDate") %>%
    xml_text() %>%
    str_remove("— ") %>%
    trimws()
  
  question_title <- question_components %>%
    xml_find_first(".//Document[@Desc='Title']") %>%
    xml_text()
  
  asker <- question_components %>%
    xml_find_first(".//Affiliation") %>%
    xml_text()
  
  response_date <- NA_character_
  response_sitting_day <- NA_integer_
  response_type <- NA_character_
  response_detail <- NA_character_
  
  if (has_response) {
    response_components <- entry_components[[2]]
    
    response_date <- response_components %>%
      xml_find_first(".//ReviewItemDate") %>%
      xml_text()
    
    response_sitting_day <- response_components %>%
      extract_sitting_day
    
    response_details <- response_components %>%
      xml_text() %>%
      str_remove(response_date) %>%
      trimws()
    
    if (is.na(response_details)) {
      response_type = "other"
    } else if (response_details == "Answered (See Debates)") {
      response_type <- "verbal"
    } else {
      response_type <- "written"
    }
    
    if (response_type == "written") {
      response_detail <- response_details %>%
        str_remove(regex("Made an order for return and answer tabled \\(", ignore_case = TRUE)) %>%
        str_remove("\\)") %>%
        trimws()
    }
    
    response_date <- response_date %>%
      str_remove("— ") %>%
      trimws()
  }
  
  tibble(
    question_number = question_number,
    question_sitting_day = question_sitting_day,
    question_date = mdy(question_date),
    question_title = question_title,
    asker = asker,
    response_date = mdy(response_date),
    response_sitting_day = response_sitting_day,
    response_type = response_type,
    response_detail = response_detail
  ) %>%
    separate(asker, into = c("asker_name", "asker_riding"), " \\(") %>%
    mutate(asker_riding = str_remove(asker_riding, "\\)"))
}

questions <- questions_raw %>%
  map_dfr(extract_question_information)


