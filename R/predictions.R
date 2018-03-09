


#' predict_firstEgg
#' @export
#' @examples
#' date_ = Sys.Date()
#' F = phenology('LIN')
#' predFirstEggData = predict_firstEgg_data(F, date_ )
#' predFirstEgg = predict_firstEgg(predFirstEggData, yday(date_), year(date_) )[, date_ := as.POSIXct(date_) ]
#' 
#' ggplot(predFirstEggData, aes(y = first_Egg , x = first_Lining, x) ) + 
#'  geom_point() + 
#'  geom_smooth(method = 'lm') + geom_text(aes(label = year_), vjust= 'bottom') + 
#'  geom_pointrange(data = predFirstEgg, aes(x = date_, y = fit, ymin = lwr, ymax = upr ), col = 2) + 
#'  ggtitle(paste(predFirstEgg[, difftime(fit, date_, units = 'days')%>% round], 'days till first egg.'))
predict_firstEgg <- function(dat, v, refyear = year(Sys.Date()) ) {

    v = data.frame(firstLining = v) 

    if(missing(v))
    v = dat[, .(firstLining)]

    fm = lm(firstEgg ~ firstLining , dat)

    o = round(predict(fm, v, interval = "confidence") ) %>% data.table
    o[, ":=" (fit = dayofyear2date(fit, refyear), lwr= dayofyear2date(lwr, refyear),  upr = dayofyear2date(upr, refyear) )  ]
    o

    }


#' @export
#' @rdname predict_firstEgg
predict_firstEgg_data <- function (F, refdate = Sys.Date()) {
    refyear = year(refdate)
    z = F[, .(yday(min(date_))), by = .(year_, variable)]

    # if( nrow(z[variable == 'firstLining']) ==0 ) stop("The prediction of the first egg is based on the first lining! ")

    z = dcast(z, year_ ~ variable, value.var = "V1")
    z[, `:=`(first_Lining, dayofyear2date(firstLining, refyear))]
    z[, `:=`(first_Egg, dayofyear2date(firstEgg, refyear))]
    z
    }


#' predict_hatchday_model
#' @export
#' @examples
#' predict_hatchday_model( Breeding() )
predict_hatchday_model <- function(x, model = lm) {
  x = Breeding()

  x[, firstEgg  := yday(firstEgg) ]
  x[, hatchDate := yday(hatchDate)]

  model(hatchDate ~ firstEgg + clutch , data = x)
  
  }

#' predict_hatchday
#' @param fm  fitted model (eg. by predict_hatchday_model () )
#' @param dat newdat for prediction
#' @param ci  lower CI
#' @param days_below_lwr 
#' @return lower CI of the prediction - days_below_lwr
#' @export
#' @examples
#'   
#' d = Breeding() 
#' fm = predict_hatchday_model(d)
#' d[, predHatch := predict_hatchday(fm, d,0.95, 1.5) ]
#' # check prediction     
#' d[, missed := difftime(hatchDate, predHatch, units= 'days') %>% as.numeric]
#' d[, .N/nrow(d), by = missed < -1]
#' 
#' # check incubation duration
#' d[, incub := difftime(hatchDate, as.Date(firstEgg) + clutch, units= 'days')]
#' d[, range(incub)]
#' d[, quantile(incub)]     
#'
#' # check predicted incubation duration
#' d[, pincub := difftime(predHatch, as.Date(firstEgg) + clutch, units= 'days')]
#' d[, range(pincub)]
#' d[, quantile(pincub)]
#' plot(incub ~ pincub, d)

predict_hatchday <- function(fm, dat = Breeding(), ci = 0.95, days_below_lwr = 1.5 ) {
   x = copy(dat)
   x[, YEAR      := year(firstEgg)]
   x[, firstEgg  := yday(firstEgg) ]

   x[, lwr := predict(fm, x , interval = 'confidence', level = ci)[, 3] ]
   x[, hatchDate_pred := dayofyear2date(lwr, YEAR), by = 1:nrow(x)]
   x[, hatchDate_pred :=  as.POSIXct(as.Date(hatchDate_pred) - days_below_lwr )]
   return(x$hatchDate_pred)
   rm(x)

  }





