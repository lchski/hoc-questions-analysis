source("load.R")

extract_sitting_day <- function(component) {
  component  %>% 
    xml_attr("NodeTitle") %>%
    str_extract("[^0-9]*([0-9]+)") %>%
    str_remove("[^0-9]*") %>%
    as.integer
}



extract_question_information <- function(question) {
  number_of_components <- question %>% xml_length()
  number_of_responses <- number_of_components - 1
  
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
  
  tibble(
    question_number = question_number,
    question_sitting_day = question_sitting_day,
    question_date = mdy(question_date),
    question_title = question_title,
    asker = asker,
    number_of_responses = number_of_responses
  ) %>%
    separate(asker, into = c("asker_name", "asker_riding"), " \\(") %>%
    mutate(asker_riding = str_remove(asker_riding, "\\)"))
}

extract_response_information <- function(question) {
  number_of_components <- question %>% xml_length()
  number_of_responses <- number_of_components - 1
  
  entry_components <- question %>% xml_children()
  
  question_components <- entry_components[[1]]
  
  question_number <- question_components %>%
    xml_find_first(".//ReviewItemNumber/Document[@Desc='Number']") %>%
    xml_text() %>%
    str_remove("Q-") %>%
    as.integer
  
  if (number_of_responses == 0) {
    responses_to_return <- tibble(
      question_number = question_number,
      response_date = mdy(NA_character_),
      response_sitting_day = NA_integer_,
      response_type = NA_character_,
      response_detail = NA_character_,
      response_details_full = NA_character_
    )
    
    return(responses_to_return)
  }
  
  extract_response_details_from_components <- function(response_components) {
    response_sitting_day <- response_components %>%
      extract_sitting_day
    
    response_details <- response_components %>%
      xml_text()
    
    ## TODO verify this doesn't break more stuff hehe
    response_date <- response_details %>%
      str_extract("[A-Z][a-z]* [0-9]{1,2}, [0-9]{4}")
    
    if (is.na(response_details)) {
      response_type = "other"
    } else if (str_detect(response_details, regex("Withdrawn", ignore_case = TRUE))) {
      response_type = "withdrawn"
    } else if (str_detect(response_details, regex("See Debates", ignore_case = TRUE))) {
      response_type <- "verbal"
    } else {
      response_type <- "written"
    }
    
    response_detail <- NA_character_
    
    if (response_type == "verbal") {
      response_detail <- paste("Debates", response_date)
    }
    
    if (response_type == "written") {
      response_date_to_remove <- response_date
      
      if (is.na(response_date_to_remove)) {
        response_date_to_remove <- "zzz"
      }
      
      response_detail <- response_details %>%
        str_remove(response_date_to_remove) %>%
        str_remove(fixed(" — ")) %>%
        str_remove("[A-Za-z (\\.]*") %>%
        str_remove("\\)") %>%
        str_remove("[[:space:]]") %>%
        trimws() %>%
        paste("Sessional Paper No.", .)
    }
    
    #response_detail = NA_character_ ## TODO remove me, just for debugging when response_detail breaks
    
    tibble(
      question_number = question_number,
      response_date = response_date,
      response_sitting_day = response_sitting_day,
      response_type = response_type,
      response_detail = response_detail,
      response_details_full = response_details
    )
  }
  
  ## take out the question component, get the response components
  responses_to_return <- entry_components[-1] %>%
    map_dfr(extract_response_details_from_components)
  
  responses_to_return %>%
    mutate(response_date = mdy(response_date))
}

read_questions <- function(path_to_xml_file) {
  questions_raw <- read_xml(path_to_xml_file) %>% xml_find_all(xpath = ".//ReviewItem")
  
  questions_raw %>%
    map_dfr(extract_question_information)
}

read_responses <- function(path_to_xml_file) {
  questions_raw <- read_xml(path_to_xml_file) %>% xml_find_all(xpath = ".//ReviewItem")
  
  questions_raw %>%
    map_dfr(extract_response_information)
}



question_files_by_parliament <- fs::dir_ls("data/source/", regexp = "\\.XML") %>%
  as_tibble() %>%
  transmute(path = as.character(value)) %>%
  pull(path) %>%
  set_names(.)


apply_to_parliament_files <- function(parliament_files, func_to_apply) {
  parliament_files %>%
    map_dfr(func_to_apply, .id = "source_file") %>%
    mutate(parliament = source_file %>%
             str_remove(fixed("data/source/")) %>%
             str_remove(fixed(".XML"))) %>%
    separate(parliament, c("parliament", "session"), convert = TRUE)
}

questions_by_parliament <- question_files_by_parliament %>%
  apply_to_parliament_files(read_questions) %>%
  select(parliament, session, question_number:number_of_responses)

questions_by_parliament %>% write_csv("data/out/questions_by_parliament.csv")



## debugging
## issue with responses .[3]
question_files_by_parliament %>%
  .[3] %>%
  apply_to_parliament_files(read_responses) %>%
  select(parliament, session, question_number:response_details_full)

responses_by_parliament <- question_files_by_parliament %>%
  apply_to_parliament_files(read_responses) %>%
  select(parliament, session, question_number:response_details_full)

responses_by_parliament %>% write_csv("data/out/responses_by_parliament.csv")
