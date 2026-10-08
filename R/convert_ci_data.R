#' Title
#' @description
#' Convert confidence interval data to replicate the format from main value data after using the function [convert_cleaned_data()]. You must use the same indicator, unit, and extent names and the main values with the correlating data in the same column order. This does not calculate confidence intervals, only reformats for use with other functions in IEAnalyzeR.
#'
#'
#' @param lowerCI_df A dataframe containing the year/time column and the lower bounds of your confidence intervals
#' @param upperCI_df A dataframe containing the year/time column and the upper bounds of your confidence intervals
#' @param indicator_names A character vector of names for the top most header row (the name of the indicator). The vector should be the length of the columns excluding the year column and should match those used in [convert_cleaned_data()] for the main values.
#' @param unit_names A character vector of names for the second header row (e.g. units of measurement). The vector should be the length of the columns excluding the year column and should match those used in [convert_cleaned_data()] for the main values.
#' @param extent_names A character vector of names for the third header row (e.g. area or species names). The vector should be the length of the columns excluding the year column and should match those used in [convert_cleaned_data()] for the main values.
#'
#' @returns A list of two dataframes (upper & lower bounds) that can be input in the [data_prep()] function.
#'
#' @examples
#' # 1. Define dummy data
#' lower_ci <- data.frame(
#'  year = 2000:2004,
#'   bio_spec1 = c(2, 8, 1, 4, 9),
#'   bio_spec2 = c(5, 2, 5, 6, 10)
#' )
#'
#' upper_ci <- data.frame(
#'   year = 2000:2004,
#'   bio_spec1 = c(8, 12, 6, 9, 15),
#'   bio_spec2 = c(9, 6, 10, 11, 14)
#' )
#'
#' # 2. Define header components for the data rows (ignore year)
#' indicator_names <- c("Biomass", "Biomass")
#' unit_names <- c("Count", "Count")
#' extent_names <- c("species A", "species B")
#'
#' # 3. Call the function
#' ci_df <- convert_ci_data(lowerCI_df = lower_ci, upperCI_df = upper_ci,
#'                          indicator_names = indicator_names,
#'                          unit_names = unit_names,
#'                          extent_names = extent_names)
#' @export


convert_ci_data<-function(lowerCI_df, upperCI_df, indicator_names, unit_names, extent_names){
  ci_list<-list()

  lower_dat<-convert_cleaned_data(lowerCI_df, indicator_names, unit_names, extent_names)
  upper_dat<-convert_cleaned_data(upperCI_df, indicator_names, unit_names, extent_names)

  ci_list$lower<-lower_dat
  ci_list$upper<-upper_dat
  return(ci_list)
}
