
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
        x[ round(as.Date(datetime_))  <= round(as.Date(refdate))  ]

 }




#' nests
#' @export
#' @examples
#' nests()
nests <-   function(refdate = Sys.Date() ) {
    x = idbq(
        paste("SELECT * FROM NESTS  
                    WHERE nest_stage is not  NULL and date_time is not NULL and date_time <=", shQuote(refdate))
                , year = year(refdate)  )
    setattr(x, 'refdate', refdate)
    x
   

   }


#' phenology
#' @export
#' @examples
#' phenology()
phenology <-  function() {

 x = idbq("SELECT n.year_,n.box, date_C firstCup ,date_LIN firstLining,  firstEgg,hatchDate,fledgeDate 
    from BTatWESTERHOLZ.NESTS n left join BTatWESTERHOLZ.BREEDING b
        on n.box = b.box and n.year_ = b.year_")

 melt(x, id.vars  = c('year_', 'box'), na.rm = TRUE, value.name = 'date_')

   
 }

