% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/trim.R
\name{trim}
\alias{trim}
\title{Trim a name and remove duplicate tabs and whitespaces}
\usage{
trim(taxon)
}
\arguments{
\item{taxon}{a character vector with a single taxon name}
}
\value{
a character vector
}
\description{
Remove duplicate and misplaced whitespace characters
}
\examples{
trim("   Myrcia  lingua")
}

