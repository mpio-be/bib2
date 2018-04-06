#' @name maps
#' @title  maps
NULL

#' @export
#' @rdname maps
theme_bib2  <- function() {
  theme(
    axis.line        = element_blank(),
    axis.text        = element_blank(),
    axis.ticks       = element_blank(),
    axis.title       = element_blank(),

    panel.background = element_blank(),
    panel.border     = element_blank(),
    panel.grid       = element_blank(),
    panel.spacing    = unit(0, "lines"),

    plot.background  = element_blank(),
    plot.margin      = unit(c(0,0,0,0), "in")
    )
  }

#' @export
#' @rdname maps
#' @return a list of geoms defining the legend around the box
map_legend <- function(size = 2.5, right = 'box', left = 'checked days ago', 
                        top = 'stage age|days to hatch', bottom = 'eggs|chicks', 
                        x = 543 , y = 735 ) {
    isp = data.frame( x = x, y = y, right, left, top, bottom)
    list( 
    geom_point(data = isp, aes(x = x, y = y), pch = 19, size = size*.5) , 
    geom_text(data  = isp, aes(x = x, y = y, label = right), hjust = 'left', nudge_x = 5) ,
    geom_text(data  = isp, aes(x = x, y = y, label = left), hjust = 'right', nudge_x = -5)  ,
    geom_text(data  = isp, aes(x = x, y = y, label = top), vjust = 'bottom', nudge_y = 7)  ,
    geom_text(data  = isp, aes(x = x, y = y, label = bottom), vjust = 'top', nudge_y = -7) )

   }


#' @export
#' @rdname maps
print_ann <- function(color = 'grey',  x = Inf, y = Inf, vjust = 'bottom', hjust  = 'top', angle = 90) { 
  z = data.frame(
      x = x, 
      y = y, 
      annlabel = paste( 'Printed on',format(Sys.time(), "%a, %d %b %y %H:%M") ), 
      color = color)

    geom_text(data = z ,color = z$color,  vjust =vjust, hjust = hjust, angle =angle,
      aes(x = x, y = y, label = annlabel)  ) 
  }

#' @export
#' @rdname maps
#' @examples
#' map_empty() 
map_empty <- function() {

  ggplot() +
    geom_polygon(data = map_layers[nam == 'buildings'] , aes(x=long, y=lat, group=group), size = .2, fill = 'grey97', col = 'grey97' ) +
    geom_path(data =  map_layers[nam == 'streets'],         aes(x=long, y=lat, group=group) , size = .2, col = 'grey60' ) +

    coord_equal(ratio=1) +
    scale_x_continuous(expand = c(0,0), limits =  map_layers[nam == 'streets', c( min(long), max(long) )]  ) +
    scale_y_continuous(expand = c(0,0)) +

    theme_bib2()

  }


#' @export
#' @rdname maps
#' @examples
#' map_base(family = 'sans') 
map_base <- function(size = 2.5, family = 'sans', fontface = 'plain',printdt = FALSE) {
  g = 
  map_empty() + 
  
  geom_point(data = boxesxy, color = 'grey', pch = 21, size = size,
    aes(x = long, y = lat) ) + 

  geom_text(data = boxesxy,family  = family, fontface = fontface, size= size, nudge_x = 10,
    aes(x = long, y = lat, label = box) ) + 

  theme( legend.justification = c(0, 1),legend.position = c(0,1) ) + 
  if(printdt) print_ann() else NULL

  g  
  }



#' @export
#' @rdname maps
#' @param   n     a data.table returned by  nests()
#' @param   title goes to ggtitle (should be the reference date)
#' @param   notes below legend annotations
#' @examples
#'  n = nests(Sys.Date() - 1 )
#'  ns = nest_state(n, hatchingModel = predict_hatchday_model(Breeding(), rlm) )
#'  map_nests(ns)  
#'  m = map_nests(ns) + print_ann() 
map_nests <- function(n, size = 2.5, family = 'sans', fontface = 'plain', 
                      title  = paste('made on:', Sys.Date() ),  notes = '')  {

    legend = nest_legend(n)

    nxy = merge(n, boxesxy, by= 'box')

    # frame
    map_empty()+
      theme( legend.justification = c(0, 1),legend.position = c(0,1) ) + ggtitle(title) + map_legend() + 
    # boxes
    geom_point(data = boxesxy, color = 'grey', pch = 21, size = size, aes(x = long, y = lat) ) + 
    geom_text( data = boxesxy, hjust = 'left', nudge_x = 5, family  = family, fontface = fontface, size = size, aes(x = long, y = lat, label = box) )+ 
    
    # nest stage  
    geom_point(data = nxy, pch = 19, size = size, aes(x = long, y = lat, color = nest_stage), na.rm = TRUE ) +
     scale_colour_manual(values = legend$col , labels = legend$labs ) +
    # last check
    geom_text(data = nxy, aes(x = long, y = lat, label = lastCheck), hjust = 'right', nudge_x = -5,size = size, family = family) +
    # nest stage age
    geom_text(data = nxy,aes(x = long, y = lat, label = AGE), vjust = 'bottom', nudge_y = 5,size = size, family = family)+
    # clutch | chicks
    geom_text(data =  nxy[!is.na(ECK)] ,aes(x = long, y = lat, label = ECK), vjust = 'top', nudge_y = -5,size = size, family = family) + 

    guides( color = guide_legend(title = NULL, ncol = 3)) + 
    
    annotate('text', x = 0, y = 650, label= paste(l, collapse = '\n') ) 

     
    
    
  
  }


