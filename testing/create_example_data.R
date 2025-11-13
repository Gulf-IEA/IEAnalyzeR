
set.seed(42)

#thousand pounds
single_metric <- data.frame(
  year = 2000:2024,
  red_fish = runif(25, min = 20, max = 100)
)


start_date <- as.Date("2000-01-01")
end_date <- as.Date("2010-12-01")
months_vector = seq.Date(from = start_date, to = end_date, by = "month")

multi_unit_monthly <- data.frame(
  date = format(months_vector, "%m-%Y"),
  temp_a = runif(12, min = 25, max = 29),
  salinity_a = runif(12, min = 10, max = 20),
  temp_b = runif(12, min = 25, max = 29),
  salinity_b = runif(12, min = 10, max = 20)
)

#millions
annual_by_area <- data.frame(
  year = 2000:2024,
  Narnia = runif(25, min = 47, max = 49),
  Westeros = runif(25, min = 38, max = 40),
  Wakanda = runif(25, min = 5, max = 6.5),
  Arrakis = runif(25, min = 14, max = 16)
)


usethis::use_data(single_metric)
usethis::use_data(multi_unit_monthly, overwrite = TRUE)
usethis::use_data(annual_by_area)


head(multi_unit_monthly)

#Define header components for the data rows (ignore year)
indicator_names <- rep("Environmental parameters", ncol(multi_unit_monthly)-1)
unit_names <- c("Temperature (°F)", "Salinity (ppm)", "Temperature (°F)", "Salinity (ppm)")
extent_names <- c("Area A", "Area B", "Area A", "Area B")

# 3. Call the function
monthly_table <- convert_cleaned_data(multi_unit_monthly, indicator_names, unit_names, extent_names)
head(monthly_table)


# Create a temporary file path for the CSV output
temp_path1 <- tempfile(pattern = "single_output", fileext = ".csv")
temp_path2 <- tempfile(pattern = "multi_output", fileext = ".csv")
temp_path3 <- tempfile(pattern = "monthly_output", fileext = ".csv")

#Save each table to its unique temporary file path
write.csv(single_table, file = temp_path1, row.names = FALSE)
write.csv(multi_table, file = temp_path2, row.names = FALSE)
write.csv(monthly_table, file = temp_path3, row.names = FALSE)

test = read.csv(temp_path3)
str(test)

final_single_data <- IEAnalyzeR::data_prep(temp_path1)
str(final_single_data)

final_multi_data <- IEAnalyzeR::data_prep(temp_path2, subind = "extent")
str(final_multi_data)

# With monthly data, we need to specify the anomaly argument. Either monthly or standardized monthly.
final_monthly_data <- IEAnalyzeR::data_prep(test, anomaly = "stdmonthly")
str(final_monthly_data)
