#' Title
#' @description
#' This function plots an indicator time series figure from data that is formated from the "data_prep" function in IEAnalyzeR.
#'
#'
#' @param df_obj Data object produced by the "data_prep" function.
#' @param interactive Run plot through plotly to create an interactive version of the plot.
#'
#' @return A plot in the indicatorTimeSeries format.
#' @export
#'
#' @examples
plot_fn_obj<-function(df_obj, interactive=FALSE) {


  if (ncol(df_obj$data)<5.5){
    #single plot
    plot_main<-ggplot(data=df_obj$data, aes(x=year, y=value))+
      geom_ribbon(data=df_obj$pos, aes(group=1,ymax=max, ymin=df_obj$vals$mean),fill="#7FFF7F")+
      geom_ribbon(data=df_obj$neg, aes(group=1,ymax=df_obj$vals$mean, ymin=min), fill="#FF7F7F")+
      geom_rect(aes(xmin=min(df_obj$data$year),xmax=max(df_obj$data$year),ymin=df_obj$vals$mean-df_obj$vals$sd, ymax=df_obj$vals$mean+df_obj$vals$sd), fill="white")+
      geom_hline(yintercept=df_obj$vals$mean, lty="dashed")+
      geom_hline(yintercept=df_obj$vals$mean+df_obj$vals$sd)+
      geom_hline(yintercept=df_obj$vals$mean-df_obj$vals$sd)+
      geom_line(aes(group=1), lwd=1)+
      labs(x="Year", y=df_obj$labs[2,2], title = df_obj$labs[1,2])+
      theme_bw() + theme(title = element_text(size=14, face = "bold"))

    if (max(df_obj$data$year)-min(df_obj$data$year)>20) {
      plot_main<-plot_main+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),5))
    } else {
      plot_main<-plot_main+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),2))
    }

    if (!interactive==F) {
      plot_main=ggplotly(plot_main)
    }
    plot_main

  } else {
    #facet plot

    plot_sec<-ggplot(data=df_obj$data, aes(x=year, y=value))+
      facet_wrap(~subnm, ncol=ifelse(length(unique(df_obj$data$subnm))<4, 1, 2), scales = "free_y")+
      geom_ribbon(data=df_obj$pos, aes(group=subnm,ymax=max, ymin=mean),fill="#7FFF7F")+
      geom_ribbon(data=df_obj$neg, aes(group=subnm,ymax=mean, ymin=min), fill="#FF7F7F")+
      geom_rect(data=merge(df_obj$data,df_obj$vals), aes(xmin=allminyear,xmax=allmaxyear,ymin=mean-sd, ymax=mean+sd), fill="white")+
      geom_hline(aes(yintercept=mean), lty="dashed",data=df_obj$vals)+
      geom_hline(aes(yintercept=mean+sd),data=df_obj$vals)+
      geom_hline(aes(yintercept=mean-sd),data=df_obj$vals)+
      geom_line(aes(group=1), lwd=0.75)+
      labs(x="Year", y=df_obj$labs[2,2], title = df_obj$labs[1,2])+
      theme_bw()+theme(strip.background = element_blank(),
                       strip.text = element_text(face="bold"),
                       title = element_text(size=14, face = "bold"))

    if (max(df_obj$data$year)-min(df_obj$data$year)>20) {
      plot_sec<-plot_sec+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),5))
    } else {
      plot_sec<-plot_sec+scale_x_continuous(breaks = seq(min(df_obj$data$year),max(df_obj$data$year),2))
    }

    if (!interactive==F) {
      plot_sec=ggplotly(plot_sec)
    }

    plot_sec
  }
}
