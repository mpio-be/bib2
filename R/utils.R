

#' find database name from year
#' @export
yy2dbnam <- function(year) {
    if(year == format(Sys.Date(), format = "%Y") )
       db = 'FIELD_BTatWESTERHOLZ' else
       paste('FIELD', year, 'BTatWESTERHOLZ', sep = "_")
    }

#' query function
#' @export
bdbq <- function(query, year = year(Sys.Date()), db = yy2dbnam(year) , host = "scidb.mpio.orn.mpg.de", user = 'bt' ) {

    if(missing(year))
    year = format(Sys.Date(), format = "%Y")
    if(missing(db))
    db = yy2dbnam(year)

    con = dbcon(user = user, host = host, db = db)
    on.exit(  closeCon (con)  )

    dbq(con, query, enhance = TRUE)

    }



#' @export
is.breeding <- function(x = Sys.time()) {
    d = as.numeric(format(x, "%m"))
    if(d %in% 3:5) TRUE else FALSE
    }





