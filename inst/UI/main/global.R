
# shiny::runApp('inst/UI/main', launch.browser = TRUE)

# settings
    sapply(c('bib2','SNB2',   'MASS',
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

  
 options(host.bib2 = 'scidb.mpio.orn.mpg.de')


