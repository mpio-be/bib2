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
#' \donttest{
#' map_empty() 
#' }
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
#' \donttest{
#' map_base(family = 'sans') 
#' }
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
#' @param   notes notes under legend annotations
#' @param   nx    notes x location
#' @param   ny    notes y location
#' @examples
#' \donttest{
#'  x = nests(Sys.Date() - 1 )
#'  notes = c('note 1: this is note 1\nnote 99: this is note 99\nnote 9999+1: this is note 9999+1')
#'  n = nest_state(x, hatchingModel = predict_hatchday_model(Breeding(), rlm) )
#'  map_nests(n)  
#'  map_nests(n, notes = notes) + print_ann() 
#'}
#' 
map_nests <- function(n, size = 2.5, family = 'sans', fontface = 'plain', 

    title  = paste('made on:', Sys.Date() ),  notes = '', nx = -20, ny = 650)  {

    legend = nest_legend(n)

    nxy = merge(n, boxesxy, by= 'box')

    # frame
    map_empty()+
        theme( legend.justification = c(0, 1),
            legend.position = c(0,1) ) + 
        ggtitle(title) + map_legend() + 
    # boxes
    geom_point(data = boxesxy, color = 'grey', pch = 21, size = size, 
        aes(x = long, y = lat) ) + 
    geom_text( data = boxesxy, hjust = 'left', nudge_x = 5, family  = family, fontface = fontface, size = size, 
        aes(x = long, y = lat, label = box) )+ 
    
    # nest stage  
    geom_point(data = nxy, pch = 19, size = size, 
        aes(x = long, y = lat, color = nest_stage), na.rm = TRUE ) +
     scale_colour_manual(values = legend$col , labels = legend$labs ) +
    # last check
    geom_text(data = nxy, 
        aes(x = long, y = lat, label = lastCheck), 
        hjust = 'right', nudge_x = -5,size = size, family = family) +
    # nest stage age
    geom_text(data = nxy,
        aes(x = long, y = lat, label = AGE), vjust = 'bottom', nudge_y = 5,
        size = size, family = family)+
    # clutch | chicks
    geom_text(data =  nxy[!is.na(ECK)] ,
        aes(x = long, y = lat, label = ECK), vjust = 'top', nudge_y = -5,
        size = size, family = family) + 

    guides( color = guide_legend(title = NULL, ncol = 3)) + 
    
    annotate('text', size = size+1, x = nx, y = ny, 
        hjust = 'left',  vjust = 'top',
     label= notes) 
    
        
    
    }


#' @export
#' @rdname maps
#' @param   exp_id   the id of the experiment as defined in the experiments table.
#' @return  a list of geoms to append to map_nests()
#' @examples
#' \donttest{
#'  x = map_experiment(2)
#' }
map_experiment <- function(exp_id) {

    x = bibq( paste('SELECT * FROM EXPERIMENTS 
        WHERE ID = ', exp_id) )$R_script

    x = stringr::str_replace_all(x, '\r\n', '\n')

    fallback = glue('function() {{ 
                list(ggtitle("Experiment {exp_id} cannot be shown.Review the EXPERIMENTS table!")) }}')

    if( length(x)>0 && nchar(x) > 0) {
        f = glue('function() {{ 
                    {x} 
                
                }}' )
    } else
        f = fallback

    o = try( eval(parse( text= f ) ), silent = TRUE)
    if(inherits (o, 'try-error')) o = eval(parse( text= fallback ) )

    o



    }


    