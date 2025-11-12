
set.seed(42)

#thousand pounds
single_metric <- data.frame(
  year = 2000:2024,
  red_fish = runif(25, min = 20, max = 100)
)


start_date <- as.Date("2000-01-01")
end_date <- as.Date("2000-12-01")
months_vector = seq.Date(from = start_date, to = end_date, by = "month")

multi_unit_monthly <- data.frame(
  date = format(months_vector, "%Y-%m"),
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
