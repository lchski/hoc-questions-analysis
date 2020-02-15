detailed_questions_by_parliament %>%
  filter(str_detect(question_content, regex("privacy", ignore_case = TRUE))) %>%
  filter(str_detect(question_title, regex("privacy|access|information|breach|cyber", ignore_case = TRUE))) %>%
  View()
