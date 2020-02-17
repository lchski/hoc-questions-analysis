
## test cases (from 42-1)
extract_response_information(questions_raw[[1]])
extract_response_information(questions_raw[[65]])
extract_response_information(questions_raw[[70]])
extract_response_information(questions_raw[[1720]])
extract_response_information(questions_raw[[1763]])
extract_response_information(questions_raw[[2530]])

## test cases (from 43-1)
extract_question_information(questions_raw[[1]]) ## Q asked and answered with sessional paper
extract_question_information(questions_raw[[2]]) ## Q asked and answered with debate
extract_question_information(questions_raw[[309]]) ## Q asked and not yet answered (TODO change this when data updated)

extract_question_information(questions_raw[[3]])

## EDGE CASES!!
  # - some e.g. parl 42-1 Q-70 have two responses
  # - parl 42-1 says "Made an Order for Return and answer tabled"


## find duplicated questions in `questions_and_responses` (tied, I think, to slightly different content)
questions_and_responses %>%
  filter(question_uid %in%
           ((.) %>%
              count_group(question_uid) %>%
              filter(count > 1) %>%
              pull(question_uid)
            )
         )

