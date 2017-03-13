#' @name maps
#' @title  maps
NULL

#' @export
#' @rdname maps
map_empty <- function() {

  ggplot() +
    geom_polygon(data = map_layers[nam == 'buildings'] , aes(x=long, y=lat, group=group), size = .2, fill = 'grey95', col = 'grey60' ) +
    geom_path(data =  map_layers[nam == 'streets'], aes(x=long, y=lat, group=group) , size = .2, col = 'grey60' ) +

    coord_equal(ratio=1) +
    scale_x_continuous(expand = c(0,0), limits =  map_layers[nam == 'streets', c( min(long), max(long) )]  ) +
    scale_y_continuous(expand = c(0,0)) +

   theme(
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),

          panel.background = element_blank(),
          panel.border = element_blank(),
          panel.grid = element_blank(),
          panel.spacing = unit(0, "lines"),

          plot.background = element_blank(),
          plot.margin = unit(c(0,0,0,0), "in")
          )

  }

#' @export
#' @rdname maps
#' @examples
#' map_base(family = 'Times')
map_base <- function(size = 2.5, family = 'Times', fontface = 'bold', bottom_ann = paste('Printed on',format(Sys.time(), "%a, %d %b %y %H:%M")) ) {
      g = 
      map_empty() +
      
      geom_point(data = boxesxy, color = 'grey', pch = 21, size = size,
        aes(x = long, y = lat) ) + 
      
      geom_text(data = boxesxy,family  = family,fontface = fontface, size= size,nudge_y= -10,
        aes(x = long, y = lat, label = box) ) + 

      annotate("text", x = 4417300, y = 5334170, label = bottom_ann, col = 'grey', fontface = "bold") +
      theme( legend.justification = c(0, 1),legend.position = c(0,1) )

      g
}

#' @export
#' @rdname maps
#' @param   n     a data.table returned by  nests()
#' @param   title goes to ggtitle (should be the reference date)
#' @examples
#'  rdate = Sys.Date() - 1
#'  n = nests(rdate) %>% nest_state(ref_date  =rdate )
#'  map_nests(n)
map_nests <- function(n, size = 2.5, family = 'Times', fontface = 'bold', 
     title      = paste('made on:', Sys.Date() ), 
     bottom_ann = paste('Printed on',format(Sys.time(), "%a, %d %b %y %H:%M")) ) {

     # legend data
        ld =  n[, .N, by = nest_stage]
        x = data.table( nscol = getOption('nest.stages.col'), nest_stage = getOption('nest.stages') )
        ld = merge(ld, x, by = 'nest_stage')
        nsc = ld$nscol ; names(nsc) =  ld$nest_stage

      g = 
        map_empty() +
        
        geom_point(data = boxesxy, color = 'grey', pch = 21, size = size, aes(x = long, y = lat) ) + 

        geom_point(data=n, pch = 19, size = size, aes(x = long, y = lat, color = nest_stage) ) + 
          scale_colour_manual(values = nsc, labels = paste0(ld$nest_stage, ' [',ld$N,']') ) +

        geom_text(data = boxesxy,family  = family,fontface = fontface, size= size, nudge_y= -10, aes(x = long, y = lat, label = box) ) +
        geom_text( data = n, nudge_x = 10, size = size, family = family, fontface = 'italic', aes(x = long, y = lat, label = lastCheck) ) + 

        annotate("text", x = 4417300, y = 5334170, label = bottom_ann, col = 'grey', fontface = "bold") +
        theme( legend.justification = c(0, 1),legend.position = c(0,1) ) + 
        ggtitle(title)

      g
}



