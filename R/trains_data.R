library(googlesheets4)
library(dplyr)
library(stringr)
library(tidyr)

# googlesheets4::sheets_auth()
trains_data <- googlesheets4::sheets_read(
  "1CIGEFtize7CFhfygVfeHyQ1vZyLGY7xFFo_A9XWVfy4"
) %>%
  # For the moment I'm just using the first 50 rows for demo purposes.
  head(50) %>%
  dplyr::select(
    "learning_no_train" = `A single sentence about learning, WITHOUT using the word "train" (nor "trained", "training", etc).`,
    "travel_no_train" = `A single sentence about travel, WITHOUT using the word "train" (as in the vehicle).`,
    "learning_train" = `A single sentence about learning, WITH the word "train" (or "trained", "training", etc, meaning "teach").`,
    "travel_train" = `A single sentence about travel, WITH the word "train" (as in the vehicle).`
  ) %>%
  dplyr::mutate_all(
    ~stringr::str_replace_all(
      .,
      c("â€™" = "'")
    )
  ) %>%
  dplyr::mutate_all(stringr::str_squish) %>%
  tidyr::pivot_longer(
    cols = dplyr::everything(),
    names_to = "label",
    values_to = "sentence"
  ) %>%
  # I don't actually want to trust that everyone followed directions on using
  # "train" or not, so I'm going to merge the labels then test for presence of
  # "train".
  dplyr::mutate(
    label = factor(
      label,
      levels = c(
        "learning_no_train",
        "learning_train",
        "travel_no_train",
        "travel_train"
      ),
      labels = c(
        "learning", "learning", "travel", "travel"
      )
    ),
    mentions_train = stringr::str_detect(tolower(sentence), "train")
  )

saveRDS(trains_data, here::here("data", "trains_data.rds"))
