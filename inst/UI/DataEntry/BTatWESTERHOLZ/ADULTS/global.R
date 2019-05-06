# ==========================================================================
# ADULTS table Data Entry
# shiny::runApp('inst/UI/DataEntry/BTatWESTERHOLZ/ADULTS', launch.browser = TRUE)
# 
# ==========================================================================

# settings
	sapply(c('bib2','DataEntry', 'data.table', 'shinyjs', 'tableHTML', 'glue'),
		require, character.only = TRUE, quietly = TRUE)
	tags = shiny::tags

	host            =  getOption('host.bib2')
	db              = 'FIELD_BTatWESTERHOLZ'
	user            = 'bt'
	pwd             = sdb::getCredentials(user, db, host )$pwd

	tableName       =  'ADULTS'
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


	# validator parameters
	measures      = dbq(user = user, host = host, q = 'select tarsus, weight, P3 from BTatWESTERHOLZ.ADULTS')
	measures      = melt(measures)[!is.na(value)]
	measures      = measures[, .(lq = quantile(value, 0.005), uq = quantile(value, 0.995)), by = variable]
	nchar         = data.table(variable = c('ID', 'UL', 'LL', 'UR', 'LR', 'transponder', 'age', 'sex'), n = c(7, 1, 1, 1, 1, 16, 1, 1) )
	
	transponders  = dbq(user = user, host = host, q = "select * from COMMON.TRANSPONDERS_LIST")
	preDefined1   = data.table( variable = 'transponder', set = c(list(transponders$transponder)))
	preDefined2   = data.table( variable = 'box',         set = c(list(1:277)))


# inspector
	inspector.ADULTS <- function(forv) {
		z = copy(forv)

		i1 = is.na_validator(z[, .(date_time_caught, author)])
		i2 = is.na_validator(z[is.na(recapture), .(age,tarsus,weight,P3,transponder)])[, reason := 'mandatory at first recapture']
		i3 = POSIXct_validator(z[ , .(date_time_caught)])
		i4 = hhmm_validator(z[ , .(handling_start,handling_stop,release_time)])
		i5 = interval_validator(z[ , .(tarsus,P3, weight)], measures)
		i6 = nchar_validator(z[ , .(ID,UL,LL,UR,LR,transponder,age,sex)], nchar)
		
		i7 = is.element_validator(z, preDefined1, reason = 'transponder does not exist!')
		i8 = is.element_validator(z, preDefined2, reason = 'box does not exist!')


		o = list(i1, i2, i3, i4, i5, i6, i7, i8) %>% rbindlist
		o = o[, .(rowid = paste(rowid, collapse = ',')), by = .(variable, reason)]
		o

		}


