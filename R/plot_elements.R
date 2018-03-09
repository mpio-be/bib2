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


  # g = 

  ggplot(zz, aes(x = variable )) +
    geom_errorbar(aes(ymin =  Min, ymax = Max) , size = .2, alpha = .6, col = 'red',  width = 0.2 ) + 
    geom_text_repel(aes(y =  Min, label =  Max_lab ) ) + 
    geom_text_repel(aes(y =  Max, label =  Min_lab ) ) + 
    xlab(NULL) + ylab(NULL)+
    ggtitle("First and last events across years")+

    coord_flip() 



 }