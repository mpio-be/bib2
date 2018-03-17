

#' @title 		Breding BIrd Planer (v2)
#' @description Mapping and field work organiser
#' @docType 	package
#' @name 		bib2
#' @usage
#' The user interface is available from http://scidb.mpio.orn.mpg.de
#'

.onLoad <- function(libname, pkgname){
    dcf <- read.dcf(file=system.file('DESCRIPTION', package=pkgname) )
    packageStartupMessage(paste('This is', pkgname, dcf[, 'Version'] ))


    # Do I run on scidbadmin?
    is.scidbadmin = grepl("192.168.2.124", system('hostname -I', intern = TRUE) )

    # Set DB host & user
    db_host = if(is.scidbadmin) 'scidb.mpio.orn.mpg.de' else '127.0.0.1'
    options(host  = db_host )

    options(host.bib2      =  db_host ) 
    
    options(user.bib2      = 'bt')
    

    # Set nest.* options

    options(nest.stages   
        = c( 'U',         'LT' ,   'R' ,     'B'  ,    'BC' ,    'C' ,    'LIN'  ,    'E'  ,   'WE',    'Y',      'NOTA',  'WSP')  )
    options(nest.stages.col   
        = c('#EEE9BF','#8DB6CD','#82A9CD','#E4AF95','#4CBB17','#4CBB17','#7570b3','#FFD700','#EE7600','#EE0000','#E5E5E5','#FF3399') )

    }

