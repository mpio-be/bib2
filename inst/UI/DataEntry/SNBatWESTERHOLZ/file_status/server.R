
shinyServer( function(input, output,session) {

 observe( on.exit( assign('input', reactiveValuesToList(input) , envir = .GlobalEnv)) )

  N <- reactiveValues(n = 0)

  observeEvent(input$refresh, {
        shinyjs::js$refresh()
      })

  Save <- eventReactive(input$saveButton, {
    hot_to_r(input$table)
    })

  output$run_save <- renderUI({
    x = Save() %>% data.table %>% cleaner
    x <<- x 
    isolate(ignore_validators <- input$ignore_checks )

    cc = inspector(x)
    print(cc)

      if(nrow(cc) > 0 & !ignore_validators) {
          toastr_error( boostrap_table(cc),
            title = HTML('<p>Data entry errors. Check <q>Ignore warnings</q> to by-pass this filter and save the data as it is.<br> </p>') ,
            timeOut = 100000, closeButton = TRUE, position = 'top-full-width')
       }

    # db update
      if(   nrow(cc) == 0 | (nrow(cc) > 0 & ignore_validators ) ) {

        update_table_from_user_input(x)

        cat('-------')

        }

    })



    output$title <- renderText({
      paste( paste(table, db, sep = '.'),  '[Total entries updated:', N$n, ']' )

      })



  output$table  <- renderRHandsontable({

    H = get_table_for_data_entry(input$pulldate)
  
    bgCols = if (nrow(H) == 1) 1 else c(1, 7, 8)

    rhandsontable(H) %>%
    hot_cols(columnSorting = FALSE) %>%
    hot_rows(fixedRowsTop = 1) %>% 
    hot_col(bgCols, readOnly = TRUE,
    renderer = "function(instance, td, row, col, prop, value, cellProperties) {
             Handsontable.renderers.TextRenderer.apply(this, arguments);
             td.style.background = 'lightblue';}"
       )


   })

   output$column_comments <- renderTable({
      comments
  })



  })

