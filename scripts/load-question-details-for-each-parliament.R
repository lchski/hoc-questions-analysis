source("scripts/load-question-details.R")


## get a sense of how many requests per session (aka how many sitting days there were with Qs asked)
questions_by_parliament %>% count_group(parliament, session, question_sitting_day) %>% count()

get_detailed_questions_for_parliamentary_session <- function(parliament, session) {
  questions_by_parliament %>%
    filter(parliament == parliament & session == session) %>%
    distinct(parliament, session, question_sitting_day) %>%
    mutate(
      detailed_questions = pmap(., slow_scrape_questions_content_for_day)
    ) %>%
    unnest(cols = c(detailed_questions))
}

p40_1_questions <- get_detailed_questions_for_parliamentary_session(40, 1)

p43_1_questions <- questions_by_parliament %>%
  filter(parliament == 43) %>%
  distinct(parliament, session, question_sitting_day) %>%
  mutate(
    detailed_questions = pmap(., slow_scrape_questions_content_for_day)
  ) %>%
  unnest(cols = c(detailed_questions))

questions_by_parliament %>%
  left_join(p43_questions, by = c("parliament", "session", "question_number", "asker_name", "asker_riding"))

