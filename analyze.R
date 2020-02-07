library(skimr)

questions_by_parliament %>%
  left_join(responses_by_parliament) %>%
  group_by(parliament, session, question_number) %>%
  mutate(time_until_response = response_date - question_date) %>%
  ungroup() %>%
  group_by(parliament, session) %>%
  skim(time_until_response)


