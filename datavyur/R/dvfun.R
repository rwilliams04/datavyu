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
    
    warnTest <- paste0(
        "\nNote: At the moment there doesn't seem to be a way for datavyu to import", 
        " a .csv even though you can export to one. To get it back to .opf, use", 
        " the csv2opf.rb ruby script in the general folder.\n"
    )
    
    warning(simpleWarning(warnTest))
    
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

#' Import Datavyu column into R
#' 
#' Imports a Datavyu column to R when using the datavyu2csv.rb script
#' 
#' This function only works if you had previously used the \code{datavyu2csv.rb} script to export a Datavyu file to .csv
#' This can be obtained from \url{http://github.com/iamamutt/datavyu/general}.
#' 
#' Note: If the same column name was used but has different number of arguments then you will get an error unless \code{asList=TRUE}.
#' This function assumes that the .csv is structured in a way based on how the \code{datavyu2csv.rb} script exports data.
#' 
#' @param column The name of the column to import as used in the Datavyu .opf file
#' @param folder Character string corresponding to the folder path to be scanned. Defaults to option \code{datavyur.folder}.
#' @param asList Logical value indicating to return a list or data frame
#' @param ... Additional options passed to the function \link{\code{data.table::fread}}
#' @examples
#' import_column("myfolder", "mycolumn")
#' @export
import_column <- function(column, folder=getOption("datavyur.folder"), asList=FALSE, ... ) {
    
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
#' \cr
#' Note: Sometimes R doesn't get the right class of the imported column argument. 
#' This can happen if you have weird characters in your data. Use \code{colClasses} to override this.
#' 
#' @param all.opf Use all found .opf files from \code{folder} or specify .opf file names to use. Must 
#' be a character vector with exact file name matches as seen inside one of the exported .csv files.
#' @param all.cols Use all columns found in \code{folder} or only use specified column names entered
#' as a character vector. 
#' @param fps Common framerate to use for alignment. Defaults to 30 frames per second video.
#' @param colClasses List of new classes to override guessed classes when reading in .csv data. see \link{\code{data.table::fread}}
#' @param folder Defaults to option \code{datavyur.folder}.
#' @return data.frame with aligned data. This will be very large!
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
temporal_align <- function(all.opf=TRUE, 
                           all.cols=TRUE, 
                           folder=getOption("datavyur.folder"), 
                           fps=30, 
                           colClasses) 
{
    # get list of opf files, columns, args, locations
    message("Searching through .csv files for valid .opf data...")
    fdat <- opf_and_col_selector(all.opf = all.opf, all.cols = all.cols, folder = folder)
    
    # classes for each argument
    est_classes <- unique(fdat[, c("column", "args", "classes"), with=FALSE])
    est_classes[, both := paste0(column, ".", args)]
    
    # overwrite classes if specified
    if (!missing(colClasses)) {
        class_names <- names(colClasses)
        for (i in 1:length(colClasses)) {
            est_classes[both %in% colClasses[[i]], classes := class_names[i]]
        }
    }
    
    message("Reading in all located data...")
    opf_list <- lapply(unique(fdat$file), function(f) {
        # DEBUG: f <- fdat$file[1]
        
        # columns find in current file
        col_names <- fdat[file==f, unique(column)]
        
        # cycle through each column and import data
        to_merge <- lapply(col_names, function(cn) {
            # DEBUG: cn <- fdat[file==f, unique(column)][1]
            
            # path to column .csv for specific .opf file
            fpath <- fdat[file==f & column==cn, unique(local)]
            
            # import .csv
            # suppress warnings about class conversions
            DT <- suppressWarnings(
                data.table::fread(fpath, 
                                  stringsAsFactors=FALSE, 
                                  verbose=FALSE, 
                                  showProgress=FALSE, 
                                  colClasses = c(file="character",
                                                 column="character",
                                                 onset="integer",
                                                 offset="integer",
                                                 ordinal="integer")))
            
            # convert timestamps to frame counts
            DT[, `:=`(onset=ts2frame(onset, fps=fps, warn=FALSE), 
                      offset=ts2frame(offset, fps=fps, warn=FALSE))]
            
            # bad timestamp data
            outOfRange <- DT[, is.na(onset) | is.na(offset)]
            badTSdata <- DT[outOfRange, .(file, column, ordinal)]
            
            # frame expansion
            DT <- DT[outOfRange==FALSE, ]
            all_names_but_onoff <- names(DT)[!names(DT) %in% c("onset", "offset")]
            DT <- DT[, .(frame_number=frame_expand(onset, offset)), by=all_names_but_onoff]
            DT[, frame_number := as.numeric(frame_number)]
            
            # add columns if missing
            # overwrite classes from estimated classes
            arg_names <- est_classes[column==cn, sort(unique(args))]
            current_cols <- est_classes[args %in% arg_names, ]
            need_add <- arg_names[!arg_names %in% names(DT)]
            for (i in arg_names) {
                if (i %in% need_add) {
                    DT[[i]] <- NA
                } 
                suppressWarnings(class(DT[[i]]) <- current_cols[args==i, classes])
            }
            
            # remove unecessary columns
            DT[, column := NULL]
            DT[, ordinal := NULL]
            
            # add column prefix to argument names
            new_suffixes <- names(DT)[!names(DT) %in% c("file", "frame_number")]
            data.table::setnames(DT, new_suffixes, paste0(cn, ".", new_suffixes))
            
            return(data.table::copy(DT))
        })
        
        # begin file merge
        if (length(to_merge) > 1) {
            merged <- multi_merge(to_merge, 
                                  by = c("file", "frame_number"), 
                                  all = TRUE, 
                                  allow.cartesian=TRUE)
        } else {
            merged <- to_merge[[1]]
        }
        
        # if need to add whole columns not found
        need_add <- est_classes[!both %in% names(merged), both]
        for (i in need_add) {
            merged[[i]] <- NA
            suppressWarnings(class(merged[[i]]) <- est_classes[both == i, classes])
        }
        
        # set key for larger merge later
        data.table::setkey(merged)
        return(merged)
    })
    
    message("Merging all files...")
    # names of columns for all list items
    all_names <- sort(unique(unlist(lapply(opf_list, function(i) names(i)))))
    
    # begin merging all files into one large dataset
    opf_merged <- multi_merge(opf_list, by=all_names, all=TRUE)
    
    # some cleanup
    opf_merged <- opf_merged[order(file, frame_number), ]
    data.table::setkey(opf_merged)
    opf_merged <- unique(opf_merged)
    
    rowNAs <- apply(opf_merged[, !names(opf_merged) %in% c("file", "frame_number"), 
                               with=FALSE],
                    1, function(i) {
                        all(is.na(i))  
                    })
    
    opf_merged <- opf_merged[rowNAs==FALSE, ]
    
    message("Merge successful!")
    return(as.data.frame(opf_merged))
}
