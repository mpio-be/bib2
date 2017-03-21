#' @name plots
#' @title  plots
NULL

#' @export
#' @rdname plots
#' @examples
#'   all_phenology = phenology()
#' plot_phenology_firstDates()
plot_phenology_firstDates <- function(refdate = Sys.Date(), x = phenology_firstDates(refdate) ) {

  ggplot(x , aes(x = Start, fill = variable)) + 
   geom_histogram(position="dodge") + xlim( c( as.POSIXct(refdate) , NA))+
   theme_solarized_2(light = FALSE) +
   scale_fill_solarized("blue")

 }