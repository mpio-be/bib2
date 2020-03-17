#' @name   plots
#' @title  plots
NULL

#' @export
#' @param   ... goes to phenology()
#' @rdname plots
#' @examples
#'   all_phenology = phenology()
#' plot_phenology_firstDates()
plot_phenology_firstDates <- function(...) {

  x =phenology(...)  

  z = x[, .(minDate = min(date_) ), .(variable, year_)][, id := 1:.N]
  z[, min_yday := yday(minDate)]

  zz = z[, .(Min = min(min_yday), Max = max(min_yday)), by = variable]
  zz = merge(zz, z[, .(year_, variable, min_yday)], by.x = c('variable', 'Min'), by.y = c('variable', 'min_yday') )
  zz = merge(zz, z[, .(year_, variable, min_yday)], 
       by.x = c('variable', 'Max'), by.y = c('variable', 'min_yday'), suffixes = c('min', 'max') )
  zz = unique(zz, by = c("Min", "Max", "variable"))

  zz[, variable := factor(variable, 
    levels = c("firstLittle", "firstBottom", "firstCup",  "firstLining","firstEgg","hatchDate", "fledgeDate")%>% rev,
    labels = c("LITTLE", "BOTTOM", "CUP",  "LINING","LAYING", "HATCHING", "FLEDGING")%>% rev
    )]

  zz[, Max := dayofyear2date(Max)]
  zz[, Min := dayofyear2date(Min)]
  zz[, Max_lab := format(Max, "%d-%b") ]
  zz[, Min_lab := format(Min, "%d-%b") ]

  # this year
  n = nests()
  n[, date_time := as.POSIXct(date_time)]
  n = n[, .(minDate = min(date_time)), by = nest_stage]
  n = n[nest_stage %in% c("LT",  "B", "C", "LIN", "E",  "Y")]
  n[, year := factor(year(minDate)) ]

  n[, variable := factor(nest_stage, 
    levels = c("LT",  "B", "C", "LIN", "E",  "Y")%>% rev,
    labels = c("LITTLE", "BOTTOM", "CUP",  "LINING","LAYING", "HATCHING")%>% rev
    )]

  # g = 

  ggplot() +
    geom_errorbar(  data =zz, aes(x = variable, ymin =  Min, ymax = Max) , size = .5, alpha = .9, col = 'blue',  width = 0.2 ) + 
    geom_text_repel(data =zz, aes(x = variable, y =  Min, label =  Min_lab ) ) + 
    geom_text_repel(data =zz, aes(x = variable, y =  Max, label =  Max_lab ) ) + 
    geom_point(     data = n, aes(x = variable, y = minDate, color = year), size = 3) + 

    xlab(NULL) + ylab(NULL)+
    ggtitle("First and last events across years")+
    theme_classic() + theme(legend.position=c(.9,.9))+

    coord_flip() 



 }