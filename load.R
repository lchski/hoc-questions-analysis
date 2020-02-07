library(tidyverse)
library(xml2)
library(lubridate)

library(helpers)

questions_raw <- read_xml("data/source/statuswq-E.XML") %>% xml_find_all(xpath = ".//ReviewItem")

extract_question_information <- function(question) {
  has_response <- question %>% xml_length() > 1
  
  entry_components <- question %>% xml_children()
  
  question_components <- entry_components[[1]]
  
  question_number <- question_components %>%
    xml_find_first(".//ReviewItemNumber/Document[@Desc='Number']") %>%
    xml_text() %>%
    str_remove("Q-") %>%
    as.integer
  
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
  response_type <- NA_character_
  response_detail <- NA_character_
  
  if (has_response) {
    response_components <- entry_components[[2]]
    
    response_date <- response_components %>%
      xml_find_first(".//ReviewItemDate") %>%
      xml_text()
    
    response_details <- response_components %>%
      xml_text() %>%
      str_remove(response_date) %>%
      trimws()
    
    if (response_details == "Answered (See Debates)") {
      response_type <- "verbal"
    } else {
      response_type <- "written"
    }
    
    if (response_type == "written") {
      response_detail <- response_details %>%
        str_remove("Made an order for return and answer tabled \\(") %>%
        str_remove("\\)") %>%
        trimws()
    }
    
    response_date <- response_date %>%
      str_remove("— ") %>%
      trimws()
  }
  
  tibble(
    question_number = question_number,
    question_date = mdy(question_date),
    question_title = question_title,
    asker = asker,
    response_date = mdy(response_date),
    response_type = response_type,
    response_detail = response_detail
  ) %>%
    separate(asker, into = c("asker_name", "asker_riding"), " \\(") %>%
    mutate(asker_riding = str_remove(asker_riding, "\\)"))
}

questions <- questions_raw %>%
  map_dfr(extract_question_information)

extract_question_information(questions_raw[[1]])
extract_question_information(questions_raw[[2]])
extract_question_information(questions_raw[[309]])


