library(tidyverse)
library(xml2)
library(lubridate)

library(helpers)

questions_by_parliament <- read_csv("data/out/questions_by_parliament.csv") %>%
  mutate(question_uid = paste0(parliament, "-", session, "-", question_number))

responses_by_parliament <- read_csv("data/out/responses_by_parliament.csv") %>%
  mutate(question_uid = paste0(parliament, "-", session, "-", question_number))

detailed_questions_by_parliament <- read_csv("data/out/detailed_questions_by_parliament.csv")
