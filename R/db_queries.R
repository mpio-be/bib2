
#' allAdults
#' @export
#' @examples
#' x = allAdults()
allAdults <- function() {
    a = idbq("SELECT a.ID, capture_date_time datetime_, age, weight, s.sex FROM BTatWESTERHOLZ.ADULTS a 
        LEFT JOIN BTatWESTERHOLZ.SEX s 
            ON a.ID = s.ID ")

    x = idbq("SELECT a.ID, date_time_caught  datetime_, age, weight, s.sex FROM ADULTS a 
        LEFT JOIN BTatWESTERHOLZ.SEX s 
            ON a.ID = s.ID ")
      rbind(a, x)
    }


#' adults
#' @export
#' @examples
#' x = adults
adults <-   function(refdate = Sys.Date(), ...) {
    x = idbq("SELECT upper(a.ID) ID,  lower(FUNCTIONS.combo(UL,LL, UR, LR)) combo,  date_time_caught  datetime_, age, weight, tarsus, a.sex, s.sex gsex 
                        FROM ADULTS a 
                            LEFT JOIN BTatWESTERHOLZ.SEX s 
                                ON a.ID = s.ID ", ...)
    suppressWarnings( x[!is.na(gsex), sex := gsex] )
    x[, gsex := NULL]
        x[ as.Date(datetime_) <= as.Date(refdate)  ]

 }

#' nests
#' @export
#' @examples
#' nests()
nests <-   function(refdate = Sys.Date() ) {
    x = idbq("SELECT * FROM NESTS  where nest_stage is not  NULL and date_time is not NULL", year = year(refdate)  )
    x = x[ as.Date(date_time) <= as.Date(refdate)  ]
    setattr(x, 'refdate', refdate)
    x
   }









