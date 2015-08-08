# Package info ------------------------------------------------------------

#' datavyur: An R Package for dealing with Datavyu files
#' 
#' A set of functions to handle import/export between R and Datavyu
#' 
#' @section Exported functions:
#' \code{\link{datavyu_col_search}} \cr
#' \code{\link{datavyu_dat}} \cr
#' \code{\link{import_column}} \cr
#' \code{\link{merge_nested}} \cr
#' \code{\link{ms2time}} \cr
#' \code{\link{multi_merge}} \cr
#' \code{\link{ordinal_align}} \cr
#' \code{\link{r2datavyu}} \cr
#' \code{\link{temporal_align}} \cr
#' \code{\link{ts2frame}} \cr
#' @import data.table
#' @docType package
#' @name datavyur
NULL

# Load options ------------------------------------------------------------

.onLoad <- function(libname, pkgname)
{
  
  startupText <- paste0(
    "\nFunctions to convert an R list to a datavyu csv file\n"
  )
  
  message(startupText)
  
  op <- options()
  dv.ops <- list(
    datavyur.folder = system.file("extdata", package="datavyur")
  )
  toset <- !(names(dv.ops) %in% names(op))
  if(any(toset)) options(dv.ops[toset])
  return(invisible())
}
