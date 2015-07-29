#' Phylomatic format
#' 
#' 
#' 
#' @param taxa A data frame with columns named family, genus, and species.
#' @param uppercase logical. Should the function capitalize first letters?
#' @export
df2phylomatic <- function(taxa, uppercase = TRUE) {
  if (!all(c("family", "genus", "species") %in% colnames(taxa)) || !inherits(taxa, "data.frame")) {
    stop("taxa is not in the correct format. It should be a data frame with columns named family, genus, and species.")
  }
  res <- vector()
  for (i in seq_len(nrow(taxa))) {
    family <- taxa[i, "family"]
    genus <- taxa[i, "genus"]
    species <- taxa[i, "species"]
    if (!is.na(species)) species <- paste(genus, species, sep = "_")
    taxon <- na.omit(c(family, genus, species))
    if (length(taxon) == 0L) next
    res[length(res) + 1] <- paste(taxon, collapse = "/")
  }
#   taxa <- within(taxa, {species[is.na(species)] <- ""; species <- paste(genus, species, sep = "_")})
#   res <- apply(taxa[c("family", "genus", "species")], 1, function(x) {paste(x[!is.na(x)][c(1,2,3)], collapse = "/")})
#   res <- gsub("_NA", "", res)
  if (uppercase) {
    res
  } else {
    tolower(res)
  }
}