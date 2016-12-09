

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
        boxesxy[, box3d := str_pad(box, 3, 'left', pad = '0') ]

        save(map_layers, file = './data/map_layers.RData')
        save(boxesxy, file = './data/boxesxy.RData')

