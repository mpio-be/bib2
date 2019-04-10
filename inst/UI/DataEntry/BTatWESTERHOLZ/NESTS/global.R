# ==========================================================================
# NESTS table Data Entry
# shiny::runApp('inst/UI/DataEntry/BTatWESTERHOLZ/NESTS', launch.browser = TRUE)
# 
# ==========================================================================


# settings
  sapply(c('bib2','DataEntry', 'data.table', 'shinyjs', 'shinyBS'),
    require, character.only = TRUE, quietly = TRUE)

  user            = 'bt'
  host            =  getOption('host.bib2') 
  pwd             = sdb::getCredentials(user, db, host )$pwd
  db              = 'FIELD_BTatWESTERHOLZ'
  tableName       =  'NESTS'
  n_empty_lines   = 60
   excludeColumns = 'N_pk'

# data
  H = emptyFrame(user, host, db, pwd, tableName, n = n_empty_lines, excludeColumns, 
        preFilled = list(
            date_time = as.character(Sys.Date()) ) 
        )
  H[, box := as.integer(box)]
  comments = column_comment(user, host, db, pwd, tableName,excludeColumns)


  # validator parameters
    nest_stages = c('NOTA','WSP', 'U', 'LT','R','B','BC','C','LIN','E','Y')
    nest_failed_reasons = c('R', 'P', 'D', 'H', 'U')
    authors = dbq(user = user, host = host, q = paste0('SELECT initials from ', db, '.AUTHORS UNION 
                          SELECT distinct initials from BTatWESTERHOLZ.AUTHORS') )$initials


# inspector [ runs on the handsontable output]
  inspector.NESTS <- function(x) {

    v1 = is.na_validator(x[, .(date_time, author, box, nest_stage)])
    v2 = POSIXct_validator(x[ , .(date_time)] )
    
    v3 = is.element_validator(x[ , .(nest_stage)], data.table(variable = 'nest_stage', set = list(nest_stages) ))
    v4 = is.element_validator(x[ , .(nest_failed)], data.table(variable = 'nest_failed', set =  list(nest_failed_reasons) ))
    v5 = is.element_validator(x[ , .(authors)], data.table(variable = 'authors', set = list( authors ) ))

    v6 = interval_validator( x[, .(box)], v = data.table(variable = 'box', lq = 1, uq = 277 ) )
    colNams = c('femaleLeft', 'warm_eggs','eggs_covered') 
    v7 = interval_validator(subset(x, select = colNams) , data.table(variable = colNams , lq = 0, uq = 1 ) )
    
    colNams = c('eggs', 'chicks', 'age_chicks_processing',  'collect_eggs', 'dead_eggs', 'dead_chicks')
    vvv = data.table(variable = colNams , lq = c(1,1, 13, 1, 1, 1), uq = c(14,14, 15, 15, 15, 15) ) 
    v8 = interval_validator(subset(x, select = colNams) ,  vvv)

    v9 = interval_validator(subset(x, select = 'female_inside_box') , data.table(variable = 'female_inside_box' , lq = 1, uq = 2 ) )
    
    colNams = c('herbs', 'guessed')
    v10 = is.identical_validator(subset(x, select = colNams) , data.table(variable = colNams , x = 1) )
 
    o = list(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10) %>% rbindlist
    o[, .(rowid = paste(rowid, collapse = ',')), by = .(variable, reason)]
    }


# table summary function
    table_smry <- function() {
      x = bibq('select * FROM NESTS')

      data.table(
          N_entries = nrow(x)

             )



    }