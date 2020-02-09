library(rvest)

scrape_questions_content_for_day <- function(parliament, session, question_sitting_day, ...) {
  get_question_nodes_from_notice_paper <- function(parliament, session, question_sitting_day, page_number = 11) {
    notice_paper <- NULL
    
    tryCatch({
      notice_paper <- read_html(
        paste0(
          "https://www.ourcommons.ca/DocumentViewer/en/",
          parliament,
          "-",
          session,
          "/house/sitting-",
          question_sitting_day,
          "/order-notice/page-",
          page_number
        ))},
      error = function(c) {
        message(
          paste0(
            "Got an error when trying to read_html a notice paper.\n\t ",
            "parliament = ", parliament,
            "; session = ", session,
            "; question_sitting_day = ", question_sitting_day
          )
        )
      }
    )

    ## didn't find anything, so let's return early from the function with just an empty list
    if (is_null(notice_paper)) {
      return(list())
    }
    
    question_nodes <- notice_paper %>%
      html_nodes(xpath = '//td[@class="JustifiedTop ItemPara" or @class="JustifiedTop ItemPara LastItemPara"]//b[contains(text(), "Q-")]/..')

    question_nodes
  }

  question_nodes <- get_question_nodes_from_notice_paper(parliament, session, question_sitting_day)

  if (length(question_nodes) == 0) {
    message(
      paste0(
        "Couldn't find a notice paper with default settings. Retrying with page_number = 12.\n\t ",
        "parliament = ", parliament,
        "; session = ", session,
        "; question_sitting_day = ", question_sitting_day
      )
    )
      
    question_nodes <- get_question_nodes_from_notice_paper(parliament, session, question_sitting_day, page_number = 12)
  }

  if (length(question_nodes) == 0) {
    message(
      paste0(
        "Couldn't find any question nodes. Maybe there's no notice paper? Returning a blank set.\n\t ",
        "parliament = ", parliament,
        "; session = ", session,
        "; question_sitting_day = ", question_sitting_day
      )
    )
    
    return(
      tibble(
        question_number = NA_integer_,
        question_date = as_date(NA_real_),
        asker_name = NA_character_,
        asker_riding = NA_character_,
        question_content = NA_character_
      )
    )
  }
  
  object_ids <- question_nodes %>%
    html_node("b") %>%
    html_nodes(xpath="./text()[normalize-space()]") %>%
    html_text(trim=TRUE)
  
  detailed_questions <- question_nodes %>%
    html_text() %>% 
    str_split(" — ", n = 4) %>%
    transpose() %>%
    as_tibble(.name_repair = ~ c("question_number", "question_date", "person", "question_content")) %>%
    unnest(cols = c(question_number, question_date, person, question_content)) %>%
    mutate(question_number = object_ids) %>%
    mutate(question_date = mdy(question_date)) %>%
    mutate(question_number = as.integer(str_remove(question_number, "Q-"))) %>%
    separate(person, into = c("asker_name", "asker_riding"), " \\(") %>%
    mutate(asker_riding = str_remove(asker_riding, "\\)")) %>%
    mutate_at(c("asker_name", "asker_riding", "question_content"), trimws)
  
  detailed_questions
}

slow_scrape_questions_content_for_day <- function(..., waiting_period = 5) {
  Sys.sleep(waiting_period)
  
  scrape_questions_content_for_day(...)
}
