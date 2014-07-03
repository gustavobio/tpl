#' Get plant taxonomical and distribution data
#' 
#' This function collects taxonomic information from The Plant List. Synonyms and
#' misspelled names are resolved automatically.
#' 
#' @param taxa a character vector containing one or more taxa, without authors 
#'   see \code{\link{noauthors}} if you have a list with authorities
#' @param replace.synonyms should the function automatically replace synonyms?
#' @param suggest.names should the function try to suggest corrections for spelling errors?
#' @param drop NULL or character vector with columns from original dataset to drop.
#' @return a data frame
#' @export
#' @examples
#' \dontrun{
#' tpl.get("Myrcia lingua")
#' }
tpl.get <-
  function(taxa, replace.synonyms = TRUE, suggest.names = TRUE, drop = c("major.group", "genus.hybrid.marker", "species.hybrid.marker", "nomenclatural.status.from.original.data.source", "ipni.id", "source.id", "publication", "collation", "page", "date"))  {
    taxa <- trim(taxa)
    taxa <- taxa[nzchar(taxa)]
    if (length(taxa) == 0L) stop("No valid names provided.")
    original.search <- taxa
    res <- data.frame(matrix(vector(), length(taxa), ncol(tpl.accepted[[1]]) + 1, dimnames=list(c(), c(names(tpl.accepted[[1]]), "note"))), stringsAsFactors = FALSE)
    minus.notes <- seq_len(ncol(tpl.accepted[[1]]))
    index <- 0
    for (taxon in taxa) {
      note <- NULL
      index <- index + 1
      taxon <- fixCase(taxon)
      uncertain <- regmatches(taxon, regexpr("[a|c]f+\\.", 
                                             taxon))
      if (length(uncertain) != 0L) 
        taxon <- gsub("[a|c]f+\\.", "", taxon)
      #ident <- regmatches(taxon, regexpr("\\s+sp\\.+\\w*", 
      #                                   taxon))
      #if (length(ident) != 0L) 
      #  taxon <- unlist(strsplit(taxon, " "))[1]
      if (!grepl(" ", taxon)) {
        res[index, "note"] <- "not full name"
        next
      }
      
      initials <- substr(strsplit(taxon, " ")[[1]], 1, 1)
      
      found <- taxon %in% tpl.names[[initials[1]]][[initials[2]]]
      
      if (!found) {
        if (suggest.names) {
          taxon <- suggest.name(taxon)
        } else {
          res[index, "note"] <- "not found"
          next
        }
        if (is.na(taxon)) {
          res[index, "note"] <- "not found"
          next
        } else {
          note <- "was misspelled"
        }
      }
      
      genus <- strsplit(taxon, " ")[[1]][1]
      #if (genus %in% names(tpl.accepted)) {
      accepted <- taxon %in% tpl.accepted[[genus]]$name
      #} else {
      #  accepted <- FALSE
      #}
      if (accepted) {
        taxon.info <- tpl.accepted[[genus]][which(tpl.accepted[[genus]]$name %in% taxon), ]
        how.many.accepted <- nrow(taxon.info)
        if (how.many.accepted == 1L) {
          res[index, minus.notes] <- taxon.info
        } else {
          note <- c(note, "check +1 accepted")
        }
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }
      
      synonym <- taxon %in% tpl.synonyms[[genus]]$name
      
      if (synonym) {
        taxon.info <- tpl.synonyms[[genus]][which(tpl.synonyms[[genus]]$name %in% taxon), ]
        how.many.synonyms <- nrow(taxon.info)
        if (replace.synonyms) {
          how.many.accepted <- sum(nzchar(unique(taxon.info$accepted.id)))
          if (how.many.accepted == 0L) {
            if (how.many.synonyms == 1L) {
              note <- c(note, "no accepted name")
              res[index, minus.notes] <- taxon.info
            }
            if (how.many.synonyms > 1L) {
              note <- c(note, "check no accepted +1 synonyms")
            }
          }
          if (how.many.accepted == 1L) {
            accepted.genus <- unique(tpl.accepted.index$genus[match(taxon.info$accepted.id, tpl.accepted.index$id)])
            if (length(accepted.genus) == 1L) {
              tpl.accepted.genus <- tpl.accepted[[accepted.genus]]
            } else {
              tpl.accepted.genus <- do.call(rbind.data.frame, tpl.accepted[accepted.genus])
            }
            accepted.ids <- tpl.accepted.genus$id %in% taxon.info$accepted.id
            if (!any(accepted.ids)) {
              note <- c(note, "check unresolved accepted")
              res[index, "note"] <- paste(note, collapse = "|")
              next
            }
            taxon.info <- tpl.accepted.genus[which(accepted.ids), ]
            hits <- nrow(taxon.info)
            if (hits == 0L) {
              note <- c(note, "check unresolved accepted")
            }
            if (hits == 1L) {
              note <- c(note, "replaced synonym")
              res[index, minus.notes] <- taxon.info
            }
            if (hits > 1L) {
              note <- c(note, "check +1 accepted")
            }
          }
          if (how.many.accepted > 1L) {
            accepted.genus <- tpl.accepted.index$genus[match(unique(taxon.info$id), tpl.accepted.index$id)]
            tpl.accepted.genus <- do.call(rbind.data.frame, tpl.accepted[accepted.genus])
            taxon.info <- tpl.accepted.genus[which(tpl.accepted.genus$id %in% taxon.info$accepted.id), ]
            really.accepted <- taxon.info$taxonomic.status.in.tpl == "Accepted"
            if (sum(really.accepted) == 0L) {
              note <- c(note, "check false accepted")
            }
            if (sum(really.accepted) == 1L) {
              note <- c(note, "replaced synonym")
              res[index, minus.notes] <- taxon.info[really.accepted, ]
            }
            if (sum(really.accepted) > 1L) {
              note <- c(note, "check +1 accepted")
            }
          }
          how.many.synonyms <- nrow(taxon.info)
        } else {
          if (how.many.synonyms == 1L) {
            res[index, minus.notes] <- taxon.info
          } else {
            note <- c(note, "check +1 entries")
          }
        }
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }      
      misapplied <- taxon %in% tpl.misapplied[[genus]]$name
      
      if (misapplied) {
        taxon.info <- tpl.misapplied[[genus]][which(tpl.misapplied[[genus]]$name %in% taxon), ]
        if (nrow(taxon.info) == 1L) {
          res[index, minus.notes] <- taxon.info
        } else {
          note <- c(note, "check +1 entries")
        }
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }
      
      unresolved <- taxon %in% tpl.unresolved[[genus]]$name
      
      if (unresolved) {
        taxon.info <- tpl.unresolved[[genus]][which(tpl.unresolved[[genus]]$name %in% taxon), ]
        if (nrow(taxon.info) == 1L) {
          res[index, minus.notes] <- taxon.info
        } else {
          note <- c(note, "check +1 entries")
        }
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }
    }
    if (is.null(drop)) {
      data.frame(res, original.search)
    } else {
      data.frame(res[!names(res) %in% drop], original.search)
    }
  }
