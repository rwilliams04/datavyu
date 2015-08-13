# Datavyu Functions --------------------------------------------------------------

#' Fake Datavyu data
#' 
#' This function will create fake data in the R format needed to import back into the Datavyu software
#'
#' The function shows how you can have either a list of columns or an actual data frame.
#' Either way will work.
#' 
#' @param n1 Sample size for variable 1
#' @param n2 Sample size for variable 2
#' @return List of datavyu formated data
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

#' R data to Datavyu .csv file
#' 
#' Process to transfer R data to Datavyu
#' 
#' Exports R data (as a list of lists or dataframes corresponding to Datavyu columns) to a .csv file. 
#' This can then be used by Datavyu for saving as .opf and importing R data Datvyu. 
#' Each list item is a different column in the final Datavyu file.
#' NOTE: Datavyu cannot currently import the .csv files this function creates.
#' To get the .csv file back into Datavyu, use the \code{csv2opf.rb} file found here: 
#' \url{http://github.com/iamamutt/datavyu/general}.
#' 
#' @param rlist List of lists or data.frames. These are the columns to be used in the final Datavyu file.
#' @param filename Filename of the .csv file to be created. Leave off extension. May specify path as prefix.
#' @examples
#' # First get example data to use
#' example_data <- datavyu_dat()
#' 
#' # See how the example data is structured, as a list with another list and data.frame
#' # Both the list and data.frame are named. If not named, one will be assigned.
#' str(example_data)
#' 
#' # Export R list to a .csv file for importing into Datavyu
#' r2datavyu(example_data, "example_file")
#' @export
r2datavyu <- function(rlist, filename="datavyur_export") {
    
    warnText <- paste0(
        "\nNote: At the moment there doesn't seem to be a way for datavyu to import", 
        " a .csv even though you can export to one. To get it back to .opf, use", 
        " the csv2opf.rb ruby script in the general folder.\n"
    )
    
    warning(simpleWarning(warnText))
    
    na2val <- function(x, v="") ifelse(is.na(x), v, x)
    
    top_digit <- "#4"
    
    n_col <- length(rlist)
    col_names <- names(rlist)
    
    if (n_col < 1) stop(simpleError("no columns found in r list object"))
    
    # check for named rlist, add new names if necessary
    if (is.null(col_names)) {
        new_names <- paste0("datavyur", 1:n_col)
        names(rlist) <- new_names
    } else {
        no_names <- col_names == ""
        if (any(no_names)) {
            new_names <- paste0("datavyur", 1:n_col)[no_names]
            names(rlist)[no_names] <- new_names
        }
    }
    
    # go through each column structured as an r list
    each_col <- lapply(1:n_col, function(col) {
        
        # get names of codes
        codes <- rlist[[col]]
        col_name <- col_names[col]
        code_names <- names(codes)
        
        if (is.null(code_names)) {
            stop(simpleError(
                paste0("ordinal, onset, offset not found for: ", col_name)
            ))
        }
        
        # check of codes have these common arguments
        common_code_names <- c("ordinal", "onset", "offset")
        common_codes_l <- common_code_names %in% code_names
        custom_code_names <- code_names[!code_names %in% common_code_names]
        
        if (!all(common_codes_l)) {
            stop(simpleError(
                paste0("ordinal, onset, offset not found for: ", col_name)
            ))
        }
        
        ts_ord <- codes$ordinal
        ts_on <- ms2time(codes$onset)[ts_ord]
        ts_off <- ms2time(codes$offset)[ts_ord]
        
        if (length(custom_code_names) == 0) {
            codes$code1 <- rep(NA, length(ts_ord))
            custom_code_names <- "code1"
        }
        
        code_str <- paste0(custom_code_names, "|NOMINAL", collapse=",")
        col_str <- paste0(col_name, " (MATRIX,true,)-", code_str)
        
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

#' Import Datavyu column into R
#' 
#' Imports a Datavyu column to R when using the datavyu2csv.rb script
#' 
#' This function only works if you had previously used the \code{datavyu2csv.rb} script to export a Datavyu file to .csv
#' This can be obtained from \url{http://github.com/iamamutt/datavyu/general}.
#' \cr
#' Note: If the same column name was used but has different number of arguments then you will get an error unless \code{asList=TRUE}.
#' This function assumes that the .csv is structured in a way based on how the \code{datavyu2csv.rb} script exports data.
#' 
#' @param column The name of the column to import as used in the Datavyu .opf file
#' @param folder Character string corresponding to the folder path to be scanned. Defaults to option \code{datavyur.folder}.
#' @param asList Logical value indicating to return a list or data frame (default).
#' @param append.colnames If \code{true}, add column name to each argument, 
#' e.g., \code{column.arg}, instead of having column as a variable in the data. 
#' @param ... Additional options passed to the function \code{data.table::fread}
#'
#' @examples
#' import_column("childhands")
#' import_column("childhands", append.colnames = TRUE)
#' @export
import_column <- function(column, 
                          folder=getOption("datavyur.folder"), 
                          asList=FALSE, 
                          append.colnames=FALSE,
                          ...)
{
    
    opf_info <- opf_and_col_selector(all.opf = TRUE, all.cols = column, folder = folder)
    
    static_classes <- c(file="character",
                        column="character",
                        onset="integer",
                        offset="integer",
                        ordinal="integer")
    
    fread_opts <- list(stringsAsFactors=FALSE,
                       verbose=FALSE,
                       showProgress=FALSE,
                       colClasses=static_classes)
    
    # overwrite default options
    ops <- list(...)
    toset <- !(names(fread_opts) %in% names(ops))
    fread_opts <- c(fread_opts[toset], ops)
    
    dat <- lapply(opf_info$local, function(i) {
        in_file <- list(input=i)
        DT <- do.call(data.table::fread, c(in_file, fread_opts))
        return(data.table::copy(DT))
    })
    
    if (!asList) {
        dat <- do.call(rbind, dat)
    }
    
    if (append.colnames) {
        append_colname(dat, column, c("file", "column"))
        dat[, column := NULL]
    }

    return(as.data.frame(dat))
}


#' Scan .csv files for data
#' 
#' Scans data exported as .csv from Datavyu and returns a list of .opf column names among other attributes
#' 
#' The function will read all .csv files found in \code{folder}.
#' All valid .opfs will be found based on if they have the columns \code{file, column, onset, offset, ordinal}.
#' 
#' @param folder Character string of the name of the folder to be scanned. Defaults to option \code{datavyur.folder}.
#' @param unq Return only unique column names
#' @param cnames Name of columns to return if \code{unq=TRUE}.
#' @return data.frame with .csv info. The variable \code{file} is the original .opf file name used.
#' \code{column} is the name of the column within the .opf file. \code{args} are the argument names used.
#' \code{classes} are the guessed classes for each argument based on R import functions.
#' \code{local} is the .csv file name and location for a particular column and .opf file.
#' @examples
#' datavyu_col_search("myfolder")
#' @export
datavyu_col_search <- function(folder=getOption("datavyur.folder"), 
                               unq=FALSE, 
                               cnames=c("file", "column", "args", "classes", "local"))
{
    message("Searching through .csv files for valid .opf data...")
    dvcols <- check_opf_data(folder=folder)
    if (unq) {
        dvcols <- unique(dvcols[, cnames, with=FALSE], by=cnames)
    }
    return(as.data.frame(dvcols))
}


#' Merge nested data
#' 
#' Merges two data frames by onset/offset timestamps
#' 
#' Since data is nested, this will repeat rows from the higher level data. Both x and y must be data frames.
#' 
#' @param x top level data frame, (e.g., trial or block)
#' @param y lower level data frame (e.g., eye gazes within trial)
#' @param ids Suffixes to use to identify repeated column names
#' @param keepall whether to keep all non-matching rows (true) or throw away non-matching (false).
#' @param mergeby any additional common columns to merge by. Defaults to merging only by \code{file}.
#' @examples
#' # get data with some rows not nested
#' x <- as.data.frame(datavyu_dat(n1=25, n2=2)[[1]])
#' y <- datavyu_dat(n1=2, n2=100)[[2]]
#' 
#' z1 <- merge_nested(x, y)
#' z2 <- merge_nested(x, y, ids=c(".higher", ".lower"), keepall=FALSE)
#' @export
merge_nested <- function(x, y, ids=c(".1", ".2"), keepall=TRUE, mergeby=NULL) {
    
    if (class(x)[1] != "data.frame" | class(y)[1] != "data.frame") {
        stop(simpleError("x and y must both be of class data.frame"))
    }
    
    mergeby <- unique(c("file", mergeby))
    
    file_c_exists <- c("file" %in% names(x), "file" %in% names(y))
    created_file <- FALSE
    if (all(file_c_exists)==FALSE) {
        x$file <- "None"
        y$file <- "None"
        created_file <- TRUE
    } else if (sum(file_c_exists) == 1) {
        stop(simpleError("One data frame had column file but not the other"))
    }
    
    mrgdat <- lapply(as.character(unique(x$file)), function(j) {
        #print(j)
        xj <- x[x$file == as.character(j), ]
        yj <- y[y$file == as.character(j), ]
        
        if (nrow(xj) == 0 | nrow(yj) == 0) {
            return(NULL)
        }
        
        xj$temp_index_val_000xy <- 1:nrow(xj)
        yj$temp_index_val_000xy <- NA
        
        for (i in 1:nrow(xj)) {
            # i=1
            onset_x <- as.numeric(xj[i, "onset"])
            offset_x <- as.numeric(xj[i, "offset"])
            y_rows <- as.numeric(yj[, "onset"]) >= onset_x & as.numeric(yj[, "offset"]) <= offset_x
            
            if (any(y_rows)) {
                yj[y_rows, "temp_index_val_000xy"] <- i
            }
        }    
        
        z <- merge(xj, yj, by=c(mergeby, "temp_index_val_000xy"), suffixes=ids, all=keepall)
        
        return(z)
    })
    
    mrgdat <- do.call(rbind, mrgdat)
    mrgdat$temp_index_val_000xy <- NULL
    if (created_file) mrgdat$file <- NULL
    return(mrgdat)
}

#' Temporally align data by frame
#' 
#' This will align several Datavyu columns by common frame number
#' 
#' You have the option to set the framerate using \code{fps}. The lower the frame rate, the less likely
#' two events will line up in time. This is because the timestamps are converted to frame numbers based on chunking into bins.
#' The larger the fps, the larger the bins, and more likely two events will line up in time.
#' Note: Sometimes R doesn't get the right class of the imported column argument. 
#' This can happen if you have weird characters in your data. Use \code{colClasses} to override this.
#' 
#' @param all.opf Use all found .opf files from \code{folder} or specify .opf file names to use. Must 
#' be a character vector with exact file name matches as seen inside one of the exported .csv files.
#' @param all.cols Use all columns found in \code{folder} or only use specified column names entered
#' as a character vector. 
#' @param fps Common framerate to use for alignment. Defaults to 30 frames per second video.
#' @param keep.frames Keep the frame_number column, which will result in a much larger dataset.
#' If \code{keep.frames=FALSE}, then all you know is which two events overlap, not knowing for how long.
#' If \code{keep.frames=TRUE} (default), you can calculate the number of frames that overlap between two events, and if fps is know,
#' you can convert this total to milliseconds.
#' @param colClasses List of new classes to override guessed classes when reading in .csv data. see \code{data.table::fread}
#' @param folder Defaults to option \code{datavyur.folder}.
#' @param ... Additional arguments passed to \code{data.table::fread}, 
#' except \code{stringsAsFactors, colClasses, verbose, showProgress}
#' @return data.frame with aligned data. This will be very large!
#' @export
#' @examples
#' # set folder path if needed, otherwise use default path with example data.
#' # options(datavyur.folder="mydatafolder")
#' 
#' # example data with no arguments
#' ex_data_aligned <- temporal_align()
#' 
#' # example data selecting only one of the columns
#' ex_data_aligned2 <- temporal_align(all.cols="childhands")
#' 
#' # example data using additional arguments
#' newClasses <- list(integer=c("childhands.look", "parenthands.look"), 
#'                    character=c("childhands.hand", "parenthands.hand"))
#' ex_data_aligned3 <- temporal_align(fps=10, colClasses=newClasses)
temporal_align <- function(all.opf = TRUE,
                           all.cols = TRUE,
                           folder = getOption("datavyur.folder"),
                           fps = 30,
                           keep.frames = TRUE,
                           colClasses,
                           ...)
{
    
    dat <- align_routine(
        ordinal = FALSE,
        all.opf = all.opf,
        all.cols = all.cols,
        folder = folder,
        fps = fps,
        colClasses = colClasses,
        ...
    )
    
    if (!keep.frames) {
        dat[, frame_number := NULL]
        dat <- unique(dat)
    }
    
    return(dat)
}



#' Ordinal alignment
#' 
#' Align and merge data by cell number (ordinal)
#'
#' See \code{\link{temporal_align}} for more details on function usage. 
#' 
#' @param all.opf All .opf files (\code{TRUE}) or a character vector of specific .opf files to use
#' @param all.cols All columns from a .opf file or character vector of specific column names
#' @param folder Search folder, defaults to \code{datavyur.folder} option
#' @param colClasses Override column classes.
#' @param ... Additional arguments passed to \code{data.table::fread}, 
#' except \code{stringsAsFactors, colClasses, verbose, showProgress}
#' @return A data.frame with merged data aligned by cell number (ordinal value)
#' @export
#' @seealso \code{\link{temporal_align}}
#' @examples
#' ordinal_align()
ordinal_align <- function(all.opf=TRUE, 
                          all.cols=TRUE, 
                          folder=getOption("datavyur.folder"),
                          colClasses, 
                          ...)
{
    dat <- align_routine(
        ordinal = TRUE,
        all.opf = all.opf,
        all.cols = all.cols,
        folder = folder,
        fps = NA,
        colClasses = colClasses,
        ...
    )
    return(dat)
}

#' Check columns for bad codes
#' 
#' Check for invalid codes used for each column and argument specified
#' 
#' This takes an already existing data.frame/data.table and checks specific columns 
#' to see if they contain only the codes listed in \code{code_list}. Each item in the 
#' list must be named according to the column name in the data.frame, and each item
#' must contain a vector of 1 or more of valid codes to check. Codes can be numeric or
#' characters.
#'
#' @param code_list A list of column names with each name having a vector of codes to check.
#' @param dat The data.frame/data.table to check
#' @param as.na If \code{TRUE}, will return a new data set with \code{NA} instead of the bad code.
#'
#' @return A list containing two items. \code{$data} is the new data with NAs, 
#' \code{$bad_codes} is another list, each item corresponding to the input list. In 
#' each there is a data.frame that is either empty (no bad codes found), or contains indices
#' for the row numbers with bad codes and the column name and type of bad code found. 
#' If \code{as.na=FALSE}, the new data will be \code{NULL}, and will only return
#' \code{$bad_codes}, if any.
#' @export
#' @examples
#' # Use example data
#' dat <- ordinal_align()
#' 
#' # Make the list of valid codes, names corresponding to columns in the data
#' code_list <- list(
#'     childhands.hand = c("left", "right", "both"),
#'     childhands.look = c(0,1),
#'     parenthands.hand = c("left", "right", "both"),
#'     parenthands.look = c(0,1)
#' )
#' 
#' # check for bad codes, returning new data with bad codes as NAs
#' codes_checked <- check_codes(code_list, dat)
check_codes <- function(code_list, 
                        dat, 
                        as.na=TRUE)
{
    # check if list
    if (class(code_list) != "list") {
        stop(simpleError("code_list must be a list of column names and valid codes"))
    }
    
    # make as data.table
    if (!any(class(dat) == "data.table")) {
        d <- data.table::as.data.table(dat)
    } else {
        d <- data.table::copy(dat)
    }
    data.table::setkey(d)
    
    # assess common column names
    cnames <- names(code_list)
    dnames <- names(d)
    valid_names <- cnames[cnames %in% dnames]
    invalid_names <- cnames[!cnames %in% dnames]
    
    bad_list <- code_list[valid_names]
    
    # check codes here, make table of bad codes
    for (n in valid_names) {
        valid_codes <- code_list[[n]]
        not_ok <- which(!(d[[n]] %in% valid_codes | is.na(d[[n]])))
        bad_list[[n]] <- d[not_ok, .(V1 = not_ok, V2 = get(n))]
        data.table::setnames(bad_list[[n]], c("V1", "V2"), c("index", n))
        if (as.na) d[not_ok, eval(n) := NA]
    }
    
    # convert bad codes to old data.frame
    bad_list <- lapply(bad_list, as.data.frame)
    
    # overwritten data to data.frame or null
    if (as.na) {
        new_dat <- as.data.frame(d)
    } else {
        new_dat <- NULL
    }
    
    # warn about invalid names used in arg list
    if (length(invalid_names) != 0) {
        w1 <- paste0(invalid_names, collapse=", ")
        w2 <- paste0("columns not found in data: ", w1)
        warning(simpleWarning(w2))
    }
    
    return(list(data=new_dat, bad_codes=bad_list))
}



#' Check for invalid timestamps
#'
#' @param ts_list A list with each item corresponding to either a pair of timestamp columns
#' \code{c(onset, offset)}, or just a single column name. If a single name, durations will not be checked,
#' and only out of range will be checked. 
#' @param dat A data.frame/data.table that contains the columns with the onset/offset timestamps
#' @param tmin Minimum allowed timestamp. Defaults to 0 (milliseconds)
#' @param tmax Maximum allowed timestamp. Defaults to one day in milliseconds.
#' @param as.na Set bad timestamps to \code{NA}
#'
#' @return Returns a list with 3 items, \code{$data, $ranges, $durations}. 
#' \code{$data} is new data with bad timestamps as \code{NA}. \code{$ranges} is
#' a list of column names, with a vector of indices corresponding to timestamps
#' out of range. If all okay, the vector is empty. \code{$durations} is a list
#' of bad timestamp durations. If \code{as.na=TRUE}, the offset timestamp is 
#' set to \code{NA}.
#' @export
#' @examples
#' # Use example data
#' dat <- ordinal_align()
#' 
#' # Make the list of timestamps to check in the example data
#' # These check durations as well as out of range
#' ts_list <- list(
#'     c(on="parenthands.onset", off="parenthands.offset"), # explicit
#'     child = c("childhands.onset", "childhands.offset") # infer from order which is on/off
#' )
#' ts_checked <- check_timestamps(ts_list, dat)
#' 
#' # This only checks for bad ranges since its only one column name.
#' # ts_list can be mixed with 2 or 1 items each.
#' ts_list <- list("parenthands.offset")
#' ts_checked2 <- check_timestamps(ts_list, dat)
check_timestamps <- function(ts_list, 
                             dat, 
                             tmin=0, 
                             tmax=864e5, 
                             as.na=TRUE)
{
    
    # check if list
    if (class(code_list) != "list") {
        stop(simpleError(
            "ts_list must be a list object. see ?check_timestamps"
        ))
    }
    
    # make as data.table
    if (!any(class(dat) == "data.table")) {
        d <- data.table::as.data.table(dat)
    } else {
        d <- data.table::copy(dat)
    }
    data.table::setkey(d)
    
    # range and duration subfunctions
    range_conditions <- function(x) {
        (x >= tmin & x <= tmax) #& !is.na(x)
    }
    
    duration_condition <- function(x, y) {
        z <- y - x
        z >= 0 & abs(z) <= tmax - tmin
    }
    
    # assess common column names
    cnames <- unique(unlist(ts_list))
    dnames <- names(d)
    valid_names <- cnames[cnames %in% dnames]
    invalid_names <- cnames[!cnames %in% dnames]
    
    if (length(invalid_names) != 0) {
        w1 <- paste0(invalid_names, collapse=", ")
        w2 <- paste0("columns not found in data: ", w1)
        stop(simpleError(w2))
    }
    
    # find bad ranges
    bad_rng <- lapply(valid_names, function(i) {
        which(!range_conditions(d[[i]]))
    })
    names(bad_rng) <- valid_names
    
    # find bad durations
    bad_dur <- lapply(ts_list, function(i) {
        l <- length(i)
        if (l == 1) {
            bad_dur <- integer()
        } else if (l == 2) {
            if (is.null(names(i))) {
                on <- i[1]
                off <- i[2]
            } else {
                on <- i["on"]
                off <- i["off"]
            }
            bad_dur <-  which(!duration_condition(d[[on]], d[[off]]))
            if (length(bad_dur) > 0 & as.na) d[bad_dur, eval(off) := NA]
        } else {
            stop(simpleError(
                "each item in ts_list must be of length 1 or 2"
            ))
        }
        return(bad_dur)
    })
    
    # check for named ts_list, add new names if necessary
    tnames <- names(ts_list)
    if (is.null(tnames)) {
        dur_names <- paste0("dur", 1:length(ts_list))
        names(bad_dur) <- dur_names
    } else {
        no_names <- tnames == ""
        dur_names <- paste0("dur", 1:length(tnames))[no_names]
        names(bad_dur)[no_names] <- dur_names
    }
    
    ## Overwrite data or set data to null
    if (as.na) {
        for (i in names(bad_rng)) {
            d[bad_rng[[i]], eval(i) := NA]
        }
        new_dat <- as.data.frame(d)
    } else {
        new_dat <- NULL
    }
    
    return(list(data=new_dat, ranges=bad_rng, durations=bad_dur))
}
