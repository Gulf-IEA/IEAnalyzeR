#' Title
#' @description
#' This function plots an indicator time series figure from data that is formated from the "data_prep" function in IEAnalyzeR.
#'
#' @import dplyr
#' @import ggplot2
#' @import plotly
#' @import ggimage
#' @import lubridate
#'
#' @param df_obj Data object produced by the "data_prep" function.
#' @param interactive Run plot through plotly to create an interactive version of the plot.
#' @param manual_ylab Manual y axis title. List multiple ylabs in order of appearance for figure with subindicators.
#' @param manual_xlab Manual x axis title.
#' @param manual_title Manual overall plot/plots title.
#' @param sep_ylabs Uses facet_wrap to allow the subplots to have separate y-axis labels. Only works for indicators that are one column and are multi.
#' @param ylab_sublabel This argument creates a sublabel for the y-axis by choosing two of the three label types. Label types include “indicator”, “unit”, and “extent”.
#' @param facet_scales Derived from facet_wrap scales argument : Should scales be fixed ("fixed", the default), free ("free"), or free in one dimension ("free_x", "free_y")? This controls the share vs “free” axis per panel in a faceted plot.
#' @param ncol How many columns should be in the faceted figure?
#' @param lwd Adjust the thickness of the timeseries line.
#' @param pts T/F Would you like points where the data are on top of the timeseries line.
#' @param pt_size What size would you like the points on the graph if pts=T?
#' @param fig.width  The intended width of saved figure. Is necessary for proper spacing if using trend symbol on final plot whether saving through the function or separately.
#' @param facet_grid Used if you need a subset of plots organized by two categories of labels. T defaults to unit by extent, or can specify two out of the three ("indicator","unit","extent")
#' @param xbreaks_by Specify the interval that the x axis breaks occur.
#' @param trend Do you want to include trend symbols (mean & slope) on the side of the plots.
#'
#' @return A plot in the indicatorTimeSeries format.
#' @export

plot_fn_obj<-function (df_obj, interactive = FALSE, sep_ylabs = F, ylab_sublabel = NULL,
                          facet_scales = "free", ncol = NULL,
                          manual_ylab = NULL, manual_xlab = NULL, manual_title = NULL,
                          lwd=0.75, pts=F, pt_size=0.75, fig.width=6,
                          facet_grid=F,  xbreaks_by= NULL,
                          trend=F)

