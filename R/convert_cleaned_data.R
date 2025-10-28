#' Convert cleaned indicator dataset to indicator data format (with metadata rows)
#'
#' This function takes a numeric data frame with year as column 1 and metric values in the remaining columns and combines it with three vectors representing different levels of header metadata (indicator, unit, and extent/sub-indicator). It returns a single data frame that is in the correct format for ingestion into the IEAnalyzeR data_prep function.
#'
#' @param data A data frame or matrix containing numeric data only.
#' @param indicator_names A character vector of names for the top most header row (the name of the indicator). The first name corresponding to year should be blank.
#' @param unit_names A character vector of names for the second header row (e.g. units of measurement).
#' @param extent_names A character vector of names for the third header row (e.g. area or species names).
#'
#' @returns A data frame containing the three metadata rows followed by the data rows.
#'
#' @examples
#' # 1. Define dummy data
#' dat <- data.frame(
#'   year = 2000:2004,
#'   bio_spec1 = c(5, 10, 3, 7, 11),
#'   bio_spec2 = c(7, 3, 8, 8, 12)
#' )
#'
#' # 2. Define ALL header components, starting with "" for the 'year' column
#' indicator_names <- c("", "Biomass", "Biomass")
#' unit_names <- c("", "Count", "Count")
#' extent_names <- c("", "species A", "species B")
#'
#' # 3. Call the function
#' final_table <- convert_csv(dat, indicator_names, unit_names, extent_names)
#' print(final_table)
#' @export
convert_cleaned_data <- function(data, indicator_names, unit_names, extent_names){

  num_cols <- ncol(data)
  if (length(indicator_names) != num_cols || length(unit_names) != num_cols || length(extent_names) != num_cols) {
    stop(paste("Error: All header vectors must have a length of", num_cols, "(the number of columns in the data)."))
  }

  if (indicator_names[1] != "" || unit_names[1] != "" || extent_names[1] != "") {
    stop("Error: The first element of 'indicator_names', 'unit_names', and 'extent_names' must be an empty string (\"\") to leave the first column header blank.")
  }

  data_matrix <- as.matrix(data)
  colnames(data_matrix) <- NULL

  data_block <- rbind(
    indicator_names,
    unit_names,
    extent_names,
    data_matrix
  )

  colnames(data_block) <- NULL

  formatted_data <- as.data.frame(data_block, stringsAsFactors = FALSE)
  rownames(formatted_data) <- NULL

  return(formatted_data)

}
