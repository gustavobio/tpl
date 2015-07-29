#' Suggest a valid name from a misspelled one
#' 
#' This function tries to suggest a valid name according to The Plant List using
#' a possibly incorrect one as a starting point.
#' 
#' @param taxon a character vector containing a single name
#' @param max.distance a numeric value indicating how conservative the function 
#'   should be when searching for suggestions. Values close to 1 are very 
#'   conservative
#' @param return.na a logical indicating whether to return a \code{NA} or the original 
#'   input when no suggestion is found
#' @param ignore.words \code{NULL} or a character vector with words to be ignored by the function. 
#'   Useful if you are automatizing a workflow and wants the function to ignore
#'   words or phrases such as "not found", "dead", "undetermined", and so on
#' @export
#' @return A character vector or \code{NA}
#' @examples
#' \dontrun{
#' suggest.name("Cofea arabyca")
#' suggest.name("Myrcia bela")
#' }
suggest.name <-
  function(taxon, max.distance = 0.75, return.na = TRUE, ignore.words = NULL) {
    "%in?%" <- function(x, table) match(x, table, nomatch = 0) > 0
    taxon <- fixCase(taxon)
    taxon.orig <- taxon
    uncertain <- regmatches(taxon, regexpr("[a|c]f+\\.", taxon))
    taxon <- gsub("^\\s+|\\s+$", "", taxon)
    if (length(uncertain) != 0L) taxon <- gsub("[a|c]f+\\.", "", taxon)
    #if (any(grepl(taxon, ignore.words, ignore.case = TRUE))) return(taxon)
    #if (grepl("Indet\\.", taxon)) return(taxon)
    ident <- regmatches(taxon, regexpr("\\s+sp\\.+\\w*", taxon))
    genus.only <- length(ident) != 0L | !grepl("\\s", taxon)
    if (genus.only) {
      taxon <- unlist(strsplit(taxon, " "))[1]
    if (taxon %in% names(tpldata::tpl.accepted)) return(taxon)
    }
    if (!nzchar(taxon)) return(NA)
    initials <- substr(strsplit(taxon, " ")[[1]], 1, 1)
    if (genus.only) {
      candidates <- unique(unlist(lapply(strsplit(unlist(tpldata::tpl.names[["M"]]), " "), `[`, 1)))
    } else {
      candidates <- tpldata::tpl.names[[initials[1]]][[initials[2]]]
    }
    if (!is.na(match(taxon, candidates))) return(taxon)
    l1 <- length(taxon)
    l2 <- length(candidates)
    out <- adist(taxon, candidates)
    distance <- 1 - (out/pmax(nchar(taxon), 
                                  nchar(candidates)))
    max.dist <- max(distance, na.rm = TRUE)
    if (max.dist >= max.distance) {
      if (genus.only) {
        res <- candidates[distance == max(distance, na.rm = TRUE)][1]
        if (length(uncertain) == 0L) {
          return(res)
        } else {
          res <- unlist(strsplit(res, " "))
          return(paste(res[1], uncertain, res[2:length(res)]))
        }
      } else {
        paste(candidates[distance == max(distance, na.rm = TRUE)][1], ident, sep = "")
      }
    } else {
      if (return.na) {
        NA
      } else {
        taxon.orig
      }
    }
  }
