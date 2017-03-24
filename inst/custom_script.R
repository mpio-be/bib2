
# Change the content of customData and customGeoms the way you like 

  customData = data.frame(
    box    = c(150, 159, 277), 
    your_category  = c('T', 'C', 'X'), 
    your_label = c('aa', 'bb', 'cc')
    )
    

# next line is required 
   customData = merge(customData, boxesxy, by = 'box') 

# create a list of ggplot geoms and scales. 
# see e.g. http://docs.ggplot2.org/current/
  customGeoms = list(
    geom_point(data = customData, 
            aes(x = long, y = lat, shape = your_category),
            size = 10, col = 'red' ), 
    scale_shape(solid = FALSE),
   
    geom_text(data = customData, 
         hjust = 'right', nudge_x = -5,
        aes(x = long, y = lat, label = your_label) ) 
    )
