

    require(rgdal)
    require(data.table)
    require(magrittr)
    require(ggplot2)
    require(stringr)

    # map layers
        streets   = readOGR('./inst/map/src/', 'streets', verbose = FALSE) %>% fortify %>% data.table
        grid      = readOGR('./inst/map/src/', 'grid', verbose = FALSE) %>% data.frame %>% data.table %>% .[, optional := NULL]
        buildings = readOGR('./inst/map/src/', 'farm', verbose = FALSE) %>% fortify %>% data.table

        s =  streets[, .(long, lat, group)][, nam := 'streets'][, type := 'lines']
        b =  buildings[, .(long, lat, group)][, nam := 'buildings'][, type := 'polygon']

        setnames(grid, c('group', 'long', 'lat'))
        grid[, nam := 'grid'][, type := 'points']
        setcolorder(grid, c('long', 'lat', 'group', 'nam', 'type'))

        map_layers = rbindlist(list(s, b, grid))

    # boxes
        boxesxy     = readOGR('./inst/map/src/', 'boxes', verbose = FALSE) %>% data.frame %>% data.table %>% .[, optional := NULL]
        setnames(boxesxy, c('coords.x1' , 'coords.x2') , c('long', 'lat') )
        boxesxy[, box := as.integer(box)]

    # scale (box 1 = c(0,0))   
        longmin = boxesxy[box == 1, long]
        latmin = boxesxy[box == 1, lat]

        map_layers[, long := long - longmin]
        map_layers[, lat := lat - latmin]

        boxesxy[, long := long - longmin]
        boxesxy[, lat := lat - latmin]


    # save 
      save(map_layers, file = './data/map_layers.RData')
      save(boxesxy,    file = './data/boxesxy.RData')





