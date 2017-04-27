
# shiny::runApp('inst/UI/main', launch.browser = TRUE)

# settings
    sapply(c('sdb', 'sysmanager', 'bib2','SNB', 'knitr', 'ggplot2', 'ggthemes','digest',
                  'shiny','shinyjs','shinydashboard','shinyBS','shinytoastr', 'shinyTree', 'shinyAce'),
      function(x) suppressPackageStartupMessages( require(x, character.only = TRUE, quietly = TRUE) ))
    options(stringsAsFactors = FALSE)


# global sets
  F = phenology()
 
