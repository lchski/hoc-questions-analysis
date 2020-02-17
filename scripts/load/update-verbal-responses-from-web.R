library(rvest)

generate_hansard_url <- function(parliament, session, sitting_day, format = "xml") {
  if (format == "xml") {
    return(paste0(
      "https://www.ourcommons.ca/Content/House/",
      parliament,
      session,
      "/Debates/",
      sitting_day,
      "/HAN",
      sitting_day,
      "-E.XML"
    ))
  } else if (format == "html") {
    return(paste0(
      "https://www.ourcommons.ca/DocumentViewer/en/",
      parliament,
      "-",
      session,
      "/house/sitting-",
      sitting_day,
      "/hansard"
    ))
  }
}

generate_hansard_url(40, 3, 120)

hansard <- read_xml("data/source/hansard/403/HAN120-E.XML")

get_response_nodes_from_hansard <- function(parliament, session, sitting_day) {
  hansard <- NULL
  
  hansard_file_path <- paste0("data/source/hansard/", parliament, session, "/HAN", sitting_day, "-E.XML")
  
  if (fs::file_exists(hansard_file_path)) {
    hansard <- read_xml(hansard_file_path)
  } else {
    tryCatch({
      hansard <- read_xml(generate_hansard_url(parliament, session, sitting_day))},
      error = function(c) {
        message(
          paste0(
            "Got an error when trying to read_html a hansard.\n\t ",
            "parliament = ", parliament,
            "; session = ", session,
            "; sitting_day = ", sitting_day
          )
        )
      }
    )
  }
  
  ## didn't find anything, so let's return early from the function with just an empty list
  if (is_null(hansard)) {
    return(list())
  }
  
  response_section <- hansard %>%
    xml_nodes(xpath = '//SubjectOfBusiness/SubjectOfBusinessTitle[contains(text(), "Questions on the Order Paper") or contains(text(), "Questions on the Order Paper")]/..')
  
  ## get all `WrittenQuestionResponse` that don't have "(Return tabled)" within them
  response_nodes <- response_section %>%
    xml_nodes(xpath = '//WrittenQuestionResponse//ResponseContent[not(starts-with(ParaText/text(), "(Return tabled)"))]/..')
  
  response_nodes
}

extract_response_information_from_hansard <- function(response_node) {
  question_number <- response_node %>%
    xml_find_first(".//QuestionID") %>%
    xml_text() %>%
    str_remove("Question No.") %>%
    str_remove("--") %>%
    as.integer
  
  asker_name <- response_node %>%
    xml_find_first(".//Questioner/Affiliation") %>%
    xml_text() %>%
    trimws
  
  response_content <- response_node %>%
    xml_find_first(".//QuestionContent") %>%
    xml_text() %>%
    trimws
  
  tibble(
    question_number = question_number,
    asker_name = asker_name,
    response_content = response_content
  )
}

get_response_nodes_from_hansard(40, 3, 120) %>%
  map_dfr(extract_response_information_from_hansard)

