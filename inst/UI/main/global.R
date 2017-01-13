
# shiny::runApp('inst/UI/main')

# settings
    sapply(c('sdb', 'sysmanager', 'bib2','SNB', 'knitr', 'ggplot2',
            'shiny','shinyjs','shinydashboard','shinyBS','shinytoastr', 'shinyTree'),
      function(x) suppressPackageStartupMessages( require(x, character.only = TRUE, quietly = TRUE) ))
    options(stringsAsFactors = FALSE)

    user          = 'bt'
    pwd           = 'bt'
    host          = "scidb.mpio.orn.mpg.de"
    db            = 'FIELD_BTatWESTERHOLZ'


# x = diagnose_pull(date= "2016.12.06")