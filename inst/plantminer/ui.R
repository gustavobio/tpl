shinyUI(fluidPage(  
  h1("Plantminer"),
  sidebarLayout(
    sidebarPanel(width = 3,
                 checkboxInput("synonyms", label = "Replace synonyms", value = TRUE),
                 checkboxInput("suggest", label = "Correct misspelled names", value = TRUE),              
                 tags$form(
                   tags$textarea(id="taxa", rows=16, cols=5, "Miconia albicans\nMyrcia lingua\nCofea arabica"),
                   tags$br(),
                   tags$input(type = "Submit"),
                   tags$i("(This may take a while)"))
    ),
    mainPanel(width = 9,
              h5("Data"),
              p("This application is an alternative front end for the tpl
                package for R. All data here come from The Plant List v1.1. Please cite them accordingly. Send your suggestions and report bugs to Gustavo Carvalho at gustavo.bio@gmail.com."
              ),
              h5("Usage"),
              p("Usage is simple: paste your taxa without authors in the textbox and hit submit. Click on the id to open the species page on The Plant List. There is a download button below to export data as a quoted csv file."),
              dataTableOutput(outputId="contents"),
              downloadButton('downloadData', 'Download results in csv format')
    ))
))