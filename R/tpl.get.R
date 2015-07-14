#' Get plant taxonomical and distribution data
#' 
#' This function collects taxonomic information from The Plant List. Synonyms and
#' misspelled names are resolved automatically.
#' 
#' @param taxa a character vector containing one or more taxa, without authors 
#'   see \code{\link{noauthors}} if you have a list with authorities
#' @param replace.synonyms should the function automatically replace synonyms?
#' @param suggest.names should the function try to suggest corrections for spelling errors?
#' @param suggestion.distance how conservative should the suggestion algorithm be?
#' @param drop NULL or character vector with columns from original dataset to drop.
#' @param apg.families Return APG families?
#' @param return.synonyms Return a list of synonyms instead of the regular dataset?
#' @return a data frame or a list of data frames if return.synonyms = TRUE
#' @export
#' @examples
#' \dontrun{
#' tpl.get("Myrcia lingua")
#' }
tpl.get <-
  function(taxa, replace.synonyms = TRUE, suggest.names = TRUE, suggestion.distance = 0.9, drop = c("major.group", "genus.hybrid.marker", "species.hybrid.marker", "nomenclatural.status.from.original.data.source", "ipni.id", "source.id", "publication", "collation", "page", "date"), apg.families = TRUE, return.synonyms = FALSE)  {
    taxa <- trim(taxa)
    taxa <- taxa[nzchar(taxa)]
    if (length(taxa) == 0L) stop("No valid names provided.")
    original.search <- taxa
    res <- data.frame(matrix(vector(), length(taxa), ncol(tpldata::tpl.accepted[[1]]) + 1, dimnames=list(c(), c(names(tpldata::tpl.accepted[[1]]), "note"))), stringsAsFactors = FALSE)
    minus.notes <- seq_len(ncol(tpldata::tpl.accepted[[1]]))
    index <- 0
    for (taxon in taxa) {
      note <- NULL
      index <- index + 1
      taxon <- fixCase(taxon)
      uncertain <- regmatches(taxon, regexpr("[a|c]f+\\.", 
                                             taxon))
      if (length(uncertain) != 0L) 
        taxon <- gsub("[a|c]f+\\.", "", taxon)
      ident <- regmatches(taxon, regexpr("\\s+sp\\.+\\w*", 
                                         taxon))
      if (length(ident) != 0L) 
        taxon <- unlist(strsplit(taxon, " "))[1]
      if (!grepl(" ", taxon)) {
        res[index, "note"] <- "not full name"
        if (taxon %in% names(tpldata::tpl.accepted)) {
          res[index, "family"] <- tpldata::tpl.accepted[[taxon]][1,"family"]
          res[index, "genus"] <- taxon
        } else {
          if (taxon %in% names(tpldata::tpl.synonyms)) {
            res[index, "family"] <- tpldata::tpl.synonyms[[taxon]][1,"family"]
            res[index, "genus"] <- taxon
          }
        }
        next
      }
      
      initials <- substr(strsplit(taxon, " ")[[1]], 1, 1)
      
      found <- taxon %in% tpldata::tpl.names[[initials[1]]][[initials[2]]]
      
      if (!found) {
        if (suggest.names) {
          taxon <- suggest.name(taxon, max.distance = suggestion.distance)
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
      #if (genus %in% names(tpldata::tpl.accepted)) {
      accepted <- taxon %in% tpldata::tpl.accepted[[genus]]$name
      #} else {
      #  accepted <- FALSE
      #}
      if (accepted) {
        taxon.info <- tpldata::tpl.accepted[[genus]][which(tpldata::tpl.accepted[[genus]]$name %in% taxon), ]
        how.many.accepted <- nrow(taxon.info)
        if (how.many.accepted == 1L) {
          res[index, minus.notes] <- taxon.info
        } else {
          note <- c(note, "check +1 accepted")
        }
        
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }
      
      synonym <- taxon %in% tpldata::tpl.synonyms[[genus]]$name
      if (synonym) {
        taxon.info <- tpldata::tpl.synonyms[[genus]][which(tpldata::tpl.synonyms[[genus]]$name %in% taxon), ]
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
            accepted.genus <- unique(tpldata::tpl.accepted.index$genus[match(taxon.info$accepted.id, tpldata::tpl.accepted.index$id)])
            if (length(accepted.genus) == 1L) {
              tpl.accepted.genus <- tpldata::tpl.accepted[[accepted.genus]]
            } else {
              tpl.accepted.genus <- do.call(rbind.data.frame, tpldata::tpl.accepted[accepted.genus])
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
            accepted.genus <- unique(tpldata::tpl.accepted.index$genus[match(unique(taxon.info$accepted.id), tpldata::tpl.accepted.index$id)])
            tpl.accepted.genus <- do.call(rbind.data.frame, tpldata::tpl.accepted[accepted.genus])
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
  
      misapplied <- taxon %in% tpldata::tpl.misapplied[[genus]]$name
      
      if (misapplied) {
        taxon.info <- tpldata::tpl.misapplied[[genus]][which(tpldata::tpl.misapplied[[genus]]$name %in% taxon), ]
        if (nrow(taxon.info) == 1L) {
          res[index, minus.notes] <- taxon.info
        } else {
          note <- c(note, "check +1 entries")
        }
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }
      
      unresolved <- taxon %in% tpldata::tpl.unresolved[[genus]]$name
      
      if (unresolved) {
        taxon.info <- tpldata::tpl.unresolved[[genus]][which(tpldata::tpl.unresolved[[genus]]$name %in% taxon), ]
        if (nrow(taxon.info) == 1L) {
          res[index, minus.notes] <- taxon.info
        } else {
          note <- c(note, "check +1 entries")
        }
        res[index, "note"] <- paste(note, collapse = "|")
        next
      }
    }
    if (apg.families) {
      for (taxon in seq_len(nrow(res))) {
        orig.family <- res[taxon, "family"]
        if (is.na(orig.family)) next
        is.old <- orig.family %in% tpl::apg$old
        if (is.old) {
          res[taxon, "family"] <- tpl::apg$new[which(tpl::apg$old == orig.family)]
          
        }
        if (!is.old && !orig.family %in% tpl::apg$new) {
          if (res[taxon, "note"] == "") {
            fam.note  <- "family not in APG"
          } else {
            fam.note <- "|family not in APG"
          }
          res[taxon, "note"] <- paste(res[taxon, "note"], fam.note, sep = "")
        }
      }
    }
    if (is.null(drop)) {
      res <- data.frame(res, original.search)
    } else {
      res <- data.frame(res[!names(res) %in% drop], original.search)
    }
    if (return.synonyms) {
      synonyms <- bind_rows(tpldata::tpl.synonyms)
      names(synonyms)[names(synonyms) == "id"] <- "synonym.id"
      res.synonyms <- merge(res[, c("id", "name", "original.search")], synonyms, by.x = "id", by.y = "accepted.id", suffixes = c(".accepted", ".synonym"))
      list(all.entries = res, synonyms = res.synonyms)
    } else {
      res
    }
  }
