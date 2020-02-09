source("scripts/load-question-details.R")

get_detailed_questions_for_parliamentary_session <- function(parliament_to_check, session_to_check, fast = FALSE) {
  if (fast) {
    scraper = scrape_questions_content_for_day
  } else {
    scraper = slow_scrape_questions_content_for_day
  }

  questions_by_parliament %>%
    filter(parliament == parliament_to_check & session == session_to_check) %>%
    distinct(parliament, session, question_sitting_day) %>%
    mutate(
      detailed_questions = pmap(., scraper)
    ) %>%
    unnest(cols = c(detailed_questions), names_repair = "universal")
}

## get a sense of how many requests per session (aka how many sitting days there were with Qs asked)
questions_by_parliament %>% count_group(parliament, session, question_sitting_day) %>% count()

p40_1_questions <- get_detailed_questions_for_parliamentary_session(40, 1, fast = TRUE)
p40_1_questions %>% write_csv("data/out/detailed-questions/40-1.csv")

p43_1_questions <- get_detailed_questions_for_parliamentary_session(43, 1, fast = TRUE)
p43_1_questions %>% write_csv("data/out/detailed-questions/43-1.csv")

## combine all the detailed question objects, left join them to the question index
questions_by_parliament %>%
  left_join(
    p40_1_questions %>%
      rbind(p43_1_questions),
    by = c("parliament", "session", "question_number", "asker_name", "asker_riding")
  )

