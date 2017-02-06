

shinyUI(

dashboardPage(skin = 'green',
  dashboardHeader(title = 'Westerholz'),

  dashboardSidebar(
    sidebarMenu(
      dateInput("date", "Date:", value = Sys.Date() ),



      menuItem("Base map",    tabName  = "basemap_tab",  icon = icon("map-o") ),
      menuItem("Breeding map",   tabName  = "breedingmap_tab", icon = icon("map") ),
      menuItem("Overnight map",   tabName  = "overnight_tab", icon = icon("map") ),

      menuItem("Data entry",  icon = icon("table"),
        menuSubItem('ADULTS', href = '/DataEntry/DB/BTatWESTERHOLZ/ADULTS', newtab = TRUE),
        menuSubItem('NESTS',  href = '/DataEntry/DB/SNBatWESTERHOLZ/NESTS', newtab = TRUE),
        menuSubItem('SNB ',   href = '/DataEntry/DB/SNBatWESTERHOLZ/file_status', newtab = TRUE)
        ),

      menuItem("SNB",  icon = icon("tablet"), tabName  = 'SNB_tab' )
  )),

 dashboardBody(
  useToastr(),
  useShinyjs(),

  tabItems(

    tabItem(tabName = "basemap_tab",
      shiny::tags$style(type = "text/css", "#basemap_show {height: calc(100vh - 1px) !important;}"),
      plotOutput('basemap_show'),

      absolutePanel(right = "0%", top="10%", width = "20%",draggable = TRUE,style = "opacity: 0.9",
      downloadButton('basemap_pdf',label = 'PDF'),
       sliderInput("font_size", "Text and symbol size:", min = 1, max = 7,step = 0.2, value = 4)
      )),


    tabItem(tabName = "breedingmap_tab",
      plotOutput('breedingmap_show')
    ),

    tabItem(tabName = "overnight_tab",
      shiny::tags$style(type = "text/css", "#overnight_show {height: calc(100vh - 1px) !important;}"),
      plotOutput('overnight_show'),

      absolutePanel(right = "0%", top="10%", width = "20%",draggable = TRUE,style = "opacity: 0.9",
        downloadButton('overnight_pdf',label = 'PDF')
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


      )


    )


)



 )

