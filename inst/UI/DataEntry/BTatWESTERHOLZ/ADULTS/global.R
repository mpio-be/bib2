
# shiny::runApp('inst/UI/DataEntry/BTatWESTERHOLZ/ADULTS', launch.browser = TRUE)

 source(system.file('UI', 'global_settings.R', package = 'bib2'))


tableName       =  'ADULTS'
excludeColumns  = c('ad_pk', 'recapture')
n_empty_lines   =  30


describeTable <- function() {
	x = bibq('select ID, transponder,  author, sex, age from ADULTS where ID is not NULL')

	data.table(
			N_entries = nrow(x), 
			N_unique_IDs = length(unique(x$ID))
				 )
}

comments = column_comment(user, host, db, pwd, tableName,excludeColumns)


# Define UI table  
uitable = emptyFrame(user, host, db, pwd, tableName, n = n_empty_lines, excludeColumns, 
	preFilled = list( date_time_caught = format(Sys.Date(), "%Y-%m-%d %H:%M")  ) ) %>% 
	rhandsontable %>% 
	hot_cols(columnSorting = FALSE, manualColumnResize = TRUE) %>%
	hot_rows(fixedRowsTop = 1) 



