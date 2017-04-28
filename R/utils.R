

#' find database name from year
#' @export
yy2dbnam <- function(year) {
    if(year == format(Sys.Date(), format = "%Y") )
       db = 'FIELD_BTatWESTERHOLZ' else
       paste('FIELD', year, 'BTatWESTERHOLZ', sep = "_")
    }

#' query function
#' @export
idbq <- function(query, year = year(Sys.Date()), db = yy2dbnam(year) , host = getOption('host.bib2') , user = getOption('user.bib2') ) {
    require(sdb)
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

#' @export
infuture <- function(x) {
  as.Date(x) %>% as.POSIXct > Sys.time()
  }

#' dayofyear2date
#' @export
#' @examples
#' dayofyear2date(1)
dayofyear2date <- function(dayofyear, year) {
  if(missing(year)) year = data.table::year(Sys.Date())
  ans = as.Date(dayofyear - 1, origin = paste(year, "01-01", sep = "-"))
  as.POSIXct(round( as.POSIXct(ans), units = "days"))

  }


#' Max
#' @export
Max <- function(x) {
     o = suppressWarnings(max(x, na.rm = TRUE) )
     if(o %in% c(Inf, -Inf) )  o = 0
     o
    }


#' Min
#' @export
Min <- function(x) {
     o = suppressWarnings(min(x, na.rm = TRUE) )
     if(o %in% c(Inf, -Inf) )  o = 0
     o
    }




#' noNApaste
#' @export
#' @examples
#' x = c(NA, 1)
Paste <- function(x) {
    x[is.na(x)] = ''
     paste(x, collapse = "|")
    }
