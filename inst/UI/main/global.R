
# shiny::runApp('inst/UI/main', launch.browser = TRUE)

# settings
    sapply(c('sdb', 'sysmanager', 'bib2','SNB', 'knitr', 'ggplot2', 'ggthemes','digest',
                  'shiny','shinyjs','shinydashboard','shinyBS','shinytoastr', 'shinyTree', 'shinyAce', 'MASS'),
      function(x) suppressPackageStartupMessages( require(x, character.only = TRUE, quietly = TRUE) ))
    options(stringsAsFactors = FALSE)


# global sets
  F = phenology()

# prediction data & model
 B = Breeding()
 hatchingModel = predict_hatchday_model(B, MASS::rlm)  

  
 


