#' Title
#' @description
#' This function re-formats data from the "plotIndicatorTimeSeries" csv file format, into a data object that works with plotting functions in the IEAnalyzeR function.
#'
#' @import dplyr
#'
#' @param df Dataset with top 3 rows inlcuding metadata of indicator name, unit, and subcategory.
#' @param trends T/F if you would like the function to calculate trends on this dataset.
#' @param subind How is the data categorized for sub indicators. Options "extent" or "unit".
#' @param window How big is the window for the trend analysis. Default is 5 years.
#'
#' @return An object with 5 datasets used in "plot_fn_obj".
#' @export

data_prep <- function (df,
                       trends = T,
                       subind = FALSE,
                       window = 5)
{
  ### helper function to interpolate across mean for pos/neg ribbon plotting
  poly_fix <- function(x, y, mean){
    d <- data.frame(x = x, y = y)
    rx <- do.call("rbind",
                  sapply(1:(nrow(d)-1), function(i){
                    f <- lm(x ~ y, d[i:(i+1), ])
                    if (f$qr$rank < 2) return(NULL)
                    r <- predict(f, newdata = data.frame(y=mean))
                    if(d[i, ]$x < r & r < d[i+1, ]$x)
                      return(data.frame(x = r, y = mean))
                    else return(NULL)
                  }))
    d2 <- cbind(rx, mean, mean)
    names(d2) <- c("year", "value",'min', 'max')
    return(d2)
  }
  ### end helper function

  ### empty data frame list for output
  df_list <- vector("list", 5)
  names(df_list) <- c("data", "pos", "neg", "labs", "vals")

  ### split input into data and metadata
  df_list$labs <- df[1:3, c(1:ncol(df))]
  df_dat <- df[4:nrow(df), c(1:ncol(df))] |>
    type.convert(as.is = TRUE) ### added else date conversion and trends fail


  # convert dates to standardized format --------------------
  if (class(df_dat[[1]]) == "integer" & all(nchar(df_dat[[1]]) <= 4)) {  # is time column values of years?
    monthly <- FALSE                                # if so, monthly F and set time to year
    df_dat[1] <- df_dat[[1]]
  }  else  {                                        # else need to find and extract month format
    monthly <- TRUE
    # Ensure the first column is character
    df_dat[[1]] <- as.character(df_dat[[1]])

    # Detect format and standardize
    if (all(grepl("^\\d{6}$", df_dat[[1]]))) {
      # Format: YYYYMM (Add '01' for day)
      df_dat[[1]] <- paste0(df_dat[[1]], "01")
      datelis <- as.Date(df_dat[[1]], format = "%Y%m%d")

    } else if (all(grepl("^\\d{8}$", df_dat[[1]]))) {
      # Format: YYYYMMDD (Use as is)
      datelis <- as.Date(df_dat[[1]], format = "%Y%m%d")

    } else if (all(grepl("^\\d{4}-\\d{2}$", df_dat[[1]]))) {
      # Format: YYYY-MM (Add '-01' for day)
      df_dat[[1]] <- paste0(df_dat[[1]], "-01")
      datelis <- as.Date(df_dat[[1]], format = "%Y-%m-%d")

    } else if (all(grepl("^\\d{2}-\\d{4}$", df_dat[[1]]))) {
      # Format: MM-YYYY (Reorder to YYYY-MM and add '-01' for day)
      df_dat[[1]] <- sub("^(\\d{2})-(\\d{4})$", "\\2-\\1-01", df_dat[[1]])
      datelis <- as.Date(df_dat[[1]], format = "%Y-%m-%d")

    } else if (all(grepl("^\\d{4}-\\d{2}-\\d{2}$", df_dat[[1]]))) {
      # Format: YYYY-MM-DD (Use as is)
      datelis <- as.Date(df_dat[[1]], format = "%Y-%m-%d")

    } else if (all(grepl("^[A-Za-z]{3}\\d{4}$", df_dat[[1]]))) {
      # Format: JanYYYY (Add '01' for day)
      datelis <- as.Date(paste0(df_dat[[1]], "01"), format = "%b%Y%d")

    } else if (all(grepl("^\\d{4}[A-Za-z]{3}$", df_dat[[1]]))) {
      # Format: YYYYJan (Add '01' for day)
      datelis <- as.Date(paste0(df_dat[[1]], "01"), format = "%Y%b%d")

    } else {
      datelis <- NA  # Unknown format
    }
  }

  # ptsizadj <- 1 # not used anywhere else nor as an output
  if (monthly==TRUE) { # if monthly, convert to decimal date
    df_dat[1] <- as.numeric(substr(datelis, 1, 4)) + ((as.numeric(strftime(datelis, format = "%j")) - 1) / 365)
    # ptsizadj <- 3
  }


  # Create data frames -------------------------------------------
  if (ncol(df_dat)<3) {
    colnames(df_dat)<-c("year","value")
    df_dat$value<- as.numeric(df_dat$value)
    df_dat$year <- as.numeric(df_dat$year)
    df_dat<-df_dat[!is.na(df_dat$value),]
  } else {
    sub_list<-list()
    for (i in 2:ncol(df_dat)){
      sub_df<-df_dat[,c(1,i)]
      df_lab<-df[1:3,]
      ind<-ifelse(subind=="extent", df_lab[3,i], ifelse(subind=="unit", df_lab[2,i], df_lab[1,i]))
      colnames(sub_df)<-c("year","value")
      sub_df<-as.data.frame(lapply(sub_df, as.numeric))
      sub_df$year <- as.numeric(sub_df$year)
      sub_df$subnm<-paste0(ind)
      sub_df$id<- i-1
      sub_df<-sub_df[!is.na(sub_df$value),]
      sub_list[[i]]<-sub_df
    }
    df_dat<-do.call("rbind",sub_list)
  }
  df_list$data <- df_dat


  ### create dataframes for ribbon plotting
  # inputs: dataframe with year and value
  # outputs: positive ribbon dataframe with year, min=mean, max=value
  #         negative ribbon dataframe with year, min=value, max=mean

  if(ncol(df_dat)<3){
    ribbon <- df_dat[, ]
    mean <- mean(as.numeric(ribbon$value), na.rm = T)
    ribbon$min <- ifelse(ribbon$value >= mean, mean, ribbon$value)
    ribbon$max <- ifelse(ribbon$value >= mean, ribbon$value, mean)
    poly_o <- poly_fix(ribbon$year, ribbon$value, mean)
    ribbon <- rbind(ribbon, poly_o)
    ribbon$mean <- mean
    ribbon <- ribbon[!is.na(ribbon$value),]
  } else {
    sub_list <- list()
    subs <- unique(df_dat$id)
    subnm_un <- unique(select(df_dat, subnm, id))
    for (i in 1:length(subs)){
      ribbon <- df_dat[df_dat$id==subs[i], ]
      mean <- mean(as.numeric(ribbon$value), na.rm = T)
      ribbon$min <- ifelse(ribbon$value >= mean, mean, ribbon$value)
      ribbon$max <- ifelse(ribbon$value >= mean, ribbon$value, mean)
      poly_o <- poly_fix(ribbon$year, ribbon$value, mean)
      poly_o$subnm <- ribbon$subnm[1]
      poly_o$id <- ribbon$id[1]
      ribbon <- rbind(ribbon, poly_o)
      ribbon$mean <- mean
      ribbon <- ribbon[!is.na(ribbon$value),]
      sub_list[[i]] <- ribbon
    }
    ribbon<-do.call("rbind",sub_list)
  }
  df_list$ribbon <- ribbon


  #Independent values used throughout
  if (trends==T) {
    if(ncol(df_dat)<3){
      mean<-mean(as.numeric(df_dat$value), na.rm = T)
      sd<-sd(as.numeric(df_dat$value), na.rm = T)
      minyear<-min(na.omit(df_dat)$year)
      maxyear<-max(na.omit(df_dat)$year)

      #Trend Analysis
      lastn<-df_dat[df_dat$year > max(df_dat$year)- window,]
      #Mean Trend
      lastn_mean<-mean(lastn$value) # mean value last 5 years
      mean_tr<-ifelse(lastn_mean>mean+sd, "ptPlus", ifelse(lastn_mean<mean-sd, "ptMinus","ptSolid")) #qualify mean trend
      mean_sym<-ifelse(lastn_mean>mean+sd, "+", ifelse(lastn_mean<mean-sd, "-","●")) #qualify mean trend
      mean_word<-ifelse(lastn_mean>mean+sd, "greater", ifelse(lastn_mean<mean-sd, "below","within")) #qualify mean trend

      #Slope Trend
      lmout<-summary(lm(lastn$value~lastn$year))
      lastn_slope<-coef(lmout)[2,1] * 5 #multiply by years in the trend (slope per year * number of years=rise over 5 years)
      slope_tr<-ifelse(lastn_slope>sd, "arrowUp", ifelse(lastn_slope< c(-sd), "arrowDown","arrowRight"))
      slope_sym<-ifelse(lastn_slope>sd, "↑", ifelse(lastn_slope< c(-sd), "↓","→"))
      slope_word<-ifelse(lastn_slope>sd, "an increasing", ifelse(lastn_slope< c(-sd), "a decreasing","a stable"))

      #Dataframe
      vals<-data.frame(mean=mean,
                       sd=sd,
                       minyear=minyear,
                       maxyear=maxyear,
                       mean_tr=mean_tr,
                       slope_tr=slope_tr,
                       mean_sym=mean_sym,
                       slope_sym=slope_sym,
                       mean_word=mean_word,
                       slope_word=slope_word)
    } else {
      sub_list<-list()
      subnm_un<-unique(select(df_dat, subnm, id))
      subs<-unique(df_dat$id)
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$id==subs[i],]
        minyear<-min(na.omit(sub_df)$year)
        maxyear<-max(na.omit(sub_df)$year)
        allminyear<-min(df_dat$year)
        allmaxyear<-max(df_dat$year)
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)

        #Trend Analysis
        lastn <- sub_df[sub_df$year > max(sub_df$year) - window,]
        #Mean Trend
        lastn_mean<-mean(lastn$value) # mean value last 5 years
        mean_tr<-ifelse(lastn_mean>mean+sd, "ptPlus", ifelse(lastn_mean<mean-sd, "ptMinus","ptSolid")) #qualify mean trend
        mean_sym<-ifelse(lastn_mean>mean+sd, "+", ifelse(lastn_mean<mean-sd, "-","●")) #qualify mean trend
        mean_word<-ifelse(lastn_mean>mean+sd, "greater", ifelse(lastn_mean<mean-sd, "below","within")) #qualify mean trend

        #Slope Trend
        lmout<-summary(lm(lastn$value~lastn$year))
        lastn_slope<-coef(lmout)[2,1] * 5 #multiply by years in the trend (slope per year * number of years=rise over 5 years)
        slope_tr<-ifelse(lastn_slope>sd, "arrowUp", ifelse(lastn_slope< c(-sd), "arrowDown","arrowRight"))
        slope_sym<-ifelse(lastn_slope>sd, "↑", ifelse(lastn_slope< c(-sd), "↓","→"))
        slope_word<-ifelse(lastn_slope>sd, "an increasing", ifelse(lastn_slope< c(-sd), "a decreasing","a stable"))

        vals<-data.frame(allminyear=allminyear,
                         allmaxyear=allmaxyear,
                         minyear=minyear,
                         maxyear=maxyear,
                         mean=mean,
                         sd=sd,
                         mean_tr=mean_tr,
                         slope_tr=slope_tr,
                         mean_sym=mean_sym,
                         slope_sym=slope_sym,
                         mean_word=mean_word,
                         slope_word=slope_word,
                         subnm=subnm_un[i,1],
                         id=unique(sub_df$id))
        sub_list[[i]]<-vals
      }
      vals<-do.call("rbind",sub_list)
    }
    df_list$vals<-vals
  }
  df_list
}
