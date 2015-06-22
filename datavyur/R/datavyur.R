# Package info ------------------------------------------------------------

#' datavyur: An R Package for dealing with Datavyu files
#' 
#' A set of functions to handle import/export between R and Datavyu
#' 
#' @section Exported functions:
#' \code{\link{datavyu_col_search}} \cr
#' \code{\link{datavyu_dat}} \cr
#' \code{\link{import_column}} \cr
#' \code{\link{merge_by_time}} \cr
#' \code{\link{ms2time}} \cr
#' \code{\link{r2datavyu}} \cr
#' 
#' @docType package
#' @name datavyur
NULL

# Load options ------------------------------------------------------------

.onLoad <- function(libname, pkgname)
{
  
  startupText <- paste0(
    "Functions to convert an R list to a datavyu csv file\n",
    "Note: At the moment there doesn't seem to be a way for datavyu to IMPORT", 
    " .csv even though you can export to one. To get it back to .opf, use", 
    " the csv2opf ruby script."
  )
  
  message(startupText)
  
  op <- options()
  dv.ops <- list(
    datavyur.null = NULL
  )
  toset <- !(names(dv.ops) %in% names(op))
  if(any(toset)) options(dv.ops[toset])
  return(invisible())
}
