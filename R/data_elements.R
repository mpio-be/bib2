


#' nest_state
#' @export
#' @param x        a  data.table (commented with ref date) returned by nests()
#' @param ref_date reference date
#' @examples
#' nests() %>% nest_state()
#' nests("2016-04-12") %>% nest_state()
nest_state <-   function(x) {
  x[, lastCheck := max(date_time), by = box]
  
  # last nest stage & last check
    o = x[ lastCheck == date_time , .(box,date_time, nest_stage)]
    setorder(o, box)
    o[, lastCheck := difftime(attr(x, 'refdate'), date_time, units = 'days') %>% as.integer]
    
  # nest_stage age
    z = x[, min(date_time), by = .(nest_stage, box)]
    z[, nest_stage_age := difftime(attr(x, 'refdate'), V1, units = 'days') %>% as.integer   ]
    z[, V1 := NULL]
    o = merge(o, z, by = c('box', 'nest_stage'), all.x = TRUE)

    setattr(o, 'refdate', attr(x, 'refdate') )
    o

  }

#' Legend
#' Nest stages, frequencies and late/early score
#' @param n   a  data.table (commented with ref date) returned by nests()
#' @param N   a  data.table returned by allNests()
#' @export
#' @examples
#' n = nests(Sys.Date() ) %>% nest_state()
#' nest_legend(n)
nest_legend <- function(n) {
    x = data.table( col = getOption('nest.stages.col'), nest_stage = getOption('nest.stages') )
    ld =  n[, .N, by = nest_stage]
    ld = merge(ld, x, by = 'nest_stage')
    ld[, labs := paste0(nest_stage, ' [',N,']')]
    ld
   }






