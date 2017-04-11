


#' predict_firstEgg
#' @export
#' @examples
#' date_ = Sys.Date()
#' F = phenology()
#' predFirstEggData = predict_firstEgg_data(F, date_ )
#' predFirstEgg = predict_firstEgg(predFirstEggData, yday(date_) )[, date_ := as.POSIXct(date_) ]
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
#' @examples
#' x = Breeding()
#' 
predict_hatchday_model <- function(x) {
 

  }


#' @export
#' @examples
#' n = nests() 
#' # predict_hatchday()
predict_hatchday <- function() {
    refyear = year(refdate)

  }





#' @export
#' @examples
#'
predict_hatchday_test <- function() {
    refyear = year(refdate)

  }

