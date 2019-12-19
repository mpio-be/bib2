


# Tools, data
sapply(c('DataEntry', 'DataEntry.validation', 'bib2' , 
       'data.table', 'shinyjs', 'tableHTML', 'glue', 'stringr', 'magrittr', 
       'shinyWidgets'),
        function(x) suppressPackageStartupMessages(require(x , 
            character.only = TRUE, quietly = TRUE) ) )

package = 'bib2'
tags    = shiny::tags
host    = getOption('host.bib2')
db      = 'FIELD_BTatWESTERHOLZ'
user    = 'bt'
pwd     = sdb::getCredentials(user, db, host )$pwd


