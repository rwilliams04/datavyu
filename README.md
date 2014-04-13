Scripts
=======

scripts to be used with the www.datavyu.org software

## general

General purpose scripts to be used for any datavyu file.

### `datavyu2csv.rb`

Creates a `.csv` file that contains all the cells found for a particular column, and converts any empty arguments to empty spaces. Multiple files will be created for each column. It doesn't do any other processing, such as handling nested columns. Mostly used for batch importing [datavyu](http://www.datavyu.org/user-guide/api.html) files into other software such as R, Python, or MATLAB (or working in Excel).

1. Make sure the `.opf` files you want to extract are all in one folder.
2. Run the script through datavyu
3. Select the folder containing the `.opf` files
4. A new subfolder will be made that outputs a `.csv` file for each column and each `.opf` file found in your root folder. 
