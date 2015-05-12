ex <- tpl.get(c("Miconia albicans", "Myrcia lingua", "Cofea arabica"))
shinyServer(function(input, output) {
  output$contents <- renderDataTable({
    if (input$taxa == "Miconia albicans\nMyrcia lingua\nCofea arabica" & input$synonyms & input$suggest) {
      res <- ex
    } else {
      x <- unlist(strsplit(input$taxa, "\n"))
      res <- tpl.get(x, 
                      replace.synonyms = input$synonyms, 
                      suggest.names = input$suggest,
                      apg.families = input$apg,
                      suggestion.distance = input$distance,
                      )
    }
    output$downloadData <- downloadHandler(
      filename = "results.csv",
      content = function(file = filename) {      
        # Write to a file specified by the 'file' argument
        write.csv(data.frame(ids, res[-1]), file,
                  row.names = FALSE, quote = TRUE)
      }
    )
    
    links <- 
      paste("<a target=\"_blank\" href = \"http://www.theplantlist.org/tpl1.1/record/", res$id, "\">", res$id,"</a>", sep = "")
    links <- gsub("NA", NA, links)
    #out <- data.frame(id = links, res[-1])
    #names(out) <- gsub("\\.", " ", names(out))
    #out
   #ids <- res[1]
   res <- data.frame(id = res[1], res[-1])
   names(res) <- gsub("\\.", " ", names(res))
   #res[c(1, 3, 22, 10, 11, 12, 13, 14, 23, 24)]
   res
  }, options = list(bFilter = TRUE))
})