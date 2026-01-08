# Generate a summary table of time series indicator trends.

This function processes time series data, performs trend analysis, and
creates a formatted summary table.

## Usage

``` r
create_trend_table(
  folder_path = "indicator_objects/objects_as_csvs/",
  stmon_inds = NULL,
  min_max_year = 0,
  include_gt = TRUE
)
```

## Arguments

- folder_path:

  A character string specifying the path to the folder.

- stmon_inds:

  A character vector of indicator names for standardized monthly anomaly
  calculation.

- min_max_year:

  An integer specifying the minimum value for the "Max year" column to
  filter the results.

- include_gt:

  A logical value. If TRUE, a gt table is returned; otherwise, a data
  frame is returned.

## Value

A gt table or a data frame summarizing the trend analysis results.

## Examples

``` r
# For a real-world example, you would replace "path/to/your/data/folder"
# with the actual path to your data.
#
# # Assuming a folder "indicator_objects/objects_as_csvs/" exists with data
# # table <- create_trend_table(folder_path = "indicator_objects/objects_as_csvs/",
# #                              stmon_inds = c("Carib_SST", "turbidity", "carib_Chl"),
# #                              min_max_year = 2022)
# # print(table)
```
