#' Title
#' @description
#' This function plots an indicator time series figure from data that is formated from the "data_prep" function in IEAnalyzeR.
#'
#' @import ggplot2
#' @import plotly
#'
#' @param df_obj Data object produced by the "data_prep" function.
#' @param interactive Run plot through plotly to create an interactive version of the plot.
#' @param sep_yaxis Logical. Does this plot have subindicators that need a separate y axis?
#' @param manual_ylab Manual y axis title. List multiple ylabs in order of appearance for figure with subindicators.
#' @param manual_xlab Manual x axis title.
#' @param manual_title Manual overall plot/plots title.
#'
#' @return A plot in the indicatorTimeSeries format.
#' @export

plot_fn_obj<-function (df_obj, interactive = FALSE, sep_yaxis=F, manual_ylab=NULL, manual_xlab=NULL, manual_title=NULL) {

  #Main Plot
  plot <- ggplot(data = df_obj$data, aes(x = year, y = value)) +
    geom_ribbon(data = df_obj$pos, aes(ymax = max, ymin = mean), fill = "#7FFF7F") +
    geom_ribbon(data = df_obj$neg, aes(ymax = mean, ymin = min), fill = "#FF7F7F") +
    geom_rect(data = merge(df_obj$data, df_obj$vals), aes(xmin = min(year), xmax = max(year), ymin = mean - sd, ymax = mean + sd), fill = "white") +
    geom_hline(aes(yintercept = mean), lty = "dashed", data = df_obj$vals) +
    geom_hline(aes(yintercept = mean + sd), data = df_obj$vals) +
    geom_hline(aes(yintercept = mean -sd), data = df_obj$vals) +
    geom_line(aes(group = 1), lwd = 0.75) +
    xlab("Year") + ylab(df_obj$labs[2,2]) + ggtitle (df_obj$labs[1, 2])+
    theme_bw() + theme(strip.background = element_blank(),
                       strip.text = element_text(face = "bold"),
                       title = element_text(size = 14, face = "bold"))

  #Altering scales
  if (max(df_obj$data$year) - min(df_obj$data$year) > 20) {
    plot <- plot + scale_x_continuous(breaks = seq(min(df_obj$data$year),
                                                   max(df_obj$data$year), 5))
  } else {
    plot <- plot + scale_x_continuous(breaks = seq(min(df_obj$data$year),
                                                   max(df_obj$data$year), 2))
  }


  #Add facetting for sub indicators
  if (ncol(df_obj$data) > 5.5) {

    if (sep_yaxis==T) {
      plot<-plot+
        facet_wrap(~subnm, ncol = ifelse(length(unique(df_obj$data$subnm)) < 4, 1, 2), scales = "free_y", strip.position = "left")+
        theme(strip.placement = "outside",
              strip.background = element_blank(),
              strip.text = element_text(face="bold"),
              axis.title.y = element_blank())

      if (!is.null(manual_ylab)) {
        plot<-plot+
          facet_wrap(~subnm,ncol = ifelse(length(unique(df_obj$data$subnm)) < 4, 1, 2), scales = "free_y" , strip.position = "left",
                     labeller = as_labeller(setNames(manual_ylab, sort(unique(df_obj$data$subnm)))))
      }
    } else {
      plot<-plot+
        facet_wrap(~subnm, ncol = ifelse(length(unique(df_obj$data$subnm)) < 4, 1, 2), scales = "free_y")
    }

  }


  #Adjusting Labels
  if (!is.null(manual_ylab)) {
    plot<-plot+
      ylab(manual_ylab)
  }

  if (!is.null(manual_xlab)) {
    plot<-plot+
      xlab(manual_xlab)
  }

  if (!is.null(manual_title)) {
    plot<-plot+
      ggtitle(manual_title)
  }

  #Toggling Interactivity (LAST IN ORDER)
  if (!interactive == F) {
    plot = ggplotly(plot)
  }


  plot
}
