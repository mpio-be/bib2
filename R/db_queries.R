
#' allAdults
#' @export
#' @examples
#' x = Breeding()
Breeding <- function() {
    bibq("select year_,box,IDfemale,firstEgg,clutch, laying_gap, hatchDate FROM BTatWESTERHOLZ.BREEDING 
    WHERE secondClutch = 0  and firstEgg is not NULL and hatchDate is not NULL and laying_gap < 4
        order by year_, firstEgg")
    }


#' allAdults
#' @export
#' @examples
#' x = allAdults()
allAdults <- function() {
    a = bibq("SELECT a.ID, capture_date_time datetime_, age, weight, s.sex FROM BTatWESTERHOLZ.ADULTS a 
        LEFT JOIN BTatWESTERHOLZ.SEX s 
            ON a.ID = s.ID ")

    x = bibq("SELECT a.ID, date_time_caught  datetime_, age, weight, s.sex FROM ADULTS a 
        LEFT JOIN BTatWESTERHOLZ.SEX s 
            ON a.ID = s.ID ")
      rbind(a, x)
    }

#' adults
#' @export
#' @examples
#' x = adults
adults <-   function(refdate = Sys.Date(), ...) {
    x = bibq("SELECT upper(a.ID) ID,  lower(FUNCTIONS.combo(UL,LL, UR, LR)) combo,  date_time_caught  datetime_, age, weight, tarsus, a.sex, s.sex gsex 
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
#' nests() %>% head
nests <-   function(refdate = Sys.Date() ) {
    
    sql = paste("SELECT * FROM NESTS  
                    WHERE nest_stage is not  NULL and date_time is not NULL and date_time <=", shQuote(refdate))

    x = bibq(sql, year = year(refdate)  )

    setattr(x, 'refdate', refdate)
    x
   

   }


#' nest_state
#' @export
#' @param x             a data.table as returned by nests()
#' @param nesr_stages   character vector
#' @param hatchingModel a model to use for prediction

#' phenology
#' @export
#' @param  minimum_stage (one of "LT", "B", "C", "LIN", "firstEgg","hatchDate","fledgeDate") default to "C"
#' @examples
#' phenology()
phenology <-  function(minimum_stage = 'C') {

    s = data.table(
        # def by the input of this function
        stage_code  = c("LT", "B", "C", "LIN", "firstEgg","hatchDate","fledgeDate"), 
         # def by db
        stage       =  c("date_LT", "date_B", "date_C", "date_LIN", "firstEgg","hatchDate","fledgeDate"),
        # def by the output of this function
        stage_name  =  c("firstLittle", "firstBottom", "firstCup", "firstLining", "firstEgg","hatchDate","fledgeDate"), 
        stage_id    = 1:7
        )
    if(!missing(minimum_stage))
    ss= s[ stage_id >= s[stage_code == minimum_stage]$stage_id] else ss = s

    n = bibq('select year_, box,  date_LT, date_B,date_C, date_LIN from BTatWESTERHOLZ.NESTS')
    b = bibq('select year_, box, firstEgg,hatchDate,fledgeDate  from BTatWESTERHOLZ.BREEDING')

    d = merge(n, b, all.x = TRUE, all.y = TRUE, by = c('year_', 'box') )
    
    d = melt(d, id.vars  = c('year_', 'box'), na.rm = TRUE, value.name = 'date_')


    d = merge(d, ss[, .(stage,stage_name)], by.x = 'variable', by.y = 'stage')
    d[, variable := NULL]
    setnames(d, 'stage_name', 'variable') # not to break upstream functions

    d

   
 }



