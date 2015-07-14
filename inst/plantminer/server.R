ex <- tpl.get(c("Miconia albicans", "Myrcia lingua", "Cofea arabica"))
shinyServer(function(input, output) {
  output$contents <- renderDataTable({
      x <- unlist(strsplit(input$taxa, "\n"))
      res <- tpl.get(x, 
                      replace.synonyms = input$synonyms, 
                      suggest.names = input$suggest,
                      apg.families = input$apg,
                      suggestion.distance = input$distance,
                      return.synonyms = input$get.synonyms
      )
    
    output$downloadData <- downloadHandler(
      filename = ifelse(input$get.synonyms, "synonyms.csv", "results.csv"),
      content = function(file = filename) {      
        if (input$get.synonyms) {
          write.csv(data.frame(res$synonyms), file,
                    row.names = FALSE, quote = TRUE)
        } else {
          write.csv(data.frame(res), file,
                    row.names = FALSE, quote = TRUE)
        }
      }
    )
    
    links <- 
      paste("<a target=\"_blank\" href = \"http://www.theplantlist.org/tpl1.1/record/", res$id, "\">", res$id,"</a>", sep = "")
    links <- gsub("NA", NA, links)
    #out <- data.frame(id = links, res[-1])
    #names(out) <- gsub("\\.", " ", names(out))
    #out
    if (input$get.synonyms) {
      if (nrow(res$synonyms) > 0L) {
        return(res$synonyms)
      } else {
        return(data.frame(notes = "no synonyms found"))
      }
    }
    res <- data.frame(id = res[1], res[-1])
    names(res) <- gsub("\\.", " ", names(res))
    res[, c("id", "family", "name", "authorship", "source", "note", "original search")]
  }, options = list(searching = FALSE, paging = TRUE))
})