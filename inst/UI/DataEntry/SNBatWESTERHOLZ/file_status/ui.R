

shinyUI(fluidPage(
  useToastr(),
  useShinyjs(),
  extendShinyjs(text = "shinyjs.refresh = function() { location.reload(); }"),


  fluidRow(
    column(3,actionButton("saveButton", "Save")                ),
    column(2,actionButton("refresh", "Refresh")              ),    
    column(2,dateInput("pulldate", NULL ) ),
    column(2,checkboxInput('ignore_checks', 'Ignore warnings') ),
    column(2,actionButton("helpButton", "Columns definition")  )

  ),

  fluidRow(
    rHandsontableOutput("table")
  ), 

  uiOutput("run_save"),

  bsModal("help", "Columns definition", "helpButton", size = "large", tableOutput("column_comments"))


) )


