
#' Nests table
#'
#' Nests table for printing
#'
#' @param n     a data.table returned by  nests()
#'
#' @return path to pdf
#' @export
#' @importFrom rmarkdown pandoc_convert
#' 
#' @examples
#' \dontrun{
#'  x = nests(Sys.Date() - 1 )
#'  n = nest_state(x, hatchingModel = predict_hatchday_model(Breeding(), rlm) )
#' 
#' }
#' 

nest_table <- function(n) {
    data(boxesxy2)
    wo = boxesxy2[, .(box, walk_order)]
    x = merge(wo, n, by = 'box', all.x = TRUE)

    o = x[, .(box, Stg = nest_stage, LaCk = lastCheck, age = AGE, EgCk = ECK, d2h = days_to_hatch)]

    f = tempfile()




}
