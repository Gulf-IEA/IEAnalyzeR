#' Title
#' @description
#' This function creates a file within the Gulf IEA repo framework. This file outlines how you should code a metric that will be included in Gulf IEA ESR's and associated products. Should only be used within a repo created from the "ESR-Report-Template".
#'
#' @import here
#'
#' @param metric_root_name The official root name of the metric to be coded.
#' @param format The filetype you would like created to code your metric. R or QMD files are supported.
#' @param data_type The type of accessibility of your data. Automated data are those that come from sources like APIs, non-automated data come from manually acquiring the data through csvs etc., and confidential data are those should not be hosted anywhere publically.
#'
#' @return A file in the appropriate folder of the ESR repository where all coding for analyzing a metric should be executed.
#' @export

create_metric_code_file <- function(metric_root_name,
                                    format = c("R", "qmd"),
                                    data_type= c("automated", "non-automated", "confidential")) {

  out_dir = here::here("testing")
  template_dir = here::here("testing")

  # Standardize filetype to lowercase so input is NOT case sensitive
  format <- tolower(format[1])

  if (!format %in% c("r", "qmd")) {
    stop('Format must be "R" or "qmd" (any capitalization works)')
  }

  # Construct file names
  file_name <- paste0(metric_root_name, "_code.", format)
  file_path <- file.path(out_dir, file_name)

  # Path to template
  template_file <- file.path(template_dir, paste0("metric_code_template.", format))

  if (!file.exists(template_file)) {
    stop("Template file not found: ", template_file)
  }

  # Read template
  template <- readLines(template_file)

  # Replace placeholder with actual indicator name
  template <- gsub("WILL CHANGE WHEN CREATED", metric_root_name, template)

  # Add a timestamp header
  template <- gsub("FILE CREATION DATE", Sys.Date(), template)


  # Write out
  writeLines(template, file_path)

  message("Template created: ", file_path)
  invisible(file_path)
}
