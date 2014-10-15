Cognitive Development Lab - Datavyu Material
=======

## general

General scripts to be used with the www.datavyu.org software. These are designed not to be specific to any particular type of project.

### `datavyu2csv.rb`

Creates a `.csv` file that contains all the cells found for a particular column, and converts any empty arguments to empty spaces. Multiple files will be created for each column. It doesn't do any other processing, such as handling nested columns. Mostly used for batch importing [datavyu](datavyu.org/user-guide/api.html) files into other software such as R, Python, or MATLAB (or working in Excel).

1. Get the script `datavyu2csv.rb` from the `general` folder.
2. Make sure the `.opf` files you want to convert to `.csv` are all in one folder on your computer somewhere.
3. Run the script `datavyu2csv.rb` through datavyu
3. When prompted, select the folder containing the `.opf` files
4. A new subfolder will be made that outputs a `.csv` file for each column and each `.opf` file found in your selected folder. 

## tutorial

Scripting tutorial for the lab catered towards beginners. The tutorial is not very detailed and focuses mostly on quickly making several columns with multiple `<codes>` and also some basics on extracting data from Datavyu using Ruby.