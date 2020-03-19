
#' data.table to html (boostrap style)
#' @param x  a data.table
#' @export
#' @examples
#' \donttest{
#' boostrap_table( data.table(x = 1, y = 'a') )
#' }
boostrap_table <- function(x, class = 'responsive') {
    paste0( '<div class="table-', class , '"> <table class="table">',  
        knitr::kable(x, format = 'html', align = 'c'), 
        ' </table> </div>' )
  }


#' @export
absDownloadButton <- function(nam, label = 'Download PDF') {
      absolutePanel(right = "0%", top="10%", width = "40%",draggable = TRUE,style = "opacity: 0.9",
      downloadButton(nam,label = label)
      )
}

#' @export
Box <- function(...) {
    shinydashboard::box(...)
    }

