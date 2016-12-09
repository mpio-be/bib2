
#' ADULTS
#' @param username user
#' @param host     host
#' @export
#' @examples
#' require(dygraphs)
#' x = ADULTS()[, week := week(capture_date)]
#' dygraph(x)
#'
ADULTS <- function(username = 'bt', host = "scidb.mpio.orn.mpg.de") {

    con = dbcon(username, host = host); on.exit(dbDisconnect(con))
    dbq(con, 'USE BTatWESTERHOLZ')

    x = dbq(con, "SELECT a.ID, capture_date_time capture_date, age, weight, s.sex
                  FROM ADULTS a LEFT JOIN SEX s on a.ID = s.ID ", enhance = TRUE)

  }



# x = ADULTS()[, ':=' (Month = month(capture_date), Year = year(capture_date) )]
#
# x = x[, .N, by = .(Year, Month, sex)]
#
# dygraph(x)