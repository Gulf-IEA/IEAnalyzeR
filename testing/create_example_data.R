
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
  temperature = c(25.89727645, 25.48104323, 25.33843609, 26.0708692, 27.11931808, 27.55626161, 27.79084524, 28.50071049, 28.94800842, 28.81906083, 28.36563713, 27.16899144),
  salinity = runif(12, min = 10, max = 20)
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
usethis::use_data(multi_unit_monthly)
usethis::use_data(annual_by_area)
