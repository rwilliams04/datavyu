# Load the datavyur library to use the functions below
# See tutorial on function usage
library(datavyur)

# Find the full path to where the .csv files have been saved
# Replace "data" with the found path
data_path <- normalizePath("data")

# Set the package option datavyur.folder
options(datavyur.folder=data_path)


# Viewing Columns ---------------------------------------------------------

# view names and list of files
datavyu_col_search(data_path)

# view names only
datavyu_col_search(unq=TRUE, cnames="column")


# Importing Columns -------------------------------------------------------

# load columns as separate data frames
child_hands <- import_column("childhands") # or import_column("childhands", data_path)
parent_hands <- import_column("parenthands")

# Merging Nested Columns --------------------------------------------------

z1 <- merge_nested(child_hands, parent_hands)
z2 <- merge_nested(child_hands, parent_hands, ids=c(".higher", ".lower"), keepall=FALSE)

# R data to datavyu -------------------------------------------------------

# provide a list of data to convert
r2datavyu(list(chands=child_hands, phands=parent_hands), "myexport")

# R to spreadsheet --------------------------------------------------------

write.csv(z2, file="merged_data.csv", row.names=FALSE, na="")


# Fake Data Example -------------------------------------------------------

x <- as.data.frame(datavyu_dat(n1=25, n2=2)[[1]])
y <- datavyu_dat(n1=2, n2=100)[[2]]

# Time Conversion ---------------------------------------------------------

# print milliseconds to time string
ms2time(x$onset)

# save time string back into data frame
x$onset_str <- ms2time(x$onset)
x$offset_str <- ms2time(x$offset)


