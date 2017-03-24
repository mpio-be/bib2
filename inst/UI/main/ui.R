

shinyUI(

dashboardPage(skin = 'green',
  dashboardHeader(title = 'Westerholz'),

  dashboardSidebar(
    sidebarMenu(id = 'menubar',
      dateInput("date", "Date:", value = Sys.Date(), min = '2007-01-01', max =  Sys.Date() + 6 ),

      menuItem("Main board",      tabName  = "board_tab",     icon = icon("dashboard") ),
      menuItem("Base map",        tabName  = "basemap_tab",   icon = icon("map-o") ),
      menuItem("Breeding map",    tabName  = "nestsmap_tab",  icon = icon("map") ),
      menuItem("Overnight map",   tabName  = "overnight_tab", icon = icon("map") ),
      menuItem("Custom map",      tabName  = "custom_tab",    icon = icon("wrench") ),

      menuItem("Data entry",  icon = icon("table"),
        menuSubItem('ADULTS', href = '/DataEntry/DB/BTatWESTERHOLZ/ADULTS', newtab = TRUE),
        menuSubItem('NESTS',  href = '/DataEntry/DB/BTatWESTERHOLZ/NESTS', newtab = TRUE),
        menuSubItem('SNB ',   href = '/DataEntry/DB/SNBatWESTERHOLZ/file_status', newtab = TRUE)
        ),

      menuItem("SNB",  icon = icon("tablet"), tabName  = 'SNB_tab' ),

      conditionalPanel(
        condition = "input.menubar == 'basemap_tab' | input.menubar == 'nestsmap_tab' | input.menubar == 'overnight_tab'",
        sliderInput("font_size", "Text and symbol size:", min = 1, max = 7,step = 0.2, value = 4)
        )
  )),

 dashboardBody(
  useToastr(),
  useShinyjs(),

  tabItems(
    tabItem(tabName = "board_tab",
        box(title = 'Laying date estimation', 
          plotOutput('predict_first_egg') 
          )

      ),

    tabItem(tabName = "custom_tab",
      shiny::tags$style(type = "text/css", "#custom_script {height: calc(81vh - 1px) !important;}"),
      shiny::tags$style(type = "text/css", "#custom_show {height: calc(85vh - 1px) !important;}"),
      fluidRow( 
        shinydashboard::box(width = 4, 
          actionButton("update_custom_map", "Update map"), 

          aceEditor("custom_script",theme = 'merbivore' , mode = "r", wordWrap = TRUE, 
            value = paste(readLines(system.file('custom_script.R', package = 'bib2') , warn = FALSE), collapse = '\n') )

           ) , 

        shinydashboard::box(width = 8,
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
      plotOutput('nestsmap_show'),
      absDownloadButton('nestsmap_pdf')
      ),

    tabItem(tabName = "overnight_tab",
      shiny::tags$style(type = "text/css", "#overnight_show {height: calc(93vh - 1px) !important;}"),
      plotOutput('overnight_show'),

      absolutePanel(right = "0%", top="10%", width = "20%",draggable = TRUE,style = "opacity: 0.9",
        actionButton("goOvernight", "Compile dataset"),
        downloadButton('overnight_pdf',label = 'Download PDF')
      )),


    tabItem(tabName = "SNB_tab",
      shinydashboard::box(title = "SNB txt files diagnostics", solidHeader = TRUE,
        actionButton("diagnose_pull_compile", "Compile diagnostic"),
        downloadButton('diagnose_pull_download',label =  'Download xlsx')
        ),

      shinydashboard::box(title = "Pull dates", solidHeader = TRUE,
        shinyTree('snbPullDates')
        )
     )

))))

