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
  x[, day := as.POSIXct(date_) %>% yday %>% dayofyear2date]
  x[, variable := factor(variable, 
    levels = c("firstLittle", "firstBottom", "firstCup",  "firstLining","firstEgg","hatchDate", "fledgeDate")%>% rev,
    labels = c("LITTLE", "BOTTOM", "CUP",  "LINING","LAYING", "HATCHING", "FLEDGING")%>% rev
    )]

 
  z = x[, .(minDate = min(date_) ), .(variable, year_)][, id := 1:.N]
  z[, min_yday := yday(minDate)]
  z[, min_day := dayofyear2date(min_yday)]

  zz = z[, .(Min = min(min_yday), Max = max(min_yday)), by = variable]
  zz = merge(zz, z[, .(year_, variable, min_yday)], by.x = c('variable', 'Min'), by.y = c('variable', 'min_yday') )
  zz = merge(zz, z[, .(year_, variable, min_yday)], 
       by.x = c('variable', 'Max'), by.y = c('variable', 'min_yday'), suffixes = c('min', 'max') )
  zz = unique(zz, by = c("Min", "Max", "variable"))

 

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

  ggplot() +
    geom_density_ridges(data = z, aes(x = min_day, y = variable), scale = 1, alpha = 0.5,col = 'grey') +
    geom_text(data =zz, aes(y = variable, x =  Min, label =  Min_lab ),angle = 90,hjust = -0.1 ) + 
    geom_text(data =zz, aes(y = variable, x =  Max, label =  Max_lab ),angle = 90,hjust = -0.1 ) + 
    geom_point(     data = n, aes(y = variable, x = minDate, color = year), size = 3) + 

    xlab(NULL) + ylab(NULL)+
    ggtitle("First events distribution\nacross years")+
    theme_classic() + theme(legend.position=c(.85,.9))  



 }