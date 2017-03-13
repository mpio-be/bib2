
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

# TODO: select the last catch and add transponder
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


#' nest_state
#' @export
#' @param x       a commented [using setattr] (with ref date) data.table returned by nests()
#' @param ref_date reference date
#' @examples
#' nests() %>% nest_state()
#' nests("2016-04-12") %>% nest_state()
nest_state <-   function(x) {
  x[, lastCheck := max(date_time), by = box]
  o = x[ lastCheck == date_time , .(box,date_time, nest_stage)]
  setorder(o, box)
  o[, lastCheck := difftime(attr(x, 'refdate'), date_time, units = 'days') %>% as.integer]
  merge(o, boxesxy[, .(box, long, lat)])

   
 }







