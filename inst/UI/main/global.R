
# shiny::runApp('inst/UI/main')

# settings
    sapply(c('sdb', 'sysmanager', 'bib2','SNB', 'knitr', 'ggplot2','digest',
                  'shiny','shinyjs','shinydashboard','shinyBS','shinytoastr', 'shinyTree'),
      function(x) suppressPackageStartupMessages( require(x, character.only = TRUE, quietly = TRUE) ))
    options(stringsAsFactors = FALSE)


