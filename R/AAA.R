

#' @title 		Breding BIrd Planer (v2)
#' @description 	Mapping and field work organiser
#' @docType 		package
#' @name 		bib2
#' @usage
#' The user interface is installed at in at http://scidb.mpio.orn.mpg.de
#'

.onLoad <- function(libname, pkgname){
    dcf <- read.dcf(file=system.file('DESCRIPTION', package=pkgname) )
    packageStartupMessage(paste('This is', pkgname, dcf[, 'Version'] ))

    options(host.bib2      = '127.0.0.1')
    options(user.bib2      = 'bt')
    options(nest.stages   = c( 'U', 'LT' , 'R' ,  'B'  , 'BC' , 'C' , 'LIN'  ,  'E'  , 'WE', 'Y', 'NOTA', 'WSP')  )
    options(nest.stages.col   = c('#EEE9BF', '#8DB6CD', '#8B7E66', '#7CFC00', '#4CBB17', '#426F42', 
                                                  '#9B2CEE' , '#FFD700', '#EE7600', '#EE0000', '#E5E5E5', '#FF3399') )

    
    }

