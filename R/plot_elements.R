
#' Maps
#' @export
#' @examples
#' map_base()
#' map_base(family = 'Arial')
#'
#' x = copy(boxesxy)
#' x[, ':=' (g = cut(1:277, 4), f = ifelse( as.numeric(box) < 100, 's', 'l') ) ]
#'
#' map_base(x,  color = 'g')
#' map_base(x, label = 'box3d', size = 2, color = 'f', fill = 'g')
#'
#'
#'
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
#' @rdname map_empty
map_base <- function(dat = boxesxy, size = 2.5, family = 'Times', fontface = 'bold' ,x = 'long', y = 'lat',
                    label = 'box', bottom_ann = paste('Printed on',format(Sys.time(), "%a, %d %b %y %H:%M") ) , ...) {
  map_empty() +

  geom_point(
    data = dat,
    color = 'grey',
    pch = 21,
    size = size,
    aes_string(x = x, y = y, ...)

    ) +

  geom_text(
    data                 = dat,
    family              = family,
    fontface           = fontface,
    size                  = size,
    nudge_y          = -10,

    aes_string(x = x, y = y, label = label, ... )
  ) +

  annotate("text", x = 4417300, y = 5334170, label = bottom_ann, col = 'grey', fontface = "bold") +

  theme( legend.justification = c(0, 1),legend.position = c(0,1) )

  }








