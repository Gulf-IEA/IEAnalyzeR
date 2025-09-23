# --------------------------------------------------------
# Indicator Analysis Template
# --------------------------------------------------------

# 0. Setup ------------------------------------------------
library(tidyverse)
# library(yourpackage)  # <- add your package here

indicator_name <- "Example Indicator"
source_data <- "https://example.com/data.csv"

# 1. Data Acquisition -------------------------------------
raw <- read_csv(source_data)

# 2. Data Cleaning ----------------------------------------
cleaned <- raw |>
  janitor::clean_names()

# 3. Standard Data Prep -----------------------------------
prepared <- data_prep(cleaned)

# 4. Analysis ---------------------------------------------
result <- prepared |>
  summarize(...)

# 5. Outputs ----------------------------------------------
write_csv(result, file = "results/example_indicator.csv")
