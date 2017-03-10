
#' ADULTS
#' @param username user
#' @param host     host
#' @export
#' @examples
#' x = ADULTS()
ADULTS <- function() {
    bdbq("SELECT a.ID, capture_date_time capture_date, age, weight, s.sex FROM BTatWESTERHOLZ.ADULTS a 
        LEFT JOIN BTatWESTERHOLZ.SEX s 
            ON a.ID = s.ID ")
    }


