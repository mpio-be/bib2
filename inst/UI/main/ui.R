

shinyUI(

dashboardPage(skin = 'green',
  dashboardHeader(title = paste('Westerholz',year(Sys.Date()),  '...🐤') ),

  dashboardSidebar(
    sidebarMenu(id = 'menubar',

       a('• DATA ENTRY', style="color:#e9390f;  font-family: 'Lucida Console', Monaco, monospace;") ,

      menuItem('ADULTS'  ,icon = icon("pencil", lib = "glyphicon"),
          href = '/bib2/DataEntry/BTatWESTERHOLZ/ADULTS', newtab = TRUE),
      
      menuItem('NESTS',icon = icon("pencil", lib = "glyphicon"),
          href = '/bib2/DataEntry/BTatWESTERHOLZ/NESTS', newtab = TRUE),
        
      menuItem('DATA EDITOR',icon = icon("edit", lib = "glyphicon"),
          href = 'http://behavioural-ecology.orn.mpg.de/db_ui/Westerholz.php?db=FIELD_BTatWESTERHOLZ', 
          newtab = TRUE),

      menuItem('SHARED NOTES',icon = icon("duplicate", lib = "glyphicon"),
          href = 'https://owncloud.gwdg.de/index.php/s/nWIb4V57wtsFg4I', 
          newtab = TRUE),




      hr(), 

      menuItem("Main board",  tabName  = "board_tab",     icon = icon("dashboard") ),

      dateInput("date", "Date:", value = Sys.Date(), min = '2007-01-01', max =  Sys.Date() + 6 ),

       a('• MAPPING', style="color:#fd9d06;  font-family: 'Lucida Console', Monaco, monospace;"),


      menuItem("Base map",          tabName  = "basemap_tab",   icon = icon("map-o") ),
      menuItem("Nests map",         tabName  = "nestsmap_tab",  icon = icon("map") ),
      
  
      conditionalPanel(
        condition = "input.menubar == 'basemap_tab' | input.menubar == 'nestsmap_tab' | input.menubar == 'overnight_tab' | input.menubar == 'custom_tab'",
        sliderInput("font_size", "Text and symbol size:", min = 1, max = 7,step = 0.2, value = 4)
        ), 


      a('• DATA VIEWERS', style="color:#80dc95;  font-family: 'Lucida Console', Monaco, monospace;"),

      menuItem("Nests data viewer", tabName  = "nestsdata_tab", icon = icon("binoculars") ),
      menuItem("Adult data viewer", tabName  = "adultdata_tab", icon = icon("binoculars") ),

      menuItem('FILES',icon = icon("paperclip", lib = "glyphicon"),
          href = 'http://behavioural-ecology.orn.mpg.de/files/', 
          newtab = TRUE),










      conditionalPanel(
        condition = "input.menubar == 'nestsdata_tab'", 
      numericInput("nestbox", "Nestbox:",value = 1, min = 1, max = 277)
      ), 


       # footer
       p(
        paste(
        "<a href='https://github.com/mpio-be/bib2' target='_blank'>bib2 v.", packageVersion('bib2'), "</a>") %>% HTML, 
       
          style="position:fixed;
                font-style: oblique;
                bottom:0;
                right:0;
                left:0;
                padding:1px;
                box-sizing:border-box;")


  )),

 dashboardBody(
  useToastr(),
  useShinyjs(),

  tabItems(
    tabItem(tabName = "board_tab",
        box(title = 'Laying date estimation', plotOutput('predict_first_egg') ) ,
        box(title = 'Phenology', plotOutput('phenology') ) 

        ),

    tabItem(tabName = "basemap_tab",
      shiny::tags$style(type = "text/css", "#basemap_show {height: calc(93vh - 1px) !important;}"),
      plotOutput('basemap_show'),
      absDownloadButton('basemap_pdf')
      ),

    tabItem(tabName = "nestsmap_tab",
      shiny::tags$style(type = "text/css", "#nestsmap_show {height: calc(93vh - 1px) !important;}"),
      
      fluidRow( 
        Box(width = 10, plotOutput('nestsmap_show')  ),
        Box(width = 2,
        
        checkboxInput('experiment', 'Show experiments', value =  TRUE), 
        tippy_this('experiment', 'see EXPERIMENTS table'),

        conditionalPanel(condition = "input.experiment==true",  
          selectInput("experiment_id", "Experiment ID:",1:5, multiple = FALSE) ),



        selectInput("nest_stages", "Nest stages:" , getOption('nest.stages'), getOption('nest.stages'), multiple = TRUE ),
        selectInput("stage_age_type", "Stages selection" , c('Equal with', "Greater or equal than"), selected = "Greater or equal than"),
        
        conditionalPanel(condition = "input.stage_age_type=='Equal with'",  
          selectInput("stage_age_equal", "Stage age = ",1:60, multiple = TRUE) ), 
        conditionalPanel(condition = "input.stage_age_type=='Greater or equal than'",
          numericInput("stage_age_greater", "Stage age ⋝", 0 , min = 0) ), 

        numericInput("days_to_hatch", "Days to hatch ⋝", 0 , min = 0, max = 0, value = 30),

        textAreaInput('notes', 'Notes', value = "", width = '100%', height = '300px'), 
        tippy_this('notes', 'Any notes you write here will be seen on right side of the map.'),


        downloadButton('nestsmap_pdf',label = 'Download PDF')
        )   
      )), 
        
    tabItem(tabName = "nestsdata_tab",
      DT::dataTableOutput('nestsdata_show')
      ),    

    tabItem(tabName = "adultdata_tab",
      DT::dataTableOutput('adultdata_show')
      )



))))

