library(readr)
library(dplyr)

# 1. Define dummy data
dat <- data.frame(
  year = 2000:2004,
  bio_spec1 = c(5, 10, 3, 7, 11),
  bio_spec2 = c(7, 3, 8, 8, 12)
)

# 2. Define header components for the data rows (ignore year)
indicator_names <- c("Biomass", "Biomass")
unit_names <- c("Count", "Count")
extent_names <- c("species A", "species B")

# 3. Call the function
final_table <- convert_cleaned_data(dat, indicator_names, unit_names, extent_names)
print(final_table)

readr::write_csv(final_table, "testing/test_converted_table.csv")

test = read.csv("testing/test_converted_table.csv", header = FALSE)

test2 = IEAnalyzeR::data_prep(test, subind = "extent")

test2

IEAnalyzeR::plot_fn_obj(test2)



