#' Convert cleaned indicator dataset to indicator data format (with metadata rows)
#'
#' This function takes a numeric data frame with year as column 1 and metric values in the remaining columns and combines it with three vectors representing different levels of header metadata (indicator, unit, and extent/sub-indicator). It returns a single data frame that once saved as a csv is in the correct format for ingestion into the IEAnalyzeR data_prep function.
#'
#' @param data A data frame or matrix containing numeric data only.
#' @param indicator_names A character vector of names for the top most header row (the name of the indicator). The vector should be the length of the columns excluding the year column.
#' @param unit_names A character vector of names for the second header row (e.g. units of measurement). The vector should be the length of the columns excluding the year column.
#' @param extent_names A character vector of names for the third header row (e.g. area or species names). The vector should be the length of the columns excluding the year column.
#'
#' @returns A data frame containing the three metadata rows followed by the data rows that can be saved as a csv.
#'
#' @examples
#' # 1. Define dummy data
#' dat <- data.frame(
#'   year = 2000:2004,
#'   bio_spec1 = c(5, 10, 3, 7, 11),
#'   bio_spec2 = c(7, 3, 8, 8, 12)
#' )
#'
#' # 2. Define header components for the data rows (ignore year)
#' indicator_names <- c("Biomass", "Biomass")
#' unit_names <- c("Count", "Count")
#' extent_names <- c("species A", "species B")
#'
#' # 3. Call the function
#' final_table <- convert_cleaned_data(dat, indicator_names, unit_names, extent_names)
#' write.csv(final_table, "Biomass_formatted.csv")
#' @export
convert_cleaned_data <- function(data, indicator_names, unit_names, extent_names){

  num_cols <- ncol(data)
  if (length(indicator_names) != num_cols-1 || length(unit_names) != num_cols-1 || length(extent_names) != num_cols-1) {
    stop(paste("Error: All header vectors must have a length of", num_cols-1, "(the number of columns in the data minus the year column)."))
  }

  data_matrix <- as.matrix(data)
  colnames(data_matrix) <- NULL

  data_block <- rbind(
    c("unit", unit_names),
    c("extent", extent_names),
    data_matrix
  )

  colnames(data_block) <- c("indicator", indicator_names)

  formatted_data <- as.data.frame(data_block, stringsAsFactors = FALSE)
  rownames(formatted_data) <- NULL

  return(formatted_data)

}
