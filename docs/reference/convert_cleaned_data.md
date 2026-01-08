# Convert cleaned indicator dataset to indicator data format (with metadata rows)

This function takes a numeric data frame with year as column 1 and
metric values in the remaining columns and combines it with three
vectors representing different levels of header metadata (indicator,
unit, and extent/sub-indicator). It returns a single data frame that
once saved as a csv is in the correct format for ingestion into the
IEAnalyzeR data_prep function.

## Usage

``` r
convert_cleaned_data(data, indicator_names, unit_names, extent_names)
```

## Arguments

- data:

  A data frame or matrix containing numeric data only.

- indicator_names:

  A character vector of names for the top most header row (the name of
  the indicator). The vector should be the length of the columns
  excluding the year column.

- unit_names:

  A character vector of names for the second header row (e.g. units of
  measurement). The vector should be the length of the columns excluding
  the year column.

- extent_names:

  A character vector of names for the third header row (e.g. area or
  species names). The vector should be the length of the columns
  excluding the year column.

## Value

A data frame containing the three metadata rows followed by the data
rows that can be saved as a csv.

## Examples

``` r
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
write.csv(final_table, "Biomass_formatted.csv")
```
