
## MAKE FAKE DATA
set.seed(42)

#thousand pounds
single_metric <- data.frame(
  year = 2000:2024,
  red_fish = runif(25, min = 20, max = 100)
)


# Define the start and end dates
start_date <- as.Date("2000-01-01")
end_date <- as.Date("2010-12-01")

# Create a vector of all monthly dates
months_vector <- seq.Date(from = start_date, to = end_date, by = "month")

# Calculate the total number of rows (should be 132)
n_rows <- length(months_vector)

# Create the DataFrame with 132 unique random numbers for each variable
set.seed(42) # Re-setting the seed is good practice for reproducibility

multi_unit_monthly <- data.frame(
  date = format(months_vector, "%Y-%m"), # Changed format for better sorting
  temp_a = runif(n_rows, min = 25, max = 29),
  salinity_a = runif(n_rows, min = 10, max = 20),
  temp_b = runif(n_rows, min = 25, max = 29),
  salinity_b = runif(n_rows, min = 10, max = 20)
)

#millions
annual_by_area <- data.frame(
  year = 2000:2024,
  Narnia = runif(25, min = 47, max = 49),
  Westeros = runif(25, min = 38, max = 40),
  Wakanda = runif(25, min = 5, max = 6.5),
  Arrakis = runif(25, min = 14, max = 16)
)

#two category data
two_cat <- data.frame(
  year = 2000:2024,
  rev_narnia= runif(25, min = 10000, max = 30000),
  count_narnia= runif(25, min = 5, max = 100),
  rev_wakanda= runif(25, min = 10000, max = 30000),
  count_wakanda= runif(25, min = 5, max = 100)
)


#save fake date (unformatted)
usethis::use_data(single_metric, overwrite = TRUE)
usethis::use_data(multi_unit_monthly, overwrite = TRUE)
usethis::use_data(annual_by_area, overwrite = TRUE)
usethis::use_data(two_cat, overwrite = TRUE)


# head(multi_unit_monthly)

# ADD HEADERS TO FAKE DATA

#Single metric add headers
indicator_names <- c("Red fish biomass")
unit_names <- c("Thousand pounds")
extent_names <- c("")

  # call the function
single_table <- convert_cleaned_data(single_metric, indicator_names, unit_names, extent_names)
head(single_table)

#Monthly (multi) metric add headers
indicator_names <- rep("Environmental parameters", ncol(multi_unit_monthly)-1)
unit_names <- c("Temperature (°F)", "Salinity (ppm)", "Temperature (°F)", "Salinity (ppm)")
extent_names <- c("Area A", "Area B", "Area A", "Area B")

  # call the function
monthly_table <- convert_cleaned_data(multi_unit_monthly, indicator_names, unit_names, extent_names)
head(monthly_table)

#Multi metric add headers
indicator_names <- rep("Population", ncol(annual_by_area)-1)
unit_names <- rep("Millions", ncol(annual_by_area)-1)
extent_names <- c("Narnia", "Westeros", "Wakanda", "Arrakis")

  # all the function
multi_table <- convert_cleaned_data(annual_by_area, indicator_names, unit_names, extent_names)
head(multi_table)

#Two category data add headers
indicator_names <- rep("Count and Revenue", ncol(two_cat)-1)
unit_names <- c("Revenue (USD)", "Count", "Revenue (USD)", "Count")
extent_names <- c("Narnia", "Narnia", "Wakanda", "Wakanda")

# all the function
twocat_table <- convert_cleaned_data(two_cat, indicator_names, unit_names, extent_names)
head(twocat_table)

# DATA_PREP FAKE DATA

single_data_formatted <- IEAnalyzeR::data_prep(single_table)
str(single_data_formatted)

multi_data_formatted <- IEAnalyzeR::data_prep(multi_table, subind = "extent")
str(multi_data_formatted)

# With monthly data, we need to specify the anomaly argument. Either monthly or standardized monthly.
monthly_data_formatted <- IEAnalyzeR::data_prep(monthly_table, anomaly = "stdmonthly")
str(monthly_data_formatted)

twocat_data_formatted <- IEAnalyzeR::data_prep(twocat_table)

# SAVE PREPPED FAKE DATA IN PACKAGE
usethis::use_data(single_data_formatted, overwrite = TRUE)
usethis::use_data(multi_data_formatted, overwrite = TRUE)
usethis::use_data(monthly_data_formatted, overwrite = TRUE)
usethis::use_data(twocat_data_formatted, overwrite = TRUE)
