#' Phylomatic format
#' 
#' Prepare taxa lists to follow the phylomatic format
#' 
#' @param taxa A data frame with columns named family, genus, and species.
#' @param uppercase logical. Should the function capitalize first letters?
#' @export
df2phylomatic <- function(taxa, uppercase = TRUE) {
  if (!all(c("family", "genus", "species") %in% colnames(taxa)) || !inherits(taxa, "data.frame")) {
    stop("taxa is not in the correct format")
  }
  apply(taxa[c("family", "genus", "species")], 1, function(x) {paste(x[!is.na(x)][c(1,2,2,3)], collapse = "/")})
}