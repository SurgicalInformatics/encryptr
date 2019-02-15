# Read data
library(readr)
gp <- read_csv("data-raw/scotprac.csv", col_types = list(
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_date("%Y%m%d"),
  col_date("%Y%m%d"),
  col_character(),
  col_double())
)
save(gp, file = "data/gp.rda")
