
#' allAdults
#' @export
#' @examples
#' \donttest{
#' x = Breeding()
#' }
Breeding <- function() {
	bibq("select year_,box,IDfemale,firstEgg,clutch, laying_gap, hatchDate FROM BTatWESTERHOLZ.BREEDING 
	WHERE secondClutch = 0  and firstEgg is not NULL and hatchDate is not NULL and laying_gap < 4
			order by year_, firstEgg")
	}


#' allAdults
#' @export
#' @examples
#' \donttest{
#' x = allAdults()
#' }
allAdults <- function() {
	a = bibq("SELECT a.ID, capture_date_time datetime_, age, weight, s.sex FROM BTatWESTERHOLZ.ADULTS a 
			LEFT JOIN BTatWESTERHOLZ.SEX s 
					ON a.ID = s.ID ")

	x = bibq("SELECT a.ID, date_time_caught  datetime_, age, weight, s.sex FROM ADULTS a 
			LEFT JOIN BTatWESTERHOLZ.SEX s 
					ON a.ID = s.ID ")
		rbind(a, x)
	}

#' adults
#' @export
#' @examples
#' \donttest{
#' x = adults
#' }
adults <-   function(refdate = Sys.Date(), ...) {
	x = bibq("SELECT upper(a.ID) ID,  lower(FUNCTIONS.combo(UL,LL, UR, LR)) combo,  date_time_caught  datetime_, age, weight, tarsus, a.sex, s.sex gsex 
				FROM ADULTS a 
						LEFT JOIN BTatWESTERHOLZ.SEX s 
								ON a.ID = s.ID ", ...)
	suppressWarnings( x[!is.na(gsex), sex := gsex] )
	x[, gsex := NULL]
			x[ round(as.Date(datetime_))  <= round(as.Date(refdate))  ]

	}

#' nests
#' @export
#' @examples
#' \donttest{
#' nests() %>% head
#' }
nests <-   function(refdate = Sys.Date() ) {
		
	sql = paste("SELECT * FROM NESTS  
					WHERE nest_stage is not  NULL and date_time is not NULL and date_time <=", shQuote(refdate))

	x = bibq(sql, year = year(refdate)  )

	setattr(x, 'refdate', refdate)
	x


	}


#' nest_state
#' @export
#' @param x             a data.table as returned by nests()
#' @param nesr_stages   character vector
#' @param hatchingModel a model to use for prediction

#' phenology
#' @export
#' @param  minimum_stage (one of "LT", "B", "C", "LIN", "firstEgg","hatchDate","fledgeDate") default to "C"
#' @examples
#' \donttest{
#' phenology()
#' }
phenology <-  function(minimum_stage = 'C') {

	s = data.table(
			# def by the input of this function
			stage_code  = c("LT", "B", "C", "LIN", "firstEgg","hatchDate","fledgeDate"), 
			 # def by db
			stage       =  c("date_LT", "date_B", "date_C", "date_LIN", "firstEgg","hatchDate","fledgeDate"),
			# def by the output of this function
			stage_name  =  c("firstLittle", "firstBottom", "firstCup", "firstLining", "firstEgg","hatchDate","fledgeDate"), 
			stage_id    = 1:7
			)
	if(!missing(minimum_stage))
	ss= s[ stage_id >= s[stage_code == minimum_stage]$stage_id] else ss = s

	n = bibq('select year_, box,  date_LT, date_B,date_C, date_LIN from BTatWESTERHOLZ.NESTS')
	b = bibq('select year_, box, firstEgg,hatchDate,fledgeDate  from BTatWESTERHOLZ.BREEDING')

	d = merge(n, b, all.x = TRUE, all.y = TRUE, by = c('year_', 'box') )

	d = melt(d, id.vars  = c('year_', 'box'), na.rm = TRUE, value.name = 'date_')


	d = merge(d, ss[, .(stage,stage_name)], by.x = 'variable', by.y = 'stage')
	d[, variable := NULL]
	setnames(d, 'stage_name', 'variable') # not to break upstream functions

	d


	}




#' RINGS_FOR_RADO
#' @export
#' @param seasons           season(s) from which the data is required. Can be vector or number. 
#' 													Note that this refers to the season, not to the calendar year 
#' 													(e.g. 2018 is summer 2017 through spring 2018)
#' @param new_ring          date and time when a bird recieved a new metal band. Only necessary if 
#' 													there is any chance that the bird was caught in between somewhere else
#' @param not_banded_by_us  band numbers of birds that were banded elsewhere should be provided as a vector
#' @examples
#' \dontrun{
#' path = RINGS_FOR_RADO(seasons = 2018)
#' }
RINGS_FOR_RADO = function(seasons = c(2018),new_ring = data.table(ID = c('B4H1627'), date_time = c("2014-11-08 10:02:00")),not_banded_by_us = c("TN90629") ) {

	#dependencies
	require(xlsx)
 
	#fetch adults and rename/redefine according to the specifications by Radolfszell
		
		ad = bibq(paste0("SELECT * FROM BTatWESTERHOLZ.ADULTS where season in (", paste(seasons, collapse = ', '), ")"))
		ad[, Ringnummer := ID]
		ad[, Status := "O"]
		ad[month(capture_date_time) %in% c(4,5,6), Status := "N"]
		ad[, Fangmethode := 0]
		ad[catch_method %in% c("box", "nestbox"), Fangmethode := 1]
		ad[catch_method  == "mistnet", Fangmethode := 2]
		ad[catch_method  == "snaptrap", Fangmethode := 4]

		ad[, Lockmethode := "0"]
		ad[Fangmethode == 1, Lockmethode := "8"]
		ad[Fangmethode == 2, Lockmethode := "1"]
		ad[Fangmethode == 4, Lockmethode := "4/5"]

		ad[, P8 := P3]

		ad[, Gewicht := weight]

		ad[, Tarsus := round(tarsus, digits = 1)]
		ad[, dtmLastUpdateDate := Sys.Date()]
		ad[, Bemerkungen := ""]

		#at first capture assumably all birds were bled, errors in the database, over-ride:
		ad[, tmp := (capture_date_time == min(capture_date_time)), by = ID]
		ad[tmp == TRUE, blood := as.integer(1)]
		ad[, tmp := NULL]
		ad[blood == 1, Bemerkungen := "Blutprobe"]

		#fill in ring colours
		ad[UL == "p", UL := "pink"]; ad[LL == "p", LL := "pink"]; ad[UR == "p", UR := "pink"]; ad[LR == "p", LR := "pink"]
		ad[UL == "y", UL := "yellow"]; ad[LL == "y", LL := "yellow"]; ad[UR == "y", UR := "yellow"]; ad[LR == "y", LR := "yellow"]
		ad[UL == "r", UL := "red"]; ad[LL == "r", LL := "red"]; ad[UR == "r", UR := "red"]; ad[LR == "r", LR := "red"]
		ad[UL == "o", UL := "orange"]; ad[LL == "o", LL := "orange"]; ad[UR == "o", UR := "orange"]; ad[LR == "o", LR := "orange"]
		ad[UL == "w", UL := "white"]; ad[LL == "w", LL := "white"]; ad[UR == "w", UR := "white"]; ad[LR == "w", LR := "white"]
		ad[UL == "m", UL := "metal"]; ad[LL == "m", LL := "metal"]; ad[UR == "m", UR := "metal"]; ad[LR == "m", LR := "metal"]
		ad[UL == "b", UL := "blue"]; ad[LL == "b", LL := "blue"]; ad[UR == "b", UR := "blue"]; ad[LR == "b", LR := "blue"]
		ad[UL == "g", UL := "green"]; ad[LL == "g", LL := "green"]; ad[UR == "g", UR := "green"]; ad[LR == "g", LR := "green"]
		ad[UL == "l", UL := "lilac"]; ad[LL == "l", LL := "lilac"]; ad[UR == "l", UR := "lilac"]; ad[LR == "l", LR := "lilac"]
		ad[is.na(UL), UL := '-']; ad[is.na(LL), LL := '-']; ad[is.na(UR), UR := '-']; ad[is.na(LR), LR := '-']

		ad[, Bemerkungen := paste(paste("Farbberingung: links: ", UL, LL, ", rechts: ", UR, LR, sep = " "), Bemerkungen, sep = "; ")]
		ad[dead == 1, Bemerkungen := paste(Bemerkungen, "tot aufgefunden", sep = "; ")]
		ad[, Zustand_bei_Fund := "8"]
		ad[Zustand_bei_Fund == 8, Funddetails := 0]
		ad[, Wiederfundchancen := "1"]
		ad[(!is.na(UL) & UL != 'm') | (!is.na(LL) & LL != 'm') | (!is.na(UR) & UR != 'm') | (!is.na(LR) & LR != 'm'), Wiederfundchancen := "4"]
		ad[blood == 1, Wiederfundchancen := paste0(Wiederfundchancen, "M")]
		ad[, Geschlecht := sex]
		ad[is.na(Geschlecht), Geschlecht := 0]
		ad[, Alter := age+2]
		ad[is.na(Alter), Alter := 2]
		ad[, Datum_Zeit:= capture_date_time]

	#fetch chicks and rename/redefine according to the specifications by Radolfszell
		
		ch = bibq(paste0("SELECT * FROM BTatWESTERHOLZ.CHICKS where year_ in (", paste(seasons, collapse = ', '), ")"))
		ch = subset(ch, nchar(ID) == 7)
		ch[, Ringnummer := ID]
		ch[, Status := length(ID), by = list(year_, box)]
		ch[, Nestlingsalter := 14]
		ch[, Genauigkeit_Nestlingsalter := 1]
		ch[, Fangmethode := 1]
		ch[, Lockmethode := 8]
		ch[, Fluegellaenge := NA]
		ch[, Gewicht := weight]
		ch[, Tarsus := round(tarsus, digits = 1)]
		ch[, dtmLastUpdateDate := Sys.Date()]
		ch[, Bemerkungen := "Blutprobe"]
		ch[dead_chick == 1, Bemerkungen := paste(Bemerkungen, "spaeter im Nest tot aufgefunden", sep = '; ')]
		ch[, Zustand_bei_Fund := 8]
		ch[Zustand_bei_Fund == 8, Funddetails := 0]

		ch[, Wiederfundchancen := "1"]
		ch[, sample := "blood"]
		ch[sample == "blood", Wiederfundchancen := "1M"]
		ch[, Geschlecht := 0]
		ch[, Alter := 1]
		ch[, Datum_Zeit:= date_time]

		ch[is.na(Datum_Zeit), Datum_Zeit := implant_date]

	#fetch "fixed" columns as defined by Radolfszell
		Art = 14620
		Genauigkeit_Datum = 0
		Regionencode = "DEAO" #Oberbayern
		Idgeotab = 1
		Genauigkeit_Koordinaten = "0"
		tk25 = 7831
		Beringernummer = "Bart Kempenaers"
		Fluegellaenge = NA
		Netznummer = NA
		Projekt = ''
		Laengengrad = 10.890
		Breitengrad = 48.143
		Beringungszentrale = "DER" #Radolfszell
		verification = 0
		Fundumstaende = 20
		Aenderungen_am_Ring = 0
		new_ring_scheme = ""
		new_ring_number = ""
		Ortsname = "Reiherschlag"

	#combine datasheets
		full = rbind(ad, ch, fill = TRUE)
		full[, ':=' (Art = Art,
									 Genauigkeit_Datum = Genauigkeit_Datum,
									 Regionencode = Regionencode,
									 Idgeotab = Idgeotab,
									 Genauigkeit_Koordinaten = Genauigkeit_Koordinaten,
									 tk25 = tk25,
									 Beringernummer = Beringernummer,
									 Fluegellaenge = Fluegellaenge,
									 Netznummer = Netznummer,
									 Projekt = Projekt,
									 Laengengrad = Laengengrad,
									 Breitengrad = Breitengrad,
									 Beringungszentrale = Beringungszentrale,
									 verification = verification,
									 Fundumstaende = Fundumstaende,
									 Aenderungen_am_Ring = Aenderungen_am_Ring,
									 new_ring_scheme = new_ring_scheme,
									 new_ring_number = new_ring_number,
									 Idopen = 0
									 )]


		#which data belong to which sheet? (recaptures (2) vs. first captures (1))
		full[, first_capture := ifelse(Datum_Zeit == min(Datum_Zeit), 1, 2), by = ID]
		full[ID %in% not_banded_by_us, first_capture := 2]

		#reformat datetime columns
		full[, dtmLastUpdateDate := format(dtmLastUpdateDate, format = "%d.%m.%y")]
		full[, Datum_Zeit := as.POSIXct(Datum_Zeit, origin = "1970-01-01")]
		full[, Datum_Zeit := format(Datum_Zeit, format = "%d.%m.%y %H:%M")]

	#make final sheets, order columns as specified by Radolfszell
		
		#Sheet 1
		nameorder_sheet1 = c('Beringungszentrale', 'Ringnummer', 'Art', 'Wiederfundchancen', 'Geschlecht', 'Alter', 'Status', 'Nestlingsalter', 'Genauigkeit_Nestlingsalter', 'Datum_Zeit', 'Genauigkeit_Datum', 'Regionencode', 'Idgeotab', 'Genauigkeit_Koordinaten', 'tk25', 'Beringernummer', 'Fangmethode', 'Lockmethode', 'Fluegellaenge', 'P8', 'Gewicht', 'Tarsus', 'dtmLastUpdateDate', 'Bemerkungen', 'Netznummer', 'Projekt', 'Laengengrad', 'Breitengrad', 'dead')
		sheet1 = subset(full, first_capture == 1, select = nameorder_sheet1)

		#Sheet 2
		nameorder_sheet2 = c('Idopen', 'Beringungszentrale', 'Ringnummer', 'Datum_Zeit', 'Art', 'verification', 'Geschlecht', 'Alter', 'Status', 'Genauigkeit_Datum', 'Regionencode', 'Idgeotab', 'Genauigkeit_Koordinaten', 'tk25', 'Zustand_bei_Fund', 'Fundumstaende', 'Funddetails', 'Beringernummer', 'Aenderungen_am_Ring', 'Fangmethode', 'Lockmethode', 'Fluegellaenge', 'P8', 'Gewicht', 'Tarsus', 'dtmLastUpdateDate', 'new_ring_scheme', 'new_ring_number', 'Bemerkungen', 'Netznummer', 'Projekt', 'Laengengrad', 'Breitengrad')
		sheet2 = subset(full, first_capture == 2, select = nameorder_sheet2)
		sheet2[, Idopen := 1:nrow(sheet2)]
		sheet2[, Aenderungen_am_Ring := 0]
		#add ring changes
		sheet2[Ringnummer %in% new_ring[,ID] & Datum_Zeit %in% new_ring[,date_time], Aenderungen_am_Ring := 3]

		#Sheet 3
		sheet3 = data.table(Idgeotab = Idgeotab, Laengengrad = Laengengrad, Breitengrad = Breitengrad, Ortsname = Ortsname, dtmLastUpdateDate = Sys.Date())

		#Sheet 4
		#probably not needed, not implemented for now
		

	# export to excel; this automatically creates the different sheets required by Radolfszell!

		wb = openxlsx::createWorkbook()
		worksheet1 = openxlsx::createSheet(wb, sheetName = 'BERINGUNG')
		worksheet2 = openxlsx::createSheet(wb, sheetName = 'FUND')
		worksheet3 = openxlsx::createSheet(wb, sheetName = 'GEOTAB')

		openxlsx::addDataFrame(sheet1, worksheet1)
		openxlsx::addDataFrame(sheet2, worksheet2)
		openxlsx::addDataFrame(sheet3, worksheet3)


		p = tempfile(pattern = "RINGS", fileext = ".xlsx") #create temporary path
		openxlsx::saveWorkbook(wb, file = p)


		p #return temporary path in order to find the file
	}