{

  # Add extra ID info
  if (!is.null(df_obj$data$id)) {
    id_info<-rbind(c("id", as.character(seq(1, ncol(df_obj$labs) - 1))),df_obj$labs)
    id_info[,1]<-c("id","indicator", "unit", "extent")
    id_info<-as.data.frame(t(id_info), )
    colnames(id_info)<-id_info[1,]
    id_info<-id_info[-1,]
    id_info$id<-as.numeric(id_info$id)
    id_info[,2]<-gsub("\\.[^.]*$", "", id_info[,2])
    df_obj$data<-suppressMessages(left_join(df_obj$data, id_info))
    df_obj$ribbon<-suppressMessages(left_join(df_obj$ribbon, id_info))
    df_obj$vals<-suppressMessages(left_join(df_obj$vals, id_info))
  }


  plot <- ggplot(data = df_obj$data, aes(x = year, y = value)) +
    geom_ribbon(data = df_obj$ribbon, aes(ymax = max, ymin = mean),
                fill = "#7FFF7F") +
    geom_ribbon(data = df_obj$ribbon, aes(ymax = mean, ymin = min), fill = "#FF7F7F") +
    geom_rect(data = merge(df_obj$data, df_obj$vals),
              aes(xmin = min(year), xmax = max(year),
                  ymin = mean - sd, ymax = mean + sd), fill = "white")
  if (trend==T) {
    plot <- plot +
      geom_rect(data = df_obj$vals, aes(xmin=maxyear-5, xmax=maxyear, ymin=mean-sd, ymax=mean+sd),
                inherit.aes = F, fill="#DFDFFF")}
  plot<- plot+
    geom_hline(aes(yintercept = mean), lty = "dashed", data = df_obj$vals) +
    geom_hline(aes(yintercept = mean + sd), data = df_obj$vals) +
    geom_hline(aes(yintercept = mean - sd), data = df_obj$vals) +
    geom_line(aes(group = 1), lwd = lwd) + xlab("Year") +
    ylab(df_obj$labs[2, 2]) + ggtitle(df_obj$labs[1, 2]) +
    theme_bw() + theme(strip.background = element_blank(),
                       strip.text = element_text(face = "bold"), title = element_text(size = 14,
                                                                                      face = "bold"), panel.grid = element_blank(), plot.title = element_text(hjust = 0.5))

  if (pts==T) {
    plot <- plot+
      geom_point(size=pt_size)
  }


  if (is.null(xbreaks_by) & (max(df_obj$data$year) - min(df_obj$data$year) > 20)) {
    xbreaks_by<-5
  }

  if (!is.null(xbreaks_by)) {
    plot <- plot + scale_x_continuous(
      breaks = seq(xbreaks_by*floor(min(df_obj$data$year)/xbreaks_by),
                   xbreaks_by*ceiling(max(df_obj$data$year)/xbreaks_by), xbreaks_by)
    )
  }


  if (!is.null(ncol)) {
    ncol<-ncol
  } else  (
    ncol <- ifelse(length(unique(df_obj$data$id)) <
                     4, 1, 2)
  )


  # Create a ylab sublabel (nrow 1 or multi)
  if (!is.null(ylab_sublabel)) {
    if (isTRUE(ylab_sublabel)) {
      ylab_sublabel<-c("indicator", "unit")
    }
    new_nm_li<-list()
    for (i in 2:ncol(df_obj$labs)) {
      main<-ifelse(ylab_sublabel[1] == "extent", df_obj$labs[3, i], ifelse(ylab_sublabel[1] ==
                                                                             "unit", df_obj$labs[2, i], df_obj$labs[1, i]))
      sub<-ifelse(ylab_sublabel[2] == "extent", df_obj$labs[3, i], ifelse(ylab_sublabel[2] ==
                                                                            "unit", df_obj$labs[2, i], df_obj$labs[1, i]))
      new_nm_li[[i-1]]<-paste(main, sub, sep="\n")
    }

    ylabs<-unlist(new_nm_li, use.names = FALSE)

  }

  #Plot sublabel if created (for single plots)
  if (exists("ylabs")) {
    if (ncol(df_obj$data)<3) {
      plot<-plot+
        ylab(ylabs)
    }

  }


  if (ncol(df_obj$data) > 3) {

    #Create and plot sep labs
    if (sep_ylabs == T) {

      if(exists("ylabs")==F) {
        ylabs<-df_obj$vals$subnm
      }

      plot <- plot + facet_wrap(~id, ncol = ncol,
                                scales = facet_scales, strip.position = "left", labeller = as_labeller(setNames(ylabs,
                                                                                                                df_obj$vals$id))) +
        theme(strip.placement = "outside", strip.background = element_blank(),
              strip.text = element_text(face = "bold"), axis.title.y = element_blank())
      if (!is.null(manual_ylab)) {
        plot <- plot + facet_wrap(~id, ncol = ncol, scales = facet_scales, strip.position = "left",
                                  labeller = as_labeller(setNames(manual_ylab,
                                                                  sort(unique(df_obj$data$id)))))
      }
    } else if (!isFALSE(facet_grid)) {
      grid_by<-facet_grid
      if (isTRUE(grid_by)) {
        grid_by<-c("unit", "extent")
      }

      plot <- plot + facet_grid(as.formula(paste(grid_by[1], "~", grid_by[2])),
                                switch="y", scales=facet_scales)+
        theme(strip.placement = "outside", strip.background = element_blank(),
              strip.text = element_text(face = "bold"))
    } else {
      if(exists("ylabs")) {
        big_y<-ylabs
      }
      if(exists("ylabs")==F) {
        ylabs<-df_obj$vals$subnm
      }
      plot <- plot + facet_wrap(~id, ncol = ncol, scales = facet_scales, labeller = as_labeller(setNames(ylabs,
                                                                                                         df_obj$vals$id)))

      if (!is.null(ylab_sublabel)) {
        plot<-plot+
          ylab(big_y)
      }
    }


  }

  if (trend==T) {
    allmaxyear<-df_obj$vals$allmaxyear
    allminyear<-df_obj$vals$allminyear
    trend_pos<-ifelse(ncol < 2,
                      allminyear+1.1*(allmaxyear-allminyear),
                      allminyear+1.2*(allmaxyear-allminyear))

    #CREATING Y POS OFF SCALES
    # Adding new YPOS
    plot_dat<-ggplot_build(plot)$layout$panel_scales_y
    y_ranges <- lapply(plot_dat, function(s) s$range$range)
    ypos_mn <- sapply(y_ranges, function(r) r[1] + 0.7 * diff(r))
    ypos_sl <- sapply(y_ranges, function(r) r[1] + 0.3 * diff(r))
    ypos_df<-data.frame(SCALE_Y=1:length(y_ranges),
                        ypos_mn=ypos_mn,
                        ypos_sl=ypos_sl)


    if(ncol(df_obj$data)>3) {

      #Match y ranges to scales
      layout<-ggplot_build(plot)$layout$layout
      good_words<-c("id","indicator", "unit", "extent", "SCALE_Y", "PANEL")
      panel_info<-layout[, intersect(good_words, names(layout))]
      ypos_df<-suppressMessages(left_join(panel_info, ypos_df))
      ypos_df<-suppressMessages(left_join(df_obj$vals, ypos_df))
    } else { ypos_df<-cbind(df_obj$vals, ypos_df) }


    plot<- plot+
      ggimage::geom_image(data=ypos_df,aes(image=mean_img, y=ypos_mn), x=trend_pos, size=0.15, na.rm = T)+
      ggimage::geom_image(data=ypos_df,aes(image=slope_img, y=ypos_sl), x=trend_pos, size=0.15, na.rm = T)+
      coord_cartesian(clip = "off", expand = T)+
      theme(plot.margin = margin(3,(0.09 * fig.width * 72),3,3,unit = "pt"),
            panel.spacing.x = unit(0.09 * fig.width * 72, "pt"))

  }

  if (!is.null(manual_ylab)) {
    if (is.na(manual_ylab)) {
      manual_ylab<-element_blank()
    }
    plot <- plot + ylab(manual_ylab)
  }
  if (!is.null(manual_xlab)) {
    if (is.na(manual_xlab)) {
      manual_xlab<-element_blank()
    }
    plot <- plot + xlab(manual_xlab)
  }
  if (!is.null(manual_title)) {
    if (is.na(manual_title)) {
      manual_title<-element_blank()
    }
    plot <- plot + ggtitle(manual_title)
  }

  if (!interactive == F) {
    plot = ggplotly(plot)
  }

  plot
}
