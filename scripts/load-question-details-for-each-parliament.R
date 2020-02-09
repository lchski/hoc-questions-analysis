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

p39_1_questions <- get_detailed_questions_for_parliamentary_session(39, 1, fast = TRUE)
p39_1_questions %>% write_csv("data/out/detailed-questions/39-1.csv")

p39_2_questions <- get_detailed_questions_for_parliamentary_session(39, 2, fast = TRUE)
p39_2_questions %>% write_csv("data/out/detailed-questions/39-2.csv")

p40_1_questions <- get_detailed_questions_for_parliamentary_session(40, 1, fast = TRUE)
p40_1_questions %>% write_csv("data/out/detailed-questions/40-1.csv")

p40_2_questions <- get_detailed_questions_for_parliamentary_session(40, 2, fast = TRUE)
p40_2_questions %>% write_csv("data/out/detailed-questions/40-2.csv")

p40_3_questions <- get_detailed_questions_for_parliamentary_session(40, 3, fast = TRUE)
p40_3_questions %>% write_csv("data/out/detailed-questions/40-3.csv")

p41_1_questions <- get_detailed_questions_for_parliamentary_session(41, 1, fast = TRUE)
p41_1_questions %>% write_csv("data/out/detailed-questions/41-1.csv")

p41_2_questions <- get_detailed_questions_for_parliamentary_session(41, 2, fast = TRUE)
p41_2_questions %>% write_csv("data/out/detailed-questions/41-2.csv")

p42_1_questions <- get_detailed_questions_for_parliamentary_session(42, 1, fast = TRUE)
p42_1_questions %>% write_csv("data/out/detailed-questions/42-1.csv")

p43_1_questions <- get_detailed_questions_for_parliamentary_session(43, 1, fast = TRUE)
p43_1_questions %>% write_csv("data/out/detailed-questions/43-1.csv")

## combine all the detailed question objects, left join them to the question index
detailed_questions_by_parliament <- questions_by_parliament %>%
  left_join(
    p39_1_questions %>%
      rbind(p39_2_questions) %>%
      rbind(p40_1_questions) %>%
      rbind(p40_2_questions) %>%
      rbind(p40_3_questions) %>%
      rbind(p41_1_questions) %>%
      rbind(p41_2_questions) %>%
      rbind(p42_1_questions) %>%
      rbind(p43_1_questions),
    by = c("parliament", "session", "question_number", "asker_name", "asker_riding")
  ) %>%
  mutate(uid = paste0(parliament, "-", session, "-", question_number))

## get a sense of coverage, how many question contents are empty by session
## (there are sometimes a few that slip through, listed on unlikely notice paper pages)
detailed_questions_by_parliament %>%
  mutate(isna = is.na(question_content)) %>%
  count_group(parliament, session, isna) %>%
  arrange(parliament, session, isna)
## get questions without content, aka missing questions (their dates are NA)
detailed_questions_by_parliament %>%
  filter(is.na(question_date.y))

