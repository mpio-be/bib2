
#' Nests table
#'
#' Nests table for printing
#'
#' @param n     a data.table returned by  nests()
#'
#' @return path to output file
#' @export
#' @importFrom openxlsx createWorkbook  addWorksheet freezePane createStyle setColWidths
#' @importFrom openxlsx saveWorkbook insertImage  writeData
#' 
#' @examples
#' \dontrun{
#'  x = nests(Sys.Date() - 1 )
#'  n = nest_state(x, hatchingModel = predict_hatchday_model(Breeding(), rlm) )
#'  p = nest_table(n)
#' }
#' 

nest_table <- function(n, file = tempfile(fileext = '.xlsx') ) {

    # prepare file
        data(boxesxy2)
        wo = boxesxy2[, .(box, walk_order)]
        x = merge(wo, n, by = 'box', sort = FALSE)

        o = x[, .(box, Stage = nest_stage, lastCheck, age = AGE, Eggs_or_Chicks = ECK, days_to_hatch = days_to_hatch)]

    # map
        m = map_nests(n)
        mfile = tempfile(fileext='.png')
   
        png(file = mfile, width = 2480, height = 3508, res = 400)
        plot(m)
        dev.off()
   


    
    # save to excel
        wb = createWorkbook()
        addWorksheet(wb, "Nests")
        freezePane(wb, 'Nests', firstRow = TRUE)
        head <- createStyle(halign = "CENTER", textDecoration = "bold",border = "Bottom")
        setColWidths(wb, 'Nests', cols = 1:nrow(o), widths = "auto")

        writeData(wb, 'Nests', o, borders = "all")

        insertImage(wb, 'Nests', mfile,  width = 21, height = 29.7, startRow = 2, startCol = "G", units = "cm")

        saveWorkbook(wb,file,overwrite = TRUE)
        Sys.chmod(file)

 }


