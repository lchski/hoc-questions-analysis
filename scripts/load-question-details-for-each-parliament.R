source("load.R")

source("lib/load-question-details.R")

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

parliaments_with_questions <- tribble(
  ~parliament, ~session, ~is_current,
  39, 1, FALSE,
  39, 2, FALSE,
  40, 1, FALSE,
  40, 2, FALSE,
  40, 3, FALSE,
  41, 1, FALSE,
  41, 2, FALSE,
  42, 1, FALSE,
  43, 1, TRUE
)

detailed_questions_by_parliament <- parliaments_with_questions %>%
  mutate(detailed_questions = pmap(., function(parliament, session, is_current) {
    detailed_questions_file_path <- paste0("data/out/detailed-questions/", parliament, "-", session, ".csv")
    
    ## check if there's an existing file, but only for non-current sessions
    if (! is_current & fs::file_exists(detailed_questions_file_path)) {
      message(
        paste0(
          "Found existing detailed questions, using those.\n\t ",
          "parliament = ", parliament,
          "; session = ", session,
          "; is_current = ", is_current
        )
      )
      
      return(
        read_csv(
          detailed_questions_file_path,
          col_types = cols(
            parliament = col_double(),
            session = col_double(),
            question_sitting_day = col_double(),
            question_number = col_double(),
            question_date = col_date(format = ""),
            asker_name = col_character(),
            asker_riding = col_character(),
            question_content = col_character()
          ),
          
        )
      )
    }
    
    message(
      paste0(
        "Current session or no existing detailed questions, scraping.\n\t ",
        "parliament = ", parliament,
        "; session = ", session,
        "; is_current = ", is_current
      )
    )
    
    detailed_questions <- get_detailed_questions_for_parliamentary_session(parliament, session, fast = TRUE)
    detailed_questions %>% write_csv(detailed_questions_file_path)
    
    return(detailed_questions)
  })) %>%
  select(detailed_questions) %>%
  unnest(c(detailed_questions)) %>%
  mutate(question_uid = paste0(parliament, "-", session, "-", question_number))

detailed_questions_by_parliament %>% write_csv("data/out/detailed_questions_by_parliament.csv")



## for debugging only, wrapped in a function to prevent auto-run on source
function() {
  ## get a sense of how many requests per session (aka how many sitting days there were with Qs asked)
  questions_by_parliament %>% count_group(parliament, session, question_sitting_day) %>% count()
  
  ## get a sense of coverage, how many question contents are empty by session
  ## (there are sometimes a few that slip through, listed on unlikely notice paper pages)
  detailed_questions_by_parliament %>%
    mutate(isna = is.na(question_content)) %>%
    count_group(parliament, session, isna) %>%
    arrange(parliament, session, isna)
  
  ## get questions without content, aka missing questions (their dates are NA)
  detailed_questions_by_parliament %>%
    filter(is.na(question_date.y))
}
