source("load.R")

source("lib/load-verbal-responses.R")

get_verbal_responses_for_sitting_day <- function(parliament, session, response_sitting_day, ...) {
  get_response_nodes_from_hansard(parliament, session, response_sitting_day, ...) %>%
    map_dfr(extract_response_information_from_hansard)
}

## get the days for which we have verbal responses, then get the verbal responses for those days
verbal_responses <- responses_by_parliament %>%
  filter(response_type == "verbal") %>%
  select(parliament, session, response_sitting_day) %>%
  arrange(parliament, session, response_sitting_day) %>%
  distinct() %>%
  mutate(
    verbal_responses = pmap(., get_verbal_responses_for_sitting_day) ## NB add `, store_hansard_xml = TRUE` if you want to save all the XML files you download
  ) %>%
  unnest(c(verbal_responses)) %>%
  filter(! is.na(responder_name)) %>% ## remove the odd "Return tabled" that slipped through (no responder listed)
  mutate(question_uid = paste0(parliament, "-", session, "-", question_number)) %>%
  select(question_uid, parliament:response_content)

verbal_responses %>%
  write_csv("data/out/verbal_responses.csv")
