
# shiny::runApp('inst/UI/main', launch.browser = TRUE)

# settings
    sapply(c('bib2', 'MASS',
             'magrittr', 'stringr', 'knitr', 'glue'  , 
             'ggplot2', 'ggthemes','digest','ggrepel',
             'shiny','shinyjs','shinydashboard','shinyBS','shinytoastr', 'shinyTree', 'shinyAce'),
      function(x) suppressPackageStartupMessages( require(x, character.only = TRUE, quietly = TRUE) ))
    options(stringsAsFactors = FALSE)


# global sets
  F = phenology()

# prediction data & model
 B = Breeding()
 hatchingModel = predict_hatchday_model(B, MASS::rlm)  

  
package = 'bib2'
tags    = shiny::tags
host    = getOption('host.bib2')
db      = 'FIELD_BTatWESTERHOLZ'
user    = 'bt'
pwd     = sdb::getCredentials(user, db, host )$pwd

