#' @title Generate a summary table of time series indicator trends.
#' @description This function processes time series data, performs trend analysis, and creates a formatted summary table.
#' @param folder_path A character string specifying the path to the folder.
#' @param stmon_inds A character vector of indicator names for standardized monthly anomaly calculation.
#' @param min_max_year An integer specifying the minimum value for the "Max year" column to filter the results.
#' @param include_gt A logical value. If TRUE, a gt table is returned; otherwise, a data frame is returned.
#' @return A gt table or a data frame summarizing the trend analysis results.
#' @importFrom tidyverse filter
#' @importFrom gt gt
#' @examples
#' # table = create_trend_table(folder_path = "path/to/your/data/folder", stmon_inds = c("My_Indicator_1", "My_Indicator_2"), min_max_year = 2020)
#' # print(table)
#' @export

create_trend_table <- function(
    folder_path = "indicator_objects/objects_as_csvs/",
    stmon_inds = c("Carib_SST", "turbidity", "carib_Chl"),
    min_max_year = 2022,
    include_gt = TRUE
) {

  # Step 1: Load and process all CSV files
  csv_files <- list.files(path = folder_path, pattern = "\\.csv$", full.names = TRUE)
  if (length(csv_files) == 0) {
    stop("No CSV files found in the specified folder path.")
  }

  ind_list <- list()

  for (file in csv_files) {
    file_name <- tools::file_path_sans_ext(basename(file))
    data <- read.csv(file, check.names = FALSE)

    processed_data <- NULL

    if (file_name %in% stmon_inds) {
      processed_data <- tryCatch({
        IEAnalyzeR::data_prep(data, anomaly = "stdmonthly")
      }, warning = function(w) {
        message("Warning in file: ", file_name, " - ", conditionMessage(w))
        return(NULL)
      }, error = function(e) {
        message("Error in file: ", file_name, " - ", conditionMessage(e))
        return(NULL)
      })
    } else {
      processed_data <- tryCatch({
        IEAnalyzeR::data_prep(data)
      }, warning = function(w) {
        message("Warning in file: ", file_name, " - ", conditionMessage(w))
        return(NULL)
      }, error = function(e) {
        message("Error in file: ", file_name, " - ", conditionMessage(e))
        return(NULL)
      })
    }

    if (!is.null(processed_data)) {
      ind_list[[file_name]] <- processed_data
    }
  }

  # Step 2: Make the trend analysis summary table
  sum_list <- list()

  for (df in ind_list) {
    # Check for sub-indicators
    if (ncol(df$labs) > 2) {
      indic_title <- df$labs[1, 2:ncol(df$labs)]
      sub_titles1 <- df$labs[2, 2:ncol(df$labs)]
      sub_titles2 <- df$labs[3, 2:ncol(df$labs)]
    } else {
      indic_title <- df$labs[1, 2]
      sub_titles1 <- df$labs[2, 2]
      sub_titles2 <- NA
    }

    # Clean up titles and values
    indic_title <- gsub("\\.", " ", indic_title)
    sub_titles1 <- gsub("\\.", " ", sub_titles1)
    if (all(!is.na(sub_titles2))) {
      sub_titles2 <- gsub("\\.", " ", sub_titles2)
    } else {
      sub_titles2 <- "Caribbean"
    }

    trend_sym <- df$vals$mean_sym
    slope_sym <- df$vals$slope_sym
    mean_vals <- round(df$vals$mean, 2)
    sd_vals <- round(df$vals$sd, 2)
    minyear <- round(df$vals$minyear, 0)
    maxyear <- round(df$vals$maxyear, 0)

    # Combine into a list of vectors
    for (j in seq_along(mean_vals)) {
      all_dat <- c(
        indic_title[j],
        sub_titles1[j],
        sub_titles2[j],
        trend_sym[j],
        slope_sym[j],
        mean_vals[j],
        sd_vals[j],
        minyear[j],
        maxyear[j]
      )
      sum_list[[length(sum_list) + 1]] <- all_dat
    }
  }

  if (length(sum_list) == 0) {
    return(NULL) # Return NULL if no data was processed
  }

  # Convert list to data frame and set column names
  sum_table <- as.data.frame(do.call("rbind", sum_list), stringsAsFactors = FALSE)
  colnames(sum_table) <- c(
    "Indicator", "Units", "Extent/sub-indicator", "Trend symbol", "Slope symbol",
    "Mean", "SD", "Min year", "Max year"
  )

  # Step 3: Apply filtering
  sum_table <- sum_table %>%
    mutate(`Max year` = as.numeric(`Max year`)) %>%
    filter(`Max year` >= min_max_year) %>%
    drop_na(`Trend symbol`)

  if (include_gt) {
    # Step 4: Create the gt table
    gt_table <- sum_table %>%
      gt() %>%
      tab_row_group(
        label = "Recent trend is average",
        rows = `Trend symbol` == "●"
      ) %>%
      tab_row_group(
        label = "Recent trend below average",
        rows = `Trend symbol` == "-"
      ) %>%
      tab_row_group(
        label = "Recent trend above average",
        rows = `Trend symbol` == "+"
      ) %>%
      tab_style(
        style = cell_text(weight = "bold"),
        locations = cells_column_labels()
      ) %>%
      cols_label(Indicator = "") %>%
      tab_style(
        style = cell_borders(
          sides = "right",
          color = "light gray",
          weight = px(2)
        ),
        locations = cells_body(columns = c(Indicator))
      ) %>%
      tab_options(row_group.background.color = "lightgrey")

    return(gt_table)
  } else {
    return(sum_table)
  }
}
