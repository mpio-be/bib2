


#' nest_state
#' @export
#' @param x          a data.table as returned by nests()
#' @param nesr_stages character vector
#' @param hatchingModel a model to use for prediction
#' @examples
#' nests() %>% nest_state()
#' nests("2016-04-12") %>% nest_state()
nest_state <-   function(x, nest_stages = NULL, hatchingModel) {
  x[, lastCheck := max(date_time), by = box]

  # last nest stage & last check
  o = x[ lastCheck == date_time , .(box,date_time, nest_stage)]
  setorder(o, box)
  o[, lastCheck := difftime(attr(x, 'refdate'), date_time, units = 'days') %>% as.integer]

  # nest_stage age
  z = x[, min(date_time), by = .(nest_stage, box)]
  z[, nest_stage_age := (difftime(attr(x, 'refdate'), V1, units = 'days') %>% as.integer )+1  ]
  z[, V1 := NULL]
  o = merge(o, z, by = c('box', 'nest_stage'), all.x = TRUE)

  # clutch, chicks  
  egck =  x[, .(clutch = Max(eggs), maxck = Max(chicks)  ), by = box]
  out =  x[, .(ce = sum(collect_eggs, na.rm=TRUE), 
               de = sum(dead_eggs, na.rm=TRUE),
               dc = sum(dead_chicks, na.rm=TRUE)
            ), by = box]
  z = merge(egck, out, by = 'box' )
  z[, ':=' (egg = clutch-ce-de-maxck, ckc = maxck - dc)]
  z[ egg >0 & ckc >0, ECK := Paste( c(egg, ckc) ), by = box]
  z[ egg >0 & ckc == 0, ECK := as.character(egg) , by = box]
  z[ egg == 0 & ckc >0, ECK := as.character(ckc) , by = box]

  # firstEgg
  e1 = x[nest_stage == 'E', .(firstEgg = Min(date_time) %>% as.Date %>% as.POSIXct  ), by = box]

  # all data  compiled data
  o = merge(o, z[, .(box, clutch, ECK)], by = 'box', all.x = TRUE)
  o = merge(o, e1, by = 'box', all.x = TRUE)

  # predicted hatching
  newdat = o[!is.na(firstEgg) & nest_stage == 'E', .(firstEgg, clutch, box)]
  newdat[, predHatchDay :=  predict_hatchday(hatchingModel, newdat  ,0.95, 1.5) ]
  newdat[, days_to_hatch:= 1 + (difftime(predHatchDay, attr(x, 'refdate'), units = 'days') %>% as.integer) ]  

  o = merge(o, newdat[, .(box, days_to_hatch)], by = 'box', all.x = TRUE)
  o[ !is.na(days_to_hatch), AGE := Paste( c(nest_stage_age, days_to_hatch) ), by = box]
  o[ is.na(days_to_hatch), AGE := as.character(nest_stage_age) ]


  # subset by nest_stages
  if(!is.null(nest_stages))
   o = o[nest_stage %in% nest_stages]


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


