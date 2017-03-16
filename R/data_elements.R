
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

#' @export
nest_legend <- function(n) {
    ld =  n[, .N, by = nest_stage]
    x = data.table( col = getOption('nest.stages.col'), nest_stage = getOption('nest.stages') )
    ld = merge(ld, x, by = 'nest_stage')
    ld[, labs := paste0(nest_stage, ' [',N,']')]
   ld
    
}


#' @export
inset_legend_pos <- function() {
    data.frame( x = 4417700, y = 5334960)
}