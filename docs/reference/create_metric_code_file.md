# Title

This function creates a file within the Gulf IEA repo framework. This
file outlines how you should code a metric that will be included in Gulf
IEA ESR's and associated products. Should only be used within a repo
created from the "ESR-Report-Template".

## Usage

``` r
create_metric_code_file(
  metric_root_name,
  format = c("R", "qmd"),
  data_type = c("automated", "non-automated", "confidential"),
  override = F
)
```

## Arguments

- metric_root_name:

  The official root name of the metric to be coded.

- format:

  The filetype you would like created to code your metric. R or QMD
  files are supported.

- data_type:

  The type of accessibility of your data. Automated data are those that
  come from sources like APIs, non-automated data come from manually
  acquiring the data through csvs etc., and confidential data are those
  should not be hosted anywhere publically.

## Value

A file in the appropriate folder of the ESR repository where all coding
for analyzing a metric should be executed.
