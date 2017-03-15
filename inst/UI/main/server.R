
shinyServer(function(input, output, session) {

  observe( on.exit( assign('input', reactiveValuesToList(input) , envir = .GlobalEnv)) )

 # base-map
    output$basemap_show <- renderPlot({
      print( map_base(size = input$font_size1) )
      })

    output$basemap_pdf <- downloadHandler(
      filename = 'basemap.pdf',
      content = function(file) {
          x = map_base(size = input$font_size1) + print_ann()
          pdf(file = file, width = 8.5, height = 11)
          print(x)
          dev.off()
      })

 # NESTS map
    output$nestsmap_show <- renderPlot({
      if(length(input$date) > 0 ) { # to avoid the split moment when the date  is changed
        nd = nests(input$date) 
        if(nrow(nd) ==0)  stop( toastr_warning( paste('There are no data on', input$date ) ) )
        m = map_nests(nest_state(nd)  , size = input$font_size2, title = paste('Reference:', input$date) )  
        print(m)
        }
      })


    output$nestsmap_pdf <- downloadHandler(
      filename = 'nestsmap.pdf',
      content = function(file) {
          
          nd = nests(input$date) 
          if(nrow(nd) ==0) stop( toastr_warning( paste('There are no data on', input$date ) ) )
          m = map_nests(nest_state(nd)  , size = input$font_size2, title = paste('Reference:', input$date) ) + print_ann()
          
          pdf(file = file, width = 8.5, height = 11)
          print(m)
          dev.off()
      })

 # overnight map

    overnight_data <- reactive({

      toastr_info('Please wait a few seconds for the map to appear.', progressBar = TRUE, timeOut = 9000)

      x = SNB::overnight(buffer = 2, date = as.Date(input$date)  )

      if(nrow(x) == 0)
      stop( toastr_error('No data for the chosen date', progressBar = TRUE, timeOut = 9000) )
      
      x[, sleeping_bird := ifelse( ! is.na(transp), 'transponded', 'unknown')]
      merge(boxesxy, x, by = 'box', all.x = TRUE)
      })


    output$overnight_show <- renderPlot({
        x = overnight_data()
        map_base() + print_ann() + 
            geom_point(dat = x, aes(x = long, y = lat, color = sleeping_bird) )+ 
            ggtitle(input$date)
      })

    output$overnight_pdf <- downloadHandler(
      filename = 'sleep.pdf',
      content = function(file) {
        x = overnight_data()
        g = 
        map_base() + print_ann() + 
            geom_point(dat = x, aes(x = long, y = lat, color = sleeping_bird) )+ 
            ggtitle(input$date)

        tf <<- tempfile(fileext = 'sleep.pdf')
        pdf(file = tf, width = 8.5, height = 11)
        print(g)
        dev.off()

        file.copy(tf, file)
      })

 # SNB diagnostics
    observeEvent(input$diagnose_pull_compile, {

      toastr_warning('This will take a couple of minutes. Wait untill the Download xlsx button is active.')

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


