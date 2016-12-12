

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
        )



  )),

 dashboardBody(
  useToastr(),
  tabItems(

    tabItem(tabName = "basemap_tab",
      tags$style(type = "text/css", "#basemap_show {height: calc(100vh - 1px) !important;}"),
      plotOutput('basemap_show'),

      absolutePanel(right = "0%", top="10%", width = "20%",draggable = TRUE,style = "opacity: 0.9",
      downloadButton('basemap_pdf',label = 'PDF'),
       sliderInput("font_size", "Box size:", min = 1, max = 7,step = 0.2, value = 2)

      )),


    tabItem(tabName = "breedingmap_tab",
      plotOutput('breedingmap_show')
    ),

    tabItem(tabName = "overnight_tab",
      tags$style(type = "text/css", "#overnight_show {height: calc(100vh - 1px) !important;}"),
      plotOutput('overnight_show'),

      absolutePanel(right = "0%", top="10%", width = "20%",draggable = TRUE,style = "opacity: 0.9",
        downloadButton('overnight_pdf',label = 'PDF')


      ))



))))

