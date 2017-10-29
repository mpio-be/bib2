
# require(sdb)
# sdb::my_remote2local('SNBatWESTERHOLZ', 'file_status', 'mihai', localUser = 'mihai')
# runApp('inst/UI/DataEntry/SNBatWESTERHOLZ/file_status')

# dbWriteTable(con, 'file_status', data.table(id = NA, author = NA, box = 1:10, datetime_ = rep(Sys.Date() %>% as.character, 5), bat_status = NA, firmware_status = NA), append =TRUE, row.names = FALSE)

# settings
  sapply(c('sdb', 'SNB','shiny','shinyjs','shinydashboard','miniUI','shinyBS','shinytoastr','knitr', 'DataEntry'),
  require, character.only = TRUE, quietly = TRUE)

  host   = scidbadmin::getSysOption('host')
  user   = getOption('DB_user')
  db     =  getOption('snbDB')
  table  = 'file_status'


# data
 comments = column_comment(user, host, db, table)

# Functions
  get_table_for_data_entry <- function(pulldate) {

    con   = dbcon(user = user, host = host)
    on.exit(dbDisconnect(con))

    dbq(con, paste('USE', db) )

    d     = dbq(con, paste('SELECT id, box, author, datetime_, bat_status, firmware_status
                              FROM file_status
                                  WHERE path  NOT REGEXP BINARY "CF/" AND 
                                      date(datetime_) = ', shQuote(pulldate)  ,'
                                        ORDER BY box') )

      if(nrow(d) == 0) toastr_warning(paste('No SD-cards were pulled on', pulldate) )
      

      d[, `:=`(hour            = as.integer(NA),
               min             = as.integer(NA),
               bat_status      = as.integer(bat_status),
               firmware_status = as.integer(firmware_status),
               box             = as.integer(box),
               id              = as.integer(id),
               datetime_       = str_replace(datetime_, '00\\:00\\:00', '') %>% str_trim
               ) ]

      setcolorder(d, c('box', 'author', 'hour', 'min', 'bat_status', 'firmware_status', 'datetime_', 'id'))
  

    d

   }

  update_table_from_user_input <- function(d) {

    con   = dbcon(user, host = host); on.exit(dbDisconnect(con))
    dbq(con, paste('USE', db) )
    

    d = d[ !is.na(hour) & !is.na(min) & !is.na(author) ]
    d[, hour := str_pad(hour, 2, 'left', '0')]
    d[, min := str_pad(min, 2, 'left', '0')]

    d[, datetime_ := paste(datetime_, paste(hour, min, sep = ':'))]



    dbq(con, "DROP  TABLE IF EXISTS temp")
    dbq(con, "CREATE  TABLE temp (id INT, author VARCHAR(4), datetime_ DATETIME, bat_status TINYINT, firmware_status TINYINT)")

    res = dbWriteTable(con, "temp", d[, .(id, author, datetime_, bat_status, firmware_status)],  row.names = FALSE, append = TRUE)
    dbq(con, 'UPDATE file_status f, temp t
                  SET f.author = t.author,
                  f.datetime_ = t.datetime_,
                  f.bat_status = t.bat_status,
                  f.firmware_status = t.firmware_status
                    WHERE f.id = t.id')

    dbq(con, "DROP  TABLE IF EXISTS temp")

    toastr_info(paste(nrow(d), 'rows updated.') )


   }

  inspector <- function(x) {

    hhmm = data.table(variable = c('hour', 'min'), lq = c(0, 0), uq = c(23, 59) )

    i1 = interval_validator(x[, .(hour, min)], hhmm)[, reason := 'incorrect hour or minute']


    o = list(i1) %>% rbindlist
    o[, .(rowid = paste(rowid, collapse = ',')), by = .(variable, reason)]

    o

    }


