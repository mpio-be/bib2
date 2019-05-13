# ==========================================================================
# NESTS table Data Entry
# shiny::runApp('inst/UI/DataEntry/BTatWESTERHOLZ/NESTS', launch.browser = TRUE)
# 
# ==========================================================================


# settings
  sapply(c('bib2','DataEntry', 'DataEntry.validation', 'data.table', 'shinyjs', 'shinyBS'),
    require, character.only = TRUE, quietly = TRUE)

  host            =  getOption('host.bib2') 
  db              = 'FIELD_BTatWESTERHOLZ'
  user            = 'bt'
  pwd             = sdb::getCredentials(user, db, host )$pwd
  
  tableName       =  'NESTS'
  package         = 'bib2'
  excludeColumns = 'N_pk'
  n_empty_lines   = 60

# table summary function
    describeTable <- function() {
      x = bibq('select * FROM NESTS')

      data.table(
          N_entries = nrow(x)

             )
    }

comments = column_comment(user, host, db, pwd, tableName,excludeColumns)


# Define UI table  
  nest_stages = c('NOTA','WSP', 'U', 'LT','R','B','BC','C','LIN','E','Y')
  authors = dbq(user = user, host = host, q = paste0('SELECT initials from ', db, '.AUTHORS UNION 
                        SELECT distinct initials from BTatWESTERHOLZ.AUTHORS') )$initials

  uitable = emptyFrame(user, host, db, pwd, tableName, n = n_empty_lines, excludeColumns, 
    preFilled = list( date_time = as.character(Sys.Date()) ) ) %>% 
    rhandsontable %>% 
    hot_cols(columnSorting = FALSE, manualColumnResize = TRUE) %>%
    hot_rows(fixedRowsTop = 1) %>%
    hot_col(col = "nest_stage", type = "dropdown", source = nest_stages ) %>%
    hot_col(col = "author", type = "dropdown", source = authors )



