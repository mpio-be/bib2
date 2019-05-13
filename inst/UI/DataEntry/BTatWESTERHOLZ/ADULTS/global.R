# ==========================================================================
# ADULTS table Data Entry
# shiny::runApp('inst/UI/DataEntry/BTatWESTERHOLZ/ADULTS', launch.browser = TRUE)
# 
# ==========================================================================

# settings
	sapply(c('bib2','DataEntry', 'DataEntry.validation', 'data.table', 'shinyjs', 'tableHTML', 'glue'),
		require, character.only = TRUE, quietly = TRUE)
	tags = shiny::tags

	host            =  getOption('host.bib2')
	db              = 'FIELD_BTatWESTERHOLZ'
	user            = 'bt'
	pwd             = sdb::getCredentials(user, db, host )$pwd

	tableName       =  'ADULTS'
	package         = 'bib2'
	excludeColumns  = 'ad_pk'
	n_empty_lines   =  30

# table summary function
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



