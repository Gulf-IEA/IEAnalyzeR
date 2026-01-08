# Title

This function re-formats data from the "plotIndicatorTimeSeries" csv
file format, into a data object that works with plotting functions in
the IEAnalyzeR function.

## Usage

``` r
data_prep(df, trends = T, subind = FALSE, anomaly = NULL)
```

## Arguments

- df:

  Dataset with top 3 rows inlcuding metadata of indicator name, unit,
  and subcategory.

- trends:

  T/F if you would like the function to calculate trends on this
  dataset.

- subind:

  How is the data categorized for sub indicators. Options "extent" or
  "unit".

- anomaly:

  Calculate and replace values with either "monthly" or "stdmonthly"
  values

## Value

An object with datasets used in "plot_fn_obj".
