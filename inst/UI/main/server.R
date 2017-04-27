
shinyServer(function(input, output, session) {

  observe( on.exit( assign('input', reactiveValuesToList(input) , envir = .GlobalEnv)) )
  overnightdata <<- data.table(long = integer(0), lat = integer(0), sleeping_bird = character(0))

 # main board
    output$predict_first_egg <- renderPlot({
      if(length(input$date) > 0 ) {

        firstLining = nests(input$date)[nest_stage == "LIN", min(date_time)] 
        predFirstEggData = predict_firstEgg_data(F, input$date )
        predFirstEgg = predict_firstEgg(predFirstEggData, yday(firstLining), year(input$date) )[, firstLining := firstLining]
        predFirstEgg = predFirstEgg[!is.na(fit)]
        
        reldays = predFirstEgg[, difftime(fit, input$date, units = 'days')%>% as.integer ]
        if ( length(reldays) > 0) {
         lword = if(reldays < 0) 'since' else 'to'
         Title = paste( abs(reldays) , 'days', lword , 'the estimated first egg.')
         } else Title = NULL

        ggplot(predFirstEggData, aes(y = first_Egg , x = first_Lining, x) ) + 
           geom_point() + 
           geom_smooth(method = 'lm') + geom_text(aes(label = year_), vjust= 'bottom') + 
           geom_pointrange(data = predFirstEgg, aes(x = firstLining, y = fit, ymin = lwr, ymax = upr ), col = 2) + 
           ggtitle(Title)
        }   

    })

 # custom map
    output$custom_show <- renderPlot({
      input$update_custom_map
      rm(css) 
      css = isolate(eval(parse(text=input$custom_script)))
      nd = nests(input$date) 

      map_nests(nest_state(nd, input$nest_stages)  , size = input$font_size, title = paste('Reference:', input$date) )   + customGeoms

      })

    output$custom_pdf <- downloadHandler(
      filename = 'custom.pdf',
      content = function(file) {
          input$update_custom_map
          rm(css) 
          css = isolate(eval(parse(text=input$custom_script)))
          nd = nests(input$date) 


          x = map_nests(nest_state(nd, input$nest_stages)  , size = input$font_size, title = paste('Reference:', input$date) )   + customGeoms

          pdf(file = file, width = 8.5, height = 11)
          print(x)
          dev.off()
      }) 

 # base-map
    output$basemap_show <- renderPlot({
      print( map_base(size = input$font_size) )
      })

    output$basemap_pdf <- downloadHandler(
      filename = 'basemap.pdf',
      content = function(file) {
          x = map_base(size = input$font_size, printdt = TRUE) 
          pdf(file = file, width = 8.5, height = 11)
          print(x)
          dev.off()
      })

 # NESTS map
    output$nestsmap_show <- renderPlot({
      if(length(input$date) > 0 ) { # to avoid the split moment when the date  is changed
        nd = nests(input$date)  
        if(nrow(nd) ==0)  stop( toastr_warning( paste('There are no data on', input$date ) ) )
 
        if( input$stage_age_type == 'Equal with' )
          N = nest_state(nd, input$nest_stages)[nest_stage_age %in% (input$stage_age_equal %>% as.numeric)]
        if( input$stage_age_type == 'Greater or equal than' )
          N = nest_state(nd, input$nest_stages)[nest_stage_age >= input$stage_age_greater]

        m <<- map_nests(N , size = input$font_size, title = paste('Reference:', input$date) )  
        m
        }
      
      })

    output$nestsmap_pdf <- downloadHandler(
      filename = 'nestsmap.pdf',
      content = function(file) {
          
          cairo_pdf(file = file, width = 8.5, height = 11)
          print(m + print_ann() )
          dev.off()
      })

 # NESTS data
    output$nestsdata_show <- renderDataTable({
        o = nests(input$date)
        setorder(o, date_time)
        o[,which(unlist(lapply(o, function(x)!all(is.na(x))))),with=FALSE]
        }, options = list(scrollX = TRUE) )

 # all ADULT data
    output$adultdata_show <- renderDataTable({
        a = allAdults()
        a[, Year := year(datetime_)]
        }, options = list(scrollX = TRUE) )



 # overnight map [ observeEvent: makes the dataset to .GlobalEnv when button is pressed; reactivePoll checks if the set was changed ]
    # compile the overnight set
    observeEvent(input$goOvernight, {
      toastr_info('Wait a bit the dataset is compiling ...', progressBar = TRUE)

      x = try(SNB::overnight(buffer = 2, date = as.Date(input$date)  ), silent = TRUE)
      # x =   data.table(box = sample(1:277, 1) , transp = 'xxx' )

      if(!inherits(x, 'try-error') && nrow(x) > 0 ) {
        x[, sleeping_bird := ifelse( ! is.na(transp), 'transponded', 'unknown')]
        overnightdata <<- merge(boxesxy, x, by = 'box', all.x = TRUE)
        } else toastr_warning('No data for the chosen date')

    })

    # watch the overnight set for changes
    overnightdataGet <- reactivePoll(1500, NULL, function() 
                    checkFunc = digest(get('overnightdata', '.GlobalEnv')) , 
                    valueFunc = function() get('overnightdata', '.GlobalEnv') )


    output$overnight_show <- renderPlot({
    map_base(size = input$font_size) +
          geom_point(dat = overnightdataGet() , size = input$font_size,
                    aes(x = long, y = lat, color = sleeping_bird) )+ 
          ggtitle(input$date)
    })

    output$overnight_pdf <- downloadHandler(
    filename = 'sleep.pdf',
    content = function(file) {
      g = 
      map_base(size = input$font_size, printdt = TRUE) + 
          geom_point(dat = overnightdataGet(), size =input$font_size,
                     aes(x = long, y = lat, color = sleeping_bird) )+ 
          ggtitle(input$date)

      tf <<- tempfile(fileext = 'sleep.pdf')
      pdf(file = tf, width = 8.5, height = 11)
      print(g)
      dev.off()

      file.copy(tf, file)
    })

 # SNB diagnostics
    observeEvent(input$diagnose_pull_compile, {

    toastr_warning('This will take a couple of minutes. Wait until the Download xlsx button is active.')

    x1 = diagnose_pull(date=  format(input$date , "%Y.%m.%d") , shiny = TRUE)
    x2 = diagnose_pull_v2(date=  format(input$date , "%Y.%m.%d") , shiny = TRUE)

    diag_xls <<- tempfile(fileext = '.xlsx')

    require(openxlsx)
    wb = createWorkbook()
    addWorksheet(wb, "v1")
    addWorksheet(wb, "v2")
    writeDataTable(wb, "v1", x = x1, rowNames= FALSE, withFilter = TRUE, tableStyle="TableStyleLight9")
    writeDataTable(wb, "v2", x = x2, rowNames= FALSE, withFilter = TRUE, tableStyle="TableStyleLight9")

    saveWorkbook(wb,diag_xls, overwrite = TRUE)


    shinyjs::enable("diagnose_pull_download")

    })

    output$diagnose_pull_download <- downloadHandler(
    filename = 'snb_diagnose.xlsx',
    content = function(file) {
     file.copy(diag_xls, file)


    })

    shinyjs::disable("diagnose_pull_download") # disabled on page load


    output$snbPullDates <- renderTree({
    x = data_dirs(p =  getOption('path.to.raw') )
    x = split(x$dir, x$year)
    lapply(x, function(i) eval(parse(text = paste('list(', paste(shQuote(i), "=''", collapse = ','), ')' ) )) )

    })

})


