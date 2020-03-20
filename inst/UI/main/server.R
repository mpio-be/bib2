
shinyServer(function(input, output, session) {

  observe( on.exit( assign('input', reactiveValuesToList(input) , envir = .GlobalEnv)) )
  overnightdata <<- data.table(long = integer(0), lat = integer(0), sleeping_bird = character(0))

  autoInv_1h <- reactiveTimer(1000*60*60) #

 # main board
    output$predict_first_egg <- renderPlot({
      autoInv_1h()
      if(length(input$date) > 0 ) {

        firstLining = nests(input$date)[nest_stage == "LIN", min(date_time)] 
        predFirstEggData = predict_firstEgg_data(F, input$date )
        predFirstEgg = predict_firstEgg(predFirstEggData, yday(firstLining), year(input$date) )[, firstLining := as.POSIXct(firstLining) ]
        predFirstEgg = predFirstEgg[!is.na(fit)]
        
        reldays = predFirstEgg[, difftime(fit, input$date, units = 'days')%>% as.integer ]
        if ( length(reldays) > 0) {
         lword = if(reldays < 0) 'since' else 'to'
         Title = paste( abs(reldays) , 'days', lword , 'the estimated first egg.')
         Subtitle = paste('(anytime between', 
                    format(predFirstEgg$lwr, "%d-%b"), '&', 
                    format(predFirstEgg$upr, "%d-%b"), ') '
                    )


         } else { 
          Title = "Waiting for the first lining ... "
          Subtitle = ''
          }

        ggplot(predFirstEggData, aes(y = first_Egg , x = first_Lining ) ) + 
           geom_point() + 
           geom_smooth(method = 'lm') + 
           ggrepel::geom_text_repel(aes(label = year_), vjust= 'bottom') + 
           geom_pointrange(data = predFirstEgg, aes(x = firstLining, y = fit, ymin = lwr, ymax = upr ), col = 2 ) + 
           scale_x_datetime(date_labels = "%d-%b") +
           ggtitle(Title, Subtitle)


        }   

    })
    
    output$phenology <- renderPlot({
     
      plot_phenology_firstDates ()

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
 
        if( input$stage_age_type == 'Equal with' ) {

          N = nest_state(nd, input$nest_stages, hatchingModel)
          N = N[nest_stage_age %in% (input$stage_age_equal %>% as.numeric) ]
          N = N[days_to_hatch < input$days_to_hatch | is.na(days_to_hatch)]
          }


        if( input$stage_age_type == 'Greater or equal than' ) {
          N = nest_state(nd, input$nest_stages, hatchingModel)
          N = N[nest_stage_age >= input$stage_age_greater]
          N = N[days_to_hatch < input$days_to_hatch | is.na(days_to_hatch)]
          }


        m <<- map_nests(N , size = input$font_size, title = paste('Reference:', input$date), 
                  notes = input$notes, ny = 720 )  
        
        if(input$experiment) {

          gg = map_experiment(input$experiment_id)
          o = try(m + gg(), silent = TRUE)

          if( inherits(o, 'try-error')) o = m + ggtitle( paste('Experiment', id, 'cannot be shown. Review the EXPERIMENTS table!'))

          m <<- o
        }

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
    output$nestsdata_show <- DT::renderDataTable({
        o = nests(input$date)[box == input$nestbox]
        setorder(o, date_time)
        o[,which(unlist(lapply(o, function(x)!all(is.na(x))))),with=FALSE]
        }, options = list(scrollX = TRUE) )

 # all ADULT data
    output$adultdata_show <- DT::renderDataTable({
        a = allAdults()
        a[, Year := year(datetime_)]
        }, options = list(scrollX = TRUE) )


})


