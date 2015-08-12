
.dv_test <- function(){
    options("datavyur.folder"="../tutorial/R/data")
}

#' Multiple data merge
#' 
#' Merge data into a single data structure from a list of data.frames/tables
#'
#' @param data_list List of separate data.frames/tables to merge
#' @param ... Additional arguments passed to \code{merge}
#'
#' @return A data.frame/data.table, depending on the input data in the list
#' @export
#'
#' @examples
#' d1 <- datavyu_dat()$parenthands
#' d2 <- as.data.frame(datavyu_dat()$childhands)
#' d3 <- datavyu_dat(n2=50)$parenthands
#' data_list <- list(d1, d2, d3)
#' merged_data <- multi_merge(data_list, all=TRUE)
multi_merge <- function(data_list, ...) {
    Reduce(function(x, y) {
        #if (data.table::is.data.table(x)) data.table::setkey(x)
        #if (data.table::is.data.table(y)) data.table::setkey(y)
        merge(x, y, ...)
    }, data_list)
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
ms2time <- function(timestamp, 
                    unit="%H:%M:%S", 
                    msSep=":") 
{
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


#' Convert timestamps to frame numbers
#'
#' @param x Vector of timestamps
#' @param fps Frames per second of the video source. 
#' Defaults to 30 Frames Per Second. The smaller the value, the more likely 
#' two events will be chunked in the same frame.
#' @param tstart Start timestamp. Anything below start will not be converted. 
#' @param tend End timestamp. Anything above will be NA. Defaults to max of x if not set. 
#' @param chunked If set to TRUE, will return a time back to you instead of frame number, 
#' but the chunked/cut value corresponding to that frame. 
#' @param warn Turn on/off warnings for NAs
#' @return numeric vector same size as x
#' @export
#'
#' @examples
#' t <- c(-1000,4047,7451,14347,17424,21673,27920,30669,39798,42504,49995,51451,56034)
#' ts2frame(t)
ts2frame <- function(x, 
                     fps=30, 
                     tstart=0, 
                     tend, 
                     chunked=FALSE, 
                     warn=TRUE)
{
    foa <- 1000 / fps
    if (missing(tend)) tend <- max(x)
    tinterval <- seq(tstart, tend + foa - ((tend-tstart) %% foa), foa)
    f <- findInterval(x, tinterval, rightmost.closed=FALSE, all.inside=FALSE)
    f[x < tstart | x > tend] <- NA
    if (any(is.na(f)) && warn) warning(simpleWarning("Found NAs for some frames"))
    
    if (chunked) {
        return(tinterval[f])
    } else {
        return(f)  
    }
}

frame_expand <- function(onset, offset) {
    if (offset < onset) {
        frames <- NA
    } else {
        frames <- seq(onset, offset, 1)
    }
    return(as.integer(frames))
}

check_opf_data <- function(folder=getOption("datavyur.folder"))
{
    folder <- normalizePath(folder, winslash = "/", mustWork = TRUE)
    filepaths <- list.files(folder, full.names=TRUE, pattern="\\.csv$")
    static_names <- c("file", "column")
    out_list <- lapply(filepaths, function(x) {
        DT <- suppressWarnings(
            data.table::fread(x, 
                              stringsAsFactors=FALSE, 
                              verbose=FALSE, 
                              showProgress=FALSE)
        )
        all_names <- names(DT)
        args_in_col <- all_names[!all_names %in% static_names]
        if (all(static_names %in% all_names)) {
            d_file <- DT[, unique(file)]
            c_type <- DT[, unique(column)]
            dat <- data.table::data.table(
                args=args_in_col,
                classes = sapply(DT[, args_in_col, with=FALSE], typeof),
                file=d_file,
                column=c_type,
                local=x
            )
            return(dat)
        } else {
            return(NULL)  
        }
    })
    dat <- do.call(rbind, out_list)
    data.table::setkey(dat)
    dat <- unique(dat)
    data.table::setcolorder(dat, c("file", "column", "args", "classes", "local"))
    
    return(dat)
}

opf_and_col_selector <- function(all.opf=TRUE, 
                                 all.cols=TRUE, 
                                 folder=getOption("datavyur.folder"))
{
    fdat <- check_opf_data(folder=folder)
    
    # colClasses needs to be list
    est_classes <- fdat[, .N, by=list(column, args, classes)][order(args, N, classes), ]
    est_classes <- est_classes[, .(classes=classes[which.max(N)]), by=list(column, args)]
    est_classes[classes=="logical", classes := "character"]
    
    fdat[, classes := NULL]
    fdat <- merge(fdat, est_classes, by=c("column", "args"), all=TRUE)
    
    if (is.logical(all.opf) && isTRUE(all.opf)) {
        fnames <- unique(fdat$file)
        if (length(fnames) == 0) {
            stop(simpleError("Could not find any files from all.opf input"))
        }
    } else if (is.character(all.opf)) {
        fnames <- unique(fdat[file %in% all.opf, file])
        if (length(fnames) != length(all.opf)) {
            errm <- paste0(c("Could not find files: ", 
                             paste0(all.opf[!all.opf %in% fnames], 
                                    collapse = ", ")), 
                           collapse = " ")
            stop(simpleError(errm))
        }
    } else {
        fErr <- paste0("Set all.opf to TRUE or use a character vector",
                       " of opf file names. You can find names of files", 
                       " from the exported .csv files using the script", 
                       " datavyu2csv.rb")
        stop(simpleError(fErr))
    }
    
    if (is.logical(all.cols) && isTRUE(all.cols)) {
        cnames <- unique(fdat$column)
        if (length(cnames) == 0) {
            stop(simpleError("Could not find `column` in .csv file"))
        }
    } else if (is.character(all.cols)) {
        cnames <- unique(fdat[column %in% all.cols, column])
        if (length(cnames) != length(all.cols)) {
            errm <- paste0(c("Could not find columns: ", 
                             paste0(all.cols[!all.cols %in% cnames], collapse = ", ")), 
                           collapse = " ")
            stop(simpleError(errm))
        }
    } else {
        stop(simpleError("Set all.cols to TRUE or use a character vector of column names exactly as in the opf file"))
    }
    
    fdat <- fdat[file %in% fnames & column %in% cnames, ]
    
    return(fdat)
}

# main routine for temporal, ordinal alignment
align_routine <- function(ordinal,
                          all.opf=TRUE, 
                          all.cols=TRUE, 
                          folder=getOption("datavyur.folder"), 
                          fps=30,
                          colClasses,
                          ...) 
{
    if (ordinal) {
        id_cols <- c("file", "ordinal")
    } else {
        id_cols <- c("file", "frame_number")
    }
    
    # get list of opf files, columns, args, locations
    message("Searching through .csv files for valid .opf data...")
    fdat <- opf_and_col_selector(all.opf = all.opf, 
                                 all.cols = all.cols, 
                                 folder = folder)
    
    # classes for each argument, add ordinal
    est_classes <- unique(fdat[, c("column", "args", "classes"), with=FALSE])
    est_classes[, both := paste0(column, ".", args)]
    
    # overwrite classes if specified
    if (!missing(colClasses) && class(colClasses) == "list") {
        class_names <- names(colClasses)
        for (i in 1:length(colClasses)) {
            est_classes[both %in% colClasses[[i]], classes := class_names[i]]
        }
    }
    
    message("Importing all located Datavyu data into R...")
    
    opf_list <- lapply(unique(fdat$file), function(opf) {
        # DEBUG: opf <- fdat$file[1]
        
        # columns to find in current file
        col_names <- fdat[file==opf, unique(column)]
        
        # cycle through each column and import data
        to_merge <- lapply(col_names, function(clm) {
            # DEBUG: clm <- fdat[file==opf, unique(column)][1]
            
            # path to column .csv for specific .opf file
            fpath <- fdat[file==opf & column==clm, unique(local)]
            
            # import .csv
            DT <- align_import(fpath, clm, est_classes, ...)
            
            if (!ordinal) {
                # expand time to frame counts
                DT <- reshape_by_frame(DT, fps)
            }
            
            # add column prefix to argument names
            DT <- append_colname(DT, clm, id_cols)
            
            # get rid of duplicates (possibly due to same files in folder)
            DT <- unique(DT)
            
            return(data.table::copy(DT))
        })
        
        # begin file merge
        if (length(to_merge) > 1) {
            merged <- multi_merge(to_merge, 
                                  by = id_cols, 
                                  all = TRUE, 
                                  allow.cartesian = TRUE)
        } else {
            merged <- to_merge[[1]]
        }
        
        # set key for larger merge later
        data.table::setkey(merged)
        merged_opf <- data.table::copy(unique(merged))
        
        return(merged_opf)
    })
    
    message("Merging all .opf files...")
    
    # some files may not have all the necessary arguments
    # add them if necessary
    if (ordinal) { # ordinal used as id_col
        est_classes <- est_classes[args !=  "ordinal", ]
    }
    opf_list <- add_columns(opf_list, est_classes)
    
    # names of columns for all list items
    all_names <- sort(unique(unlist(lapply(opf_list, function(i) names(i)))))
    
    # begin merging all files into one large dataset
    opf_merged <- multi_merge(opf_list, by=all_names, all=TRUE)
    
    # some cleanup
    opf_merged <- opf_merged[order(get(id_cols)), ]
    data.table::setkey(opf_merged)
    opf_merged <- unique(opf_merged)
    
    rowNAs <- apply(opf_merged[, !names(opf_merged) %in% id_cols, 
                               with=FALSE], 1, function(i) {
                                   all(is.na(i))  
                               })
    
    opf_merged <- opf_merged[rowNAs==FALSE, ]
    
    new_order <- c(id_cols, sort(all_names[!all_names %in% id_cols], decreasing=TRUE))
    data.table::setcolorder(opf_merged, new_order)
    
    message("Merge successful!")

    return(as.data.frame(opf_merged))
}

# import datavyur .csv file, check classes and args
align_import <- function(fpath, cname, est_classes, ...) {
    DT <- suppressWarnings(
        data.table::fread(fpath, 
                          stringsAsFactors=FALSE, 
                          verbose=FALSE, 
                          showProgress=FALSE, 
                          colClasses = c(file="character",
                                         column="character",
                                         onset="integer",
                                         offset="integer",
                                         ordinal="integer"), ...
        ))
    
    # remove unecessary column id
    DT[, column := NULL]
    
    # check existing columns and args
    current_cols <- est_classes[column == cname, ]
    need_add <- current_cols[!args %in% names(DT), .(args, classes)]
    
    # add columns if missing
    if (nrow(need_add) > 0) {
        for (i in 1:nrow(need_add)) {
            DT[, eval(need_add[i, args]) := NA]
        }
    }
    
    # overwrite classes from estimated classes
    check_args <- current_cols[, args]
    check_class <- current_cols[, classes]
    for (i in 1:length(check_args)) {
        if (typeof(DT[[check_args[i]]]) != check_class[i]) {
            suppressWarnings(
                class(DT[[check_args[i]]]) <- check_class[i]
            )
        }
    }
    return(DT)
}

# used with temporal alignment
reshape_by_frame <- function(DT, fps) {
    
    DT <- data.table::copy(DT)
    
    # convert timestamps to frame counts
    DT[, `:=`(onset.f=ts2frame(onset, fps=fps, warn=FALSE), 
              offset.f=ts2frame(offset, fps=fps, warn=FALSE))]
    
    # remove bad
    DT <- DT[!(is.na(onset.f) | is.na(offset.f)), ]
    
    # frame expansion
    DT <- DT[, .(frame_number=as.integer(frame_expand(onset.f, offset.f))), 
             by=names(DT)]
    
    DT[, `:=` (onset.f=NULL, offset.f=NULL)]
    
    return(DT)
}

# add column.args suffixes
append_colname <- function(DT, clm, except) {
    new_suffixes <- names(DT)[!names(DT) %in% except]
    data.table::setnames(DT, new_suffixes, paste0(clm, ".", new_suffixes))
    return(DT)
}

# add whole columns if missing
add_columns <- function(opf_list, est_classes) {
    necessary_names <- est_classes$both
    necessary_classes <- est_classes$classes
    
    opf_list <- lapply(opf_list, function(i) {
        lnames <- names(i)
        need_idx <- !necessary_names %in% lnames
        if (any(need_idx)) {
            new_names <- necessary_names[need_idx]
            new_cls <- necessary_classes[need_idx]
            for (j in 1:length(new_names)) {
                i[[new_names[j]]] <- NA
                class(i[[new_names[j]]]) <- new_cls[j]
            }
        }
        return(i)
    })
    
    return(opf_list)
}

return_duplicated <- function(DT) {
    setkey(DT)
    d1 <- which(duplicated(DT, fromLast = TRUE))
    d2 <- which(duplicated(DT, fromLast = FALSE))
    return(DT[unique(d1, d2), ])
}
