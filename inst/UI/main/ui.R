

shinyUI(

dashboardPage(skin = 'purple',
  dashboardHeader(title = paste('Westerholz',year(Sys.Date()),  '🐣') ),

  dashboardSidebar(
    sidebarMenu(id = 'menubar',
      dateInput("date", "Date:", value = Sys.Date(), min = '2007-01-01', max =  Sys.Date() + 6 ),

      menuItem("Main board",        tabName  = "board_tab",     icon = icon("dashboard") ),
      menuItem("Base map",          tabName  = "basemap_tab",   icon = icon("map-o") ),
      menuItem("Nests map",         tabName  = "nestsmap_tab",  icon = icon("map") ),
      menuItem("Nests data viewer", tabName  = "nestsdata_tab", icon = icon("binoculars") ),
      menuItem("Adult data viewer", tabName  = "adultdata_tab", icon = icon("binoculars") ),
      menuItem("Overnight map",     tabName  = "overnight_tab", icon = icon("map") ),
      menuItem("Custom map",        tabName  = "custom_tab",    icon = icon("wrench") ),

      menuItem("Data entry",  icon = icon("table"),
        menuSubItem('ADULTS', href = '/bib2/DataEntry/BTatWESTERHOLZ/ADULTS', newtab = TRUE),
        menuSubItem('NESTS',  href = '/bib2/DataEntry/BTatWESTERHOLZ/NESTS', newtab = TRUE)
        ),

      menuItem("SNB",  icon = icon("tablet"), tabName  = 'SNB_tab' ),

      conditionalPanel(
        condition = "input.menubar == 'basemap_tab' | input.menubar == 'nestsmap_tab' | input.menubar == 'overnight_tab' | input.menubar == 'custom_tab'",
        sliderInput("font_size", "Text and symbol size:", min = 1, max = 7,step = 0.2, value = 4)
        ), 
      conditionalPanel(
        condition = "input.menubar == 'nestsdata_tab'", 
      numericInput("nestbox", "Nestbox:",value = 1, min = 1, max = 277)
      )

  )),

 dashboardBody(
  useToastr(),
  useShinyjs(),

  tabItems(
    tabItem(tabName = "board_tab",
        box(title = 'Laying date estimation', plotOutput('predict_first_egg') ) ,
        box(title = 'Phenology', plotOutput('phenology') ) 

        ),

    tabItem(tabName = "custom_tab",
      shiny::tags$style(type = "text/css", "#custom_script {height: calc(81vh - 1px) !important;}"),
      shiny::tags$style(type = "text/css", "#custom_show {height: calc(85vh - 1px) !important;}"),
      fluidRow( 
        Box(width = 4, 
          actionButton("update_custom_map", "Update map"), 

          aceEditor("custom_script",theme = 'merbivore' , mode = "r", wordWrap = TRUE, 
            value = paste(readLines(system.file('custom_script.R', package = 'bib2') , warn = FALSE), collapse = '\n') )

           ) , 

        Box(width = 8,
          absDownloadButton('custom_pdf'),
          plotOutput('custom_show') )
      )),

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

        selectInput("nest_stages", "Nest stages:" , getOption('nest.stages'), getOption('nest.stages'), multiple = TRUE ),
        selectInput("stage_age_type", "Stages selection" , c('Equal with', "Greater or equal than"), selected = "Greater or equal than"),
        
        conditionalPanel(condition = "input.stage_age_type=='Equal with'",  
          selectInput("stage_age_equal", "Stage age = ",1:60, multiple = TRUE) ), 
        conditionalPanel(condition = "input.stage_age_type=='Greater or equal than'",
          numericInput("stage_age_greater", "Stage age ⋝", 0 , min = 0) ), 

        numericInput("days_to_hatch", "Days to hatch ⋝", 0 , min = 0, max = 0, value = 30),

        textAreaInput('notes', 'Notes', value = "", width = '100%', height = '300px'), 


        downloadButton('nestsmap_pdf',label = 'Download PDF')
        )   
      )), 
        
    tabItem(tabName = "nestsdata_tab",
      dataTableOutput('nestsdata_show')
      ),    

    tabItem(tabName = "adultdata_tab",
      dataTableOutput('adultdata_show')
      ),

    tabItem(tabName = "overnight_tab",
      shiny::tags$style(type = "text/css", "#overnight_show {height: calc(93vh - 1px) !important;}"),
      plotOutput('overnight_show'),

      absolutePanel(right = "0%", top="10%", width = "20%",draggable = TRUE,style = "opacity: 0.9",
        actionButton("goOvernight", "Compile dataset"),
        downloadButton('overnight_pdf',label = 'Download PDF')
      )),

    tabItem(tabName = "SNB_tab",
      Box(title = "SNB txt files diagnostics", solidHeader = TRUE,
        actionButton("diagnose_pull_compile", "Compile diagnostic"),
        downloadButton('diagnose_pull_download',label =  'Download xlsx')
        ),

      Box(title = "Pull dates", solidHeader = TRUE,
        shinyTree('snbPullDates')
        )
     )

))))

