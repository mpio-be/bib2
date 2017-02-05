

#' @export
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

#' Map w. geom_label()
#' @export
#' @examples
#' map_geom_label(x = 'long', y = 'lat', label = 'box3d', size = 2)
#' x = copy(boxesxy)
#'
#' x[, ':=' (g = cut(1:277, 4), f = ifelse( as.numeric(box) < 100, 's', 'l') ) ]
#' map_geom_label(x = 'long', y = 'lat', label = 'box3d', size = 2, color = 'g', dat = x)
#' map_geom_label(x = 'long', y = 'lat', label = 'box3d', size = 2, color = 'f', fill = 'g', dat = x)
#'
#' require(showtext)
#' showtext.auto(enable = TRUE)
#' font.add.google("Abril Fatface", "Abril Fatface")
#' map_geom_label(x = 'long', y = 'lat', label = 'box3d', size = 2)
#'
map_geom_label <- function(dat = boxesxy, size = 2.5, family = , ...) {

    map_empty() +

    geom_label(
      data          = dat,
      family        = family,
      fontface      = 'bold',
      size          = size,
      label.padding = unit(0.07, "lines"),
      label.r       = unit(0.2, "lines"),
      label.size    = 0.1,
      na.rm         = TRUE,

      aes_string(...)
    ) +

     theme( legend.justification = c(0, 1),legend.position = c(0,1) )


 }


