# Title

This function plots an indicator time series figure from data that is
formated from the "data_prep" function in IEAnalyzeR.

## Usage

``` r
plot_fn_obj(
  df_obj,
  interactive = FALSE,
  sep_ylabs = F,
  ylab_sublabel = NULL,
  facet_scales = "free",
  ncol = NULL,
  manual_ylab = NULL,
  manual_xlab = NULL,
  manual_title = NULL,
  lwd = 0.75,
  pts = F,
  pt_size = 0.75,
  fig.width = 6,
  facet_grid = F,
  xbreaks_by = NULL,
  trend = F
)
```

## Arguments

- df_obj:

  Data object produced by the "data_prep" function.

- interactive:

  Run plot through plotly to create an interactive version of the plot.

- sep_ylabs:

  Uses facet_wrap to allow the subplots to have separate y-axis labels.
  Only works for indicators that are one column and are multi.

- ylab_sublabel:

  This argument creates a sublabel for the y-axis by choosing two of the
  three label types. Label types include “indicator”, “unit”, and
  “extent”.

- facet_scales:

  Derived from facet_wrap scales argument : Should scales be fixed
  ("fixed", the default), free ("free"), or free in one dimension
  ("free_x", "free_y")? This controls the share vs “free” axis per panel
  in a faceted plot.

- ncol:

  How many columns should be in the faceted figure?

- manual_ylab:

  Manual y axis title. List multiple ylabs in order of appearance for
  figure with subindicators.

- manual_xlab:

  Manual x axis title.

- manual_title:

  Manual overall plot/plots title.

- lwd:

  Adjust the thickness of the timeseries line.

- pts:

  T/F Would you like points where the data are on top of the timeseries
  line.

- pt_size:

  What size would you like the points on the graph if pts=T?

- fig.width:

  The intended width of saved figure. Is necessary for proper spacing if
  using trend symbol on final plot whether saving through the function
  or separately.

- facet_grid:

  Used if you need a subset of plots organized by two categories of
  labels. T defaults to unit by extent, or can specify two out of the
  three ("indicator","unit","extent")

- xbreaks_by:

  Specify the interval that the x axis breaks occur.

- trend:

  Do you want to include trend symbols (mean & slope) on the side of the
  plots.

## Value

A plot in the indicatorTimeSeries format.
