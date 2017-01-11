



shinyServer(function(input, output, session) {

 # basemap
    output$basemap_pdf <- downloadHandler(
      filename = 'basemap.pdf',
      content = function(file) {
          x = map_geom_label(x = 'long', y = 'lat', label = 'box3d', size = 2)
          pdf(file = file, width = 8.5, height = 11)
          print(x)
          dev.off()
      })

    output$basemap_show <- renderPlot({
      print( map_geom_label(x = 'long', y = 'lat', label = 'box3d', size = input$font_size) )
      })

 # breeding map
    output$breedingmap_show <- renderPlot({
      plot(1, main = 'Under construction', xlab = '', ylab = '', col = NA, axes = FALSE)
      })

 # overnight map

    overnight_data <- reactive({

      toastr_info('Please wait a few seconds for the map to appear.\nIf you get an Empty Dataset error choose another date',
        position = 'top-center', progressBar = TRUE, timeOut = 9000)

      x = SNB::overnight(getOption('DB_user'), host, buffer = 2, date = as.Date(input$date)  )
      x[, sleeping_bird := ifelse( ! is.na(transp), 'transponded', 'unknown')]
      merge(boxesxy, x, by = 'box', all.x = TRUE)
      })


    output$overnight_show <- renderPlot({
      x = overnight_data()
      map_geom_label(dat = x, x = 'long', y = 'lat', label = 'box3d', color = 'sleeping_bird', size = 5) +
      ggtitle(input$date)
      })

    output$overnight_pdf <- downloadHandler(
      filename = 'sleep.pdf',
      content = function(file) {
        x = overnight_data()
        g = map_geom_label(dat = x, x = 'long', y = 'lat', label = 'box3d', color = 'sleeping_bird', size = 3) +
            ggtitle(input$date)

        tf <<- tempfile(fileext = 'sleep.pdf')
        pdf(file = tf, width = 8.5, height = 11)
        print(g)
        dev.off()

        file.copy(tf, file)


      })


      observeEvent(input$diagnose_pull_compile, {

        toastr_warning('This will take a couple of minutes. Wait untill the Download xlsx button is active.')

        x = diagnose_pull(date=  format(input$date , "%Y.%m.%d") , shiny = TRUE)
        diag_xls <<- tempfile(fileext = '.xlsx')

        openxlsx::write.xlsx(x, file = diag_xls, overwrite = TRUE)

        shinyjs::enable("diagnose_pull_download")

        })

    output$diagnose_pull_download <- downloadHandler(
     filename = 'snb_diagnose.xlsx',
     content = function(file) {
       file.copy(diag_xls, file)


     })

    shinyjs::disable("diagnose_pull_download") # disabled on page load



})


