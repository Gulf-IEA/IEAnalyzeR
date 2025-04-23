#' Title
#' @description
#' This function re-formats data from the "plotIndicatorTimeSeries" csv file format, into a data object that works with plotting functions in the IEAnalyzeR function.
#'
#' @import dplyr
#'
#' @param df Dataset with top 3 rows inlcuding metadata of indicator name, unit, and subcategory.
#' @param trends T/F if you would like the function to calculate trends on this dataset.
#' @param subind How is the data categorized for sub indicators. Options "extent" or "unit".
#'
#' @return An object with 5 datasets used in "plot_fn_obj".
#' @export

data_prep <-function (df, trends = T, subind = FALSE){
  df_list<-vector("list", 5)
  names(df_list)<-c("data", "pos", "neg", "labs", "vals")

  #Data used for everything
  df_dat<-df[4:nrow(df),c(1:ncol(df))]#' Title
#' @description
#' This function re-formats data from the "plotIndicatorTimeSeries" csv file format, into a data object that works with plotting functions in the IEAnalyzeR function.
#'
#' @import dplyr
#'
#' @param df Dataset with top 3 rows inlcuding metadata of indicator name, unit, and subcategory.
#' @param trends T/F if you would like the function to calculate trends on this dataset.
#' @param subind How is the data categorized for sub indicators. Options "extent" or "unit".
#'
#' @return An object with 5 datasets used in "plot_fn_obj".
#' @export

data_prep <-function (df, trends = T, subind = FALSE){
  df_list<-vector("list", 5)
  names(df_list)<-c("data", "pos", "neg", "labs", "vals")

  #Data used for everything
  df_dat<-df[4:nrow(df),c(1:ncol(df))] |>
    type.convert(as.is = TRUE) ### BDT added to make it work

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

  ptsizadj <- 1
  if (monthly==TRUE) {                                  # if monthly, convert to decimal date
    df_dat[1] <- as.numeric(substr(datelis, 1, 4)) + ((as.numeric(strftime(datelis, format = "%j")) - 1) / 365)
    ptsizadj <- 3
  }


  # Create data frames -------------------------------------------
  if (ncol(df_dat)<2.5) {
    colnames(df_dat)<-c("year","value")
    df_dat$value<- as.numeric(df_dat$value)

    mean<-mean(as.numeric(df_dat$value), na.rm = T)
    sd<-sd(as.numeric(df_dat$value), na.rm = T)

    df_dat$valence[df_dat$value>=mean]<-"pos"
    df_dat$valence[df_dat$value< mean]<-"neg"
    df_dat$min <- ifelse(df_dat$value >= mean, mean, df_dat$value)
    df_dat$max <- ifelse(df_dat$value >= mean, df_dat$value, mean)
    df_dat$year <- as.numeric(df_dat$year)
    df_dat<-df_dat[!is.na(df_dat$value),]
    df_dat} else {

      sub_list<-list()
      for (i in 2:ncol(df_dat)){
        sub_df<-df_dat[,c(1,i)]
        df_lab<-df[1:3,]
        ind<-ifelse(subind=="extent", df_lab[3,i], ifelse(subind=="unit", df_lab[2,i], df_lab[1,i]))


        colnames(sub_df)<-c("year","value")
        sub_df<-as.data.frame(lapply(sub_df, as.numeric))

        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)

        sub_df$valence[sub_df$value>=mean]<-"pos"
        sub_df$valence[sub_df$value< mean]<-"neg"
        sub_df$min <- ifelse(sub_df$value >= mean, mean, sub_df$value)
        sub_df$max <- ifelse(sub_df$value >= mean, sub_df$value, mean)
        sub_df$year <- as.numeric(sub_df$year)
        sub_df$subnm<-paste0(ind)
        sub_df$id<-i-1
        sub_df<-sub_df[!is.na(sub_df$value),]
        sub_list[[i]]<-sub_df

      }
      df_dat<-do.call("rbind",sub_list)
    }
  df_list$data<-df_dat


  #Pos data set used for main plot

  if(ncol(df_dat)<6){
    mean<-mean(as.numeric(df_dat$value), na.rm = T)
    sd<-sd(as.numeric(df_dat$value), na.rm = T)
    pos<-df_dat
    pos$value<-ifelse(pos$valence == "pos",pos$value, mean)
    pos$mean<-mean
    pos$sd<-sd
    pos<-pos[!is.na(pos$value),]
    pos} else {
      sub_list<-list()
      subs<-unique(df_dat$id)
      subnm_un<-unique(select(df_dat, subnm, id))
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$id==subs[i],]
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)
        pos<-sub_df
        pos$value<-ifelse(pos$valence == "pos",pos$value, mean)
        pos$subnm<-subnm_un[i,1]
        pos$mean<-mean
        pos$sd<-sd
        pos<-pos[!is.na(pos$value),]
        sub_list[[i]]<-pos
      }
      pos<-do.call("rbind",sub_list)
    }
  df_list$pos<-pos


  #Neg data set used for main plot
  if(ncol(df_dat)<6){
    mean<-mean(as.numeric(df_dat$value), na.rm = T)
    sd<-sd(as.numeric(df_dat$value), na.rm = T)
    neg<-df_dat
    neg$value<-ifelse(neg$valence == "neg",neg$value, mean)
    neg$mean<-mean
    neg$sd<-sd
    neg<-neg[!is.na(neg$value),]
    neg} else {
      sub_list<-list()
      subs<-unique(df_dat$id)
      subnm_un<-unique(select(df_dat, subnm, id))
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$id==subs[i],]
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)
        neg<-sub_df
        neg$value<-ifelse(neg$valence == "neg",neg$value, mean)
        neg$subnm<-subnm_un[i,1]
        neg$mean<-mean
        neg$sd<-sd
        neg<-neg[!is.na(neg$value),]
        sub_list[[i]]<-neg
      }
      neg<-do.call("rbind",sub_list)
    }
  df_list$neg<-neg

  df_list$labs<-df[1:3, c(1:ncol(df))]

  #Independent values used throughout
  if (trends==T) {
    if(ncol(df_dat)<6){
      mean<-mean(as.numeric(df_dat$value), na.rm = T)
      sd<-sd(as.numeric(df_dat$value), na.rm = T)
      minyear<-min(na.omit(df_dat)$year)
      maxyear<-max(na.omit(df_dat)$year)

      #Trend Analysis
      last5<-df_dat[df_dat$year > max(df_dat$year)-5,]
      #Mean Trend
      last5_mean<-mean(last5$value) # mean value last 5 years
      mean_tr<-if_else(last5_mean>mean+sd, "ptPlus", if_else(last5_mean<mean-sd, "ptMinus","ptSolid")) #qualify mean trend
      mean_sym<-if_else(last5_mean>mean+sd, "+", if_else(last5_mean<mean-sd, "-","●")) #qualify mean trend
      mean_word<-if_else(last5_mean>mean+sd, "greater", if_else(last5_mean<mean-sd, "below","within")) #qualify mean trend

      #Slope Trend
      lmout<-summary(lm(last5$value~last5$year))
      last5_slope<-coef(lmout)[2,1] * 5 #multiply by years in the trend (slope per year * number of years=rise over 5 years)
      slope_tr<-if_else(last5_slope>sd, "arrowUp", if_else(last5_slope< c(-sd), "arrowDown","arrowRight"))
      slope_sym<-if_else(last5_slope>sd, "↑", if_else(last5_slope< c(-sd), "↓","→"))
      slope_word<-if_else(last5_slope>sd, "an increasing", if_else(last5_slope< c(-sd), "a decreasing","a stable"))

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
      vals} else {
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
          last5<-sub_df[sub_df$year > max(sub_df$year)-5,]
          #Mean Trend
          last5_mean<-mean(last5$value) # mean value last 5 years
          mean_tr<-if_else(last5_mean>mean+sd, "ptPlus", if_else(last5_mean<mean-sd, "ptMinus","ptSolid")) #qualify mean trend
          mean_sym<-if_else(last5_mean>mean+sd, "+", if_else(last5_mean<mean-sd, "-","●")) #qualify mean trend
          mean_word<-if_else(last5_mean>mean+sd, "greater", if_else(last5_mean<mean-sd, "below","within")) #qualify mean trend

          #Slope Trend
          lmout<-summary(lm(last5$value~last5$year))
          last5_slope<-coef(lmout)[2,1] * 5 #multiply by years in the trend (slope per year * number of years=rise over 5 years)
          slope_tr<-if_else(last5_slope>sd, "arrowUp", if_else(last5_slope< c(-sd), "arrowDown","arrowRight"))
          slope_sym<-if_else(last5_slope>sd, "↑", if_else(last5_slope< c(-sd), "↓","→"))
          slope_word<-if_else(last5_slope>sd, "an increasing", if_else(last5_slope< c(-sd), "a decreasing","a stable"))

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

  ptsizadj <- 1
  if (monthly==TRUE) {                                  # if monthly, convert to decimal date
    df_dat[1] <- as.numeric(substr(datelis, 1, 4)) + ((as.numeric(strftime(datelis, format = "%j")) - 1) / 365)
    ptsizadj <- 3
  }


  # Create data frames -------------------------------------------
  if (ncol(df_dat)<2.5) {
    colnames(df_dat)<-c("year","value")
    df_dat$value<- as.numeric(df_dat$value)

    mean<-mean(as.numeric(df_dat$value), na.rm = T)
    sd<-sd(as.numeric(df_dat$value), na.rm = T)

    df_dat$valence[df_dat$value>=mean]<-"pos"
    df_dat$valence[df_dat$value< mean]<-"neg"
    df_dat$min <- ifelse(df_dat$value >= mean, mean, df_dat$value)
    df_dat$max <- ifelse(df_dat$value >= mean, df_dat$value, mean)
    df_dat$year <- as.numeric(df_dat$year)
    df_dat<-df_dat[!is.na(df_dat$value),]
    df_dat} else {

      sub_list<-list()
      for (i in 2:ncol(df_dat)){
        sub_df<-df_dat[,c(1,i)]
        df_lab<-df[1:3,]
        ind<-ifelse(subind=="extent", df_lab[3,i], ifelse(subind=="unit", df_lab[2,i], df_lab[1,i]))


        colnames(sub_df)<-c("year","value")
        sub_df<-as.data.frame(lapply(sub_df, as.numeric))

        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)

        sub_df$valence[sub_df$value>=mean]<-"pos"
        sub_df$valence[sub_df$value< mean]<-"neg"
        sub_df$min <- ifelse(sub_df$value >= mean, mean, sub_df$value)
        sub_df$max <- ifelse(sub_df$value >= mean, sub_df$value, mean)
        sub_df$year <- as.numeric(sub_df$year)
        sub_df$subnm<-paste0(ind)
        sub_df$id<-i-1
        sub_df<-sub_df[!is.na(sub_df$value),]
        sub_list[[i]]<-sub_df

      }
      df_dat<-do.call("rbind",sub_list)
    }
  df_list$data<-df_dat


  #Pos data set used for main plot

  if(ncol(df_dat)<6){
    mean<-mean(as.numeric(df_dat$value), na.rm = T)
    sd<-sd(as.numeric(df_dat$value), na.rm = T)
    pos<-df_dat
    pos$value<-ifelse(pos$valence == "pos",pos$value, mean)
    pos$mean<-mean
    pos$sd<-sd
    pos<-pos[!is.na(pos$value),]
    pos} else {
      sub_list<-list()
      subs<-unique(df_dat$id)
      subnm_un<-unique(select(df_dat, subnm, id))
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$id==subs[i],]
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)
        pos<-sub_df
        pos$value<-ifelse(pos$valence == "pos",pos$value, mean)
        pos$subnm<-subnm_un[i,1]
        pos$mean<-mean
        pos$sd<-sd
        pos<-pos[!is.na(pos$value),]
        sub_list[[i]]<-pos
      }
      pos<-do.call("rbind",sub_list)
    }
  df_list$pos<-pos


  #Neg data set used for main plot
  if(ncol(df_dat)<6){
    mean<-mean(as.numeric(df_dat$value), na.rm = T)
    sd<-sd(as.numeric(df_dat$value), na.rm = T)
    neg<-df_dat
    neg$value<-ifelse(neg$valence == "neg",neg$value, mean)
    neg$mean<-mean
    neg$sd<-sd
    neg<-neg[!is.na(neg$value),]
    neg} else {
      sub_list<-list()
      subs<-unique(df_dat$id)
      subnm_un<-unique(select(df_dat, subnm, id))
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$id==subs[i],]
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)
        neg<-sub_df
        neg$value<-ifelse(neg$valence == "neg",neg$value, mean)
        neg$subnm<-subnm_un[i,1]
        neg$mean<-mean
        neg$sd<-sd
        neg<-neg[!is.na(neg$value),]
        sub_list[[i]]<-neg
      }
      neg<-do.call("rbind",sub_list)
    }
  df_list$neg<-neg

  df_list$labs<-df[1:3, c(1:ncol(df))]

  #Independent values used throughout
  if (trends==T) {
    if(ncol(df_dat)<6){
      mean<-mean(as.numeric(df_dat$value), na.rm = T)
      sd<-sd(as.numeric(df_dat$value), na.rm = T)
      minyear<-min(na.omit(df_dat)$year)
      maxyear<-max(na.omit(df_dat)$year)

      #Trend Analysis
      last5<-df_dat[df_dat$year > max(df_dat$year)-5,]
      #Mean Trend
      last5_mean<-mean(last5$value) # mean value last 5 years
      mean_tr<-if_else(last5_mean>mean+sd, "ptPlus", if_else(last5_mean<mean-sd, "ptMinus","ptSolid")) #qualify mean trend
      mean_sym<-if_else(last5_mean>mean+sd, "+", if_else(last5_mean<mean-sd, "-","●")) #qualify mean trend
      mean_word<-if_else(last5_mean>mean+sd, "greater", if_else(last5_mean<mean-sd, "below","within")) #qualify mean trend

      #Slope Trend
      lmout<-summary(lm(last5$value~last5$year))
      last5_slope<-coef(lmout)[2,1] * 5 #multiply by years in the trend (slope per year * number of years=rise over 5 years)
      slope_tr<-if_else(last5_slope>sd, "arrowUp", if_else(last5_slope< c(-sd), "arrowDown","arrowRight"))
      slope_sym<-if_else(last5_slope>sd, "↑", if_else(last5_slope< c(-sd), "↓","→"))
      slope_word<-if_else(last5_slope>sd, "an increasing", if_else(last5_slope< c(-sd), "a decreasing","a stable"))

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
      vals} else {
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
          last5<-sub_df[sub_df$year > max(sub_df$year)-5,]
          #Mean Trend
          last5_mean<-mean(last5$value) # mean value last 5 years
          mean_tr<-if_else(last5_mean>mean+sd, "ptPlus", if_else(last5_mean<mean-sd, "ptMinus","ptSolid")) #qualify mean trend
          mean_sym<-if_else(last5_mean>mean+sd, "+", if_else(last5_mean<mean-sd, "-","●")) #qualify mean trend
          mean_word<-if_else(last5_mean>mean+sd, "greater", if_else(last5_mean<mean-sd, "below","within")) #qualify mean trend

          #Slope Trend
          lmout<-summary(lm(last5$value~last5$year))
          last5_slope<-coef(lmout)[2,1] * 5 #multiply by years in the trend (slope per year * number of years=rise over 5 years)
          slope_tr<-if_else(last5_slope>sd, "arrowUp", if_else(last5_slope< c(-sd), "arrowDown","arrowRight"))
          slope_sym<-if_else(last5_slope>sd, "↑", if_else(last5_slope< c(-sd), "↓","→"))
          slope_word<-if_else(last5_slope>sd, "an increasing", if_else(last5_slope< c(-sd), "a decreasing","a stable"))

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
