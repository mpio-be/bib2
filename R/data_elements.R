


#' nest_state
#' @export
#' @param x             a data.table as returned by nests()
#' @param nesr_stages   character vector
#' @param hatchingModel a model to use for prediction
#' @examples \donttest{
#'  B = Breeding()
#' hatchingModel = predict_hatchday_model(B, MASS::rlm)  
#' nests() %>% nest_state(hatchingModel =hatchingModel)
#' nests("2016-04-12") %>% nest_state(hatchingModel =hatchingModel)
#' }
nest_state <-   function(x, nest_stages = NULL, hatchingModel) {
  x[, lastCheck := max(date_time), by = box]

  # last nest stage & last check (days ago) [MAIN FRAME]
    m = x[ lastCheck == date_time , .(box,date_time, nest_stage)]
    m[, lastCheck := difftime(attr(x, 'refdate'), date_time, units = 'days') %>% as.integer]

  # nest_stage age
    stage_age = x[, min(date_time), by = .(nest_stage, box)]
    stage_age[, nest_stage_age := (difftime(attr(x, 'refdate'), V1, units = 'days') %>% as.integer )+1  ]
    stage_age[, V1 := NULL]
  
  # clutch, chicks  
    eggs_chicks = x[date_time == lastCheck & nest_stage %in% c('E', 'Y'), .(box, eggs, chicks, guessed)]
    eggs_chicks[eggs > 0 & chicks >0, ECK := Paste( c(eggs, chicks) ), by = box]
    eggs_chicks[ eggs > 0 & is.na(chicks),  ECK := as.character(eggs) , by = box]
    eggs_chicks[ is.na(eggs) & chicks >  0,  ECK := as.character(chicks) , by = box]
    eggs_chicks[!is.na(guessed), ECK := paste0(ECK,'?')]
    eggs_chicks = eggs_chicks[, .(box, ECK)]


  # firstEgg, Max clutch size
    firstEggDat = x[nest_stage == 'E', .(firstEgg = Min(date_time) , clutch = Max(eggs) %>% as.integer  ), by = box]

    if(nrow(firstEggDat) > 0) {
      firstEggDat[, firstEgg := firstEgg %>% as.Date %>% as.POSIXct]

  # predicted hatching
      pred_hatch = copy(firstEggDat)
      pred_hatch[, predHatchDay  :=  predict_hatchday(hatchingModel, firstEggDat  ,0.95, 1.5) ]
      pred_hatch[, days_to_hatch := 1 + (difftime(predHatchDay, attr(x, 'refdate'), units = 'days') %>% as.integer) ]  
      pred_hatch = pred_hatch[, .(box, days_to_hatch)]
      } else pred_hatch = data.table(box = numeric(0),days_to_hatch = numeric(0) )

  # COMBINE SETS
    o = merge(m, stage_age, by = c('box', 'nest_stage'), all.x = TRUE)
    o = merge(o, eggs_chicks, by = 'box', all.x = TRUE)
    o = merge(o, firstEggDat, by = 'box', all.x = TRUE)
    
    o = merge(o, pred_hatch[, .(box, days_to_hatch)], by = 'box', all.x = TRUE)
    o[ !is.na(days_to_hatch),  AGE := Paste( c(nest_stage_age, days_to_hatch) ), by = box]
    o[ is.na(days_to_hatch),   AGE := as.character(nest_stage_age) ]

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
#' \donttest{
#' n = nests(Sys.Date() ) %>% nest_state()
#' nest_legend(n)
#' }
nest_legend <- function(n) {
  x = data.table( col = getOption('nest.stages.col'), nest_stage = getOption('nest.stages') )
  ld =  n[, .N, by = nest_stage]
  ld = merge(ld, x, by = 'nest_stage')
  ld[, labs := paste0(nest_stage, ' [',N,']')]
  ld
  }


