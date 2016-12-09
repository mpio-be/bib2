
# shiny::runApp('inst/UI/main')

# settings
    sapply(c('bib2','SNB', 'shiny','shinyjs','shinydashboard','shinyBS','shinytoastr','knitr', 'ggplot2'),
      function(x) suppressPackageStartupMessages( require(x, character.only = TRUE, quietly = TRUE) ))
    options( stringsAsFactors = FALSE)

    user          = 'bt'
    pwd           = 'bt'
    host          = "scidb.mpio.orn.mpg.de"
    db            = 'FIELD_BTatWESTERHOLZ'


