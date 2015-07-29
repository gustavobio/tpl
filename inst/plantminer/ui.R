shinyUI(fluidPage(theme = "bootstrap.css", 
  tags$title("Plantminer - The Plant List"),
  h1("Plantminer"),
  sidebarLayout(
    sidebarPanel(width = 3,
                 checkboxInput("synonyms", label = "Replace synonyms", value = TRUE),
                 checkboxInput("suggest", label = "Correct misspelled names", value = TRUE),              
                 checkboxInput("apg", label = "APG families", value = FALSE), 
                 checkboxInput("get.synonyms", label = "Get synonyms", value = FALSE),
                 sliderInput("distance", label = "Suggestion conservativeness",
                             min = 0.5, max = 1, value = 0.9),
                 tags$form(
                   tags$textarea(id="taxa", rows=12, cols=19, "Miconia albicans\nMyrcia lingua\nCofea arabica"),
                   tags$br()),
                   submitButton(text = "Submit", icon("refresh"))
    ),
    mainPanel(width = 9,
              dataTableOutput(outputId="contents"),
              downloadButton('downloadData', 'Download full results in csv format'),
              downloadButton('downloadPhylomatic', 'Download results as phylomatic taxa'),
              tags$p('All data come from The Plant List v1.1. Please cite the accordingly.',
                     tags$br(),
              'Download code to run a local version and file suggestions or bug reports at', 
              tags$a(href = "http://www.github.com/gustavobio/tpl", "github."), style = "margin-top:20px"),
              tags$p('Coded by Gustavo Carvalho <gustavo.bio@gmail.com>', style = "font-size:14px")
              
    ))
))
