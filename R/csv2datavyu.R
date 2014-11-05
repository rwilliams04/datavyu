# Functions to convert an R list to a datavyu csv file
# Some of these require my mejr R libary
# An R list object can have sublists
#   Each sublist is a datavyu column
#   There must be at least these sublists: ordinal, onset, offset
#   Each onset, offset must be in milliseconds time, as if datavyu exported it using a ruby script
# At the moment there doesn't seem to be a way for datavyu to IMPORT .csv
#   even though you can export to one
#   To get it back to .opf, use the csv2opf ruby script


# Example of what your data should look like
datavyu_dat <- function(n1=10, n2=15) {
    ch_on <- sort(round(runif(n1, 0, 3600000)))
    pr_on <- sort(round(runif(n2, 0, 3600000)))
    
    
    ch_off <- abs(round(runif(n1, ch_on+1, c(ch_on[2:n1]-1, 3600000))))
    pr_off <- abs(round(runif(n1, pr_on+1, c(pr_on[2:n1]-1, 3600000))))
    
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

# convert ms to time
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

# function to write r list object to a .csv file which datavyu understands
# must provide a file name
r2datavyu <- function(rlist, filename) {
    
    
    na2val <- function(x, v="") ifelse(is.na(x), v, x)
    message("Use the Ruby script to convert .csv to .opf")
    
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

# import datavyu column to r when using the datavyu2csv script
compile_dvcolumn <- function(folder, column) {
    filepaths <- list.files(folder, full.names=TRUE, pattern="\\.csv$")
    cols <- lapply(filepaths, function(x) {
        d <- read.csv(x, stringsAsFactors=FALSE)
        if (!any(names(d) == "column")) return(FALSE)
        return(all(d$column == column))
    })
    cols <- unlist(cols)
    #cols <- grepl(paste0(column, "__"), basename(filepaths))
    sublist <- filepaths[cols]
    dat <- stackCSV(files=sublist, search=FALSE, stringsAsFactors=FALSE)
    return(dat)
}

# scan through files to find names of files
scan_colnames <- function(folder, unq=FALSE) {
    filepaths <- list.files(folder, full.names=TRUE, pattern="\\.csv$")
    cols <- lapply(filepaths, function(x) {
        d <- read.csv(x, stringsAsFactors=FALSE)
        if (!any(names(d) == "column")) return(NA)
        return(unique(d$column))
    })
    cols <- unlist(cols)
    if (unq) cols <- unique(cols)
    return(cols)
}
