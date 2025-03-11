#' Title
#' @description
#' This function reformats data from the "plotIndicatorTimeSeries" format, into a data object that works with plotting functions in the IEAnalyzeR function.
#'
#' @import dplyr
#'
#' @param df Dataset with top 3 rows inlcuding metadata of indicator name, unit, and subcategory.
#' @param trends T/F if you would like the function to calculate trends on this dataset.
#' @param subind How is the data categorized for sun indicators. Options "extent" or "unit".
#'
#' @return An object with 5 datasets used in "plot_fn_obj".
#' @export

data_prep <-function (df, trends=T, subind= "extent") {

  df_list<-vector("list", 5)
  names(df_list)<-c("data", "pos", "neg", "labs", "vals")

  #Data used for everything
  df_dat<-df[4:nrow(df),c(1:ncol(df))]

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
    df_dat} else {

      sub_list<-list()
      for (i in 2:ncol(df_dat)){
        sub_df<-df_dat[,c(1,i)]
        df_lab<-df[1:3,] #For example sake cutting to only col I need
        ind<-ifelse(subind=="extent", df_lab[3,i], ifelse(subind=="unit", df_lab[2,i], df_lab[1,i]))
        colnames(sub_df)<-c("year","value")
        # sub_df$value<- as.numeric(sub_df$value)
        sub_df<-as.data.frame(lapply(sub_df, as.numeric))

        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)

        sub_df$valence[sub_df$value>=mean]<-"pos"
        sub_df$valence[sub_df$value< mean]<-"neg"
        sub_df$min <- ifelse(sub_df$value >= mean, mean, sub_df$value)
        sub_df$max <- ifelse(sub_df$value >= mean, sub_df$value, mean)
        sub_df$year <- as.numeric(sub_df$year)
        sub_df$subnm<-paste0(ind)
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
    pos} else {
      sub_list<-list()
      subs<-unique(df_dat$subnm)
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$subnm==subs[i],]
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)
        pos<-sub_df
        pos$value<-ifelse(pos$valence == "pos",pos$value, mean)
        pos$subnm<-subs[i]
        pos$mean<-mean
        pos$sd<-sd
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
    neg} else {
      sub_list<-list()
      subs<-unique(df_dat$subnm)
      for (i in 1:length(subs)){
        sub_df<-df_dat[df_dat$subnm==subs[i],]
        mean<-mean(as.numeric(sub_df$value), na.rm = T)
        sd<-sd(as.numeric(sub_df$value), na.rm = T)
        neg<-sub_df
        neg$value<-ifelse(neg$valence == "neg",neg$value, mean)
        neg$subnm<-subs[i]
        neg$mean<-mean
        neg$sd<-sd
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
                       mean_tr=mean_tr,
                       slope_tr=slope_tr,
                       mean_sym=mean_sym,
                       slope_sym=slope_sym,
                       mean_word=mean_word,
                       slope_word=slope_word)
      vals} else {
        sub_list<-list()
        subs<-unique(df_dat$subnm)
        for (i in 1:length(subs)){
          sub_df<-df_dat[df_dat$subnm==subs[i],]
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
                           subnm=subs[i])


          sub_list[[i]]<-vals
        }
        vals<-do.call("rbind",sub_list)

      }
    df_list$vals<-vals
  }
  df_list
}
