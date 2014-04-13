datavyu
=======

scripts used with the www.datavyu.org software

## `datavyu2csv.rb`

1. Make sure the `.opf` files you want to extract are all in one folder.
2. Run the script through datavyu
3. Select the folder containing the `.opf` files
4. A new subfolder will be made that outputs a `.csv` file for each column and each `.opf` file found in your root folder. The `.csv` file will contain all the cells found for a particular column, and convert empty arguments to empty spaces.