

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


#' @export
inset_legend_pos <- function() {
    data.frame( x = 4417700, y = 5334960)
}


