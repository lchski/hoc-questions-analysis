library(rvest)

scrape_questions_content_for_day <- function(parliament, session, sitting_day) {
  notice_paper <- read_html(
    paste0(
      "https://www.ourcommons.ca/DocumentViewer/en/",
      parliament,
      "-",
      session,
      "/house/sitting-",
      sitting_day,
      "/order-notice/page-11"
    ))
  
  object_ids <- notice_paper %>%
    html_nodes(xpath = '//td[@class="JustifiedTop ItemPara"]//b/..') %>%
    html_node("b") %>%
    html_nodes(xpath="./text()[normalize-space()]") %>%
    html_text(trim=TRUE)
  
  detailed_questions <- notice_paper %>%
    html_nodes(xpath = '//td[@class="JustifiedTop ItemPara"]//b/..') %>%
    html_text() %>% 
    str_split(" — ") %>%
    transpose() %>%
    as_tibble(.name_repair = ~ c("question_number", "question_date", "person", "question_content")) %>%
    unnest(cols = c(question_number, question_date, person, question_content)) %>%
    mutate(question_number = object_ids) %>%
    mutate(question_date = mdy(question_date)) %>%
    filter(str_detect(question_number, "Q-")) %>% ## getting rid of M- etc.
    mutate(question_number = as.integer(str_remove(question_number, "Q-"))) %>%
    separate(person, into = c("asker_name", "asker_riding"), " \\(") %>%
    mutate(asker_riding = str_remove(asker_riding, "\\)"))
  
  detailed_questions
}

slow_scrape_questions_content_for_day <- function(..., waiting_period = 20) {
  Sys.sleep(waiting_period)
  
  scrape_questions_content_for_day(...)
}


