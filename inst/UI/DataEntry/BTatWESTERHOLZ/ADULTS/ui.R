
  dashboardPage(skin = 'yellow', 
  dashboardHeader(title = dbtable),

  dashboardSidebar(width = 100, 
    'Total entries:', br(), 
    textOutput('title')
    )  ,

  dashboardBody(

  includeCSS(system.file('UI', 'www', 'floatingButton.css', package = 'DataEntry'))   ,

  useToastr(),
  useShinyjs(),
  extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),
  js_insertMySQLTimeStamp(),


  rHandsontableOutput("table", height = '100%', width = '100%'),



  # Menu
   HTML('
    <div id="container-floating">
      
      <!-- Save  -->
      <div id="saveButton" class="nd4 nds btn btn-danger action-button" data-toggle="tooltip">
      <h6> Save </h6>
      <div id="run_save" class="shiny-html-output"></div>
      </div>
      
       <!-- Ignore validators  -->  
      

      <div class="nd3 nds material-switch pull-right" data-toggle="tooltip" >
        <h6> No validation! </h6>
        <input id="ignore_checks"  type="checkbox"/>
        <label for="ignore_checks" class="label-danger"> </label>
       </div>


      <!-- Refresh  -->
      <div id="refresh" class="nd2 nds btn btn-primary action-button" data-toggle="tooltip" >

      <h6> Refresh </h6>
      </div>


      <!-- Columns definition  -->
      <div id = "helpButton" class="nd1 nds btn btn-primary action-button" data-toggle="tooltip">
        <h6> Help </h6>
      </div>

      <!-- Start  -->
      <div id="floating-button" data-toggle="tooltip">
        <p class="plus">+</p>
        
      </div>

    </div>


    ')

   , 


   bsModal("help", dbtable , "helpButton", size = "large", tableOutput("column_comments"))



 )
)



