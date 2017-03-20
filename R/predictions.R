


p <- function() {
 require(MASS)   

 x = idbq('SELECT b.firstEgg, n.date_LIN, b.box, b.year_ FROM 
                BTatWESTERHOLZ.BREEDING b join  
                BTatWESTERHOLZ.NESTS n 
                    on b.year_ = n.year_ and b.box = n.box WHERE
                        firstEgg is not NULL and date_LIN is not NULL')

 x[, firstEggDate := yday(firstEgg)]
 x[, firstLinDate := yday(date_LIN)]


 fm = 
 x[, rlm(firstEggDate ~ firstLinDate) %>% summary %$% r.squared  , by = year_]
 x[, rlm(firstEggDate ~ firstLinDate) %>% summary   , by = year_]












}