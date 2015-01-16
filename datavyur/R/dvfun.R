message(
"
Functions to convert an R list to a datavyu csv file


Note: At the moment there doesn't seem to be a way for datavyu to IMPORT .csv even though you can export to one. To get it back to .opf, use the csv2opf ruby script
"
)

#' Fake Datavyu data
#' 
#' This function will create fake data in the R format needed to import into Datavyu
#'
#' The function shows how you can have either a list of columns or an actual data frame. Either way will work.
#' @param n1 Sample size for variable 1
#' @param n2 Sample size for variable 2
#' @examples
#' my_data <- datavyu_dat()
#' @export
datavyu_dat <- function(n1=10, n2=15) {
  ch_on <- sort(round(runif(n1, 0, 3600000)))
  pr_on <- sort(round(runif(n2, 0, 3600000)))
  
  
  ch_off <- abs(round(runif(n1, ch_on+1, c(ch_on[2:n1]-1, 3600000))))
  pr_off <- abs(round(runif(n2, pr_on+1, c(pr_on[2:n2]-1, 3600000))))
  
  hand_char <- c("left", "right", "both", "")
  look_val <- c("0", "1", "")
  
  dat <- list(
    childhands = list(
      ordinal=1:n1,
      onset=ch_on,
      offset=ch_off,
      hand=sample(hand_char, n1, replace=TRUE),
      look=sample(look_val, n1, replace=TRUE)
    ),
    parenthands = data.frame(
      ordinal=1:n2,
      onset=pr_on,
      offset=pr_off,
      hand=sample(hand_char, n2, replace=TRUE),
      look=sample(look_val, n2, replace=TRUE)
    )
  )
  return(dat)
}

#' Convert milliseconds to a time string
#' 
#' This will take a duration of time in milliseconds and convert it to a time string format
#' 
#' @param timestamp A numeric time duration, such as \code{1102013} ms
#' @param unit How the string will be contructed. Default is Hours:Minutes:Seconds.MS
#' @param msSep How the separator between seconds and ms will look like
#' @examples
#' # 18 minutes and 22 seconds and 13 milliseconds
#' ms2time(1102013)
#' @export
ms2time <- function(timestamp, unit="%H:%M:%S", msSep=":") {
  if (any(timestamp >= 60*60*24*1000)) stop(simpleError("More than 24 hours. Can't do days"))
  sec <- timestamp/1000
  ms <- formatC(x=round((sec-trunc(sec))*1000, digits=3), 
                digits=3, width=3, format="d", flag="0")
  sec <- trunc(sec)
  start <- as.POSIXct(Sys.time())
  dt <- difftime(start+sec, start, units="secs")
  time_char <- paste0(format(.POSIXct(dt, tz="GMT"), unit), msSep, ms)
  return(time_char)
}

#' R data to Datavyu .csv file
#' 
#' Exports R data as a list or dataframe to a .csv file used by Datavyu for importing.
#' 
#' Each list item is a different column in the final datavyu file.
#' 
#' Note: Datavyu cannot currently import .csv files. To get the .csv file back into Datavyu
#' use the \code{csv2opf.rb} file found here: \url{http://github.com/iamamutt/datavyu/general}.
#' 
#' @param rlist List of columns to be used in the final Datavyu file.
#' @param filename Filename of the .csv file to be used
#' @examples
#' # First get example data to use
#' example_data <- datavyu_dat()
#' 
#' # See how the example data is structured
#' str(example_data)
#' 
#' # Export R list to a .csv file for importing into Datavyu
#' r2datavyu(example_data, "example_file")
#' @export
r2datavyu <- function(rlist, filename="datavyur_export") {
  
  na2val <- function(x, v="") ifelse(is.na(x), v, x)
  
  top_digit <- "#4"
  
  n_col <- length(rlist)
  col_names <- names(rlist)
  
  if (n_col < 1) stop(simpleError("no columns found in r list object"))
  if (any(col_names == "")) stop(simpleError("not all list items have column names"))
  
  # go through each column structured as an r list
  each_col <- lapply(1:n_col, function(col) {
    
    # get names of codes
    codes <- rlist[[col]]
    col_name <- col_names[col]
    code_names <- names(codes)
    
    common_codes_l <- code_names %in% c("ordinal", "onset", "offset")
    
    if (sum(common_codes_l) != 3) stop(simpleError("ordinal, onset, offset not found"))
    if (length(codes) < 4) stop(simpleError("no custom arguments found"))
    
    
    custom_code_names <- code_names[!common_codes_l]
    code_str <- paste0(custom_code_names, "|NOMINAL", collapse=",")
    col_str <- paste0(col_name, " (MATRIX,true,)-", code_str)
    
    ts_ord <- codes$ordinal
    ts_on <- ms2time(codes$onset)[ts_ord]
    ts_off <- ms2time(codes$offset)[ts_ord]
    
    code_mat <- lapply(custom_code_names, function(cn) {
      na2val(as.character(codes[[cn]])[ts_ord])
    })
    
    code_mat <- cbind(ts_on, ts_off, do.call(cbind, code_mat))
    
    col_dat <- apply(code_mat, 1, function(s) {
      code_text <- paste0("(", paste0(s[-c(1,2)], collapse=","), ")", collapse="")
      paste0(s[1], ",", s[2], ",", code_text)
    })
    
    return(c(col_str, col_dat))
  })
  
  text_lines <- c(top_digit, c(each_col, recursive=TRUE))
  out_file <- file(paste0(filename, ".csv"), "w")
  writeLines(text_lines, out_file)
  close(out_file)
}

#' Import Datavyu column to R
#' 
#' Imports a Datavyu column to R when using the datavyu2csv.rb script
#' 
#' This function only works if you had previously used the \code{datavyu2csv.rb} script to export a Datavyu file to .csv
#' This can be obtained from \url{http://github.com/iamamutt/datavyu/general}.
#' 
#' Note: If the same column name was used but has different number of arguments then you will get an error unless \code{asList=TRUE}.
#' This function assumes that the .csv is structured in a way based on how the \code{datavyu2csv.rb} script exports data.
#' 
#' @param folder Character string of the name of the folder to be scanned.
#' @param column The name of the column to import as used in the Datavyu file
#' @param asList Logical value indicating to return a list or data frame
#' @param ... Additional options passed to the read.csv function
#' @examples
#' import_column("myfolder", "mycolumn")
#' @export
import_column <- function(folder, column, asList=FALSE, ... ) {
  require(mejr)
  filepaths <- list.files(folder, full.names=TRUE, pattern="\\.csv$")
  cols <- lapply(filepaths, function(x) {
    d <- read.csv(x, stringsAsFactors=FALSE)
    if (!any(names(d) == "column")) return(FALSE)
    return(all(d$column == column))
  })
  cols <- unlist(cols)
  #cols <- grepl(paste0(column, "__"), basename(filepaths))
  sublist <- filepaths[cols]
  
  dat <- lapply(sublist, function(x) read.csv(x, ...))

  if (!asList) dat <- do.call(rbind, dat)
  
  return(dat)
}


#' Scan .csv files for data
#' 
#' Scans data exported as .csv from Datavyu and returns a list of column names
#' 
#' The function will read all csv files found in the folder and check if they have the column name as indicated in the \code{cname} argument.
#' If the column name is found, it will return the name of the actual column name used within Datavyu.
#' 
#' @param folder Character string of the name of the folder to be scanned.
#' @param unq Return only unique column names
#' @param cname Name of .csv column to check if exists. Defaults to \code{"column"}. 
#' @examples
#' datavyu_col_search("myfolder")
#' @export
datavyu_col_search <- function(folder, unq=FALSE, cname="column") {
  filepaths <- list.files(folder, full.names=TRUE, pattern="\\.csv$")
  cols <- lapply(filepaths, function(x) {
    d <- read.csv(x, stringsAsFactors=FALSE)
    if (!any(names(d) == cname)) return(NA)
    return(unique(d$column))
  })
  cols <- unlist(cols)
  if (unq) {
    cols <- unique(cols)
  }
  return(cols)
}
