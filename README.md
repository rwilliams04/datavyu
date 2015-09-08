Cognitive Development Lab - Datavyu Materials
=======

This repository contains a basic tutorial for getting started with Datavyu scripting and also the R `datavyur` package to be used in conjunction with the general Ruby scripts.

# GitHub Folder Contents

## general

General scripts to be used with the www.datavyu.org software. These are designed not to be specific to any particular type of project.

### `datavyu2csv.rb`

Creates a `.csv` file that contains all the cells found for a particular column, and converts any empty arguments to empty spaces. Multiple files will be created for each column. It doesn't do any other processing, such as handling nested columns. Mostly used for batch importing [datavyu](datavyu.org/user-guide/api.html) files into other software such as R, Python, or MATLAB (or working in Excel).

1. Get the script `datavyu2csv.rb` from the `general` folder.
2. Make sure the `.opf` files you want to convert to `.csv` are all in one folder on your computer somewhere.
3. Run the script `datavyu2csv.rb` through datavyu
3. When prompted, select the folder containing the `.opf` files
4. A new subfolder will be made that outputs a `.csv` file for each column and each `.opf` file found in your selected folder.

### `csv2opf.rb`

This file takes a properly formatted `.csv` file that Datavyu understands and converts it into a `.opf` file that you can open within Datavyu.

The script is to be run within Datavyu.

### `findopf.py`

A basic python script that will search for `.opf` files at the root of some location and copy them over to another location. Requires that your python installation has `Tk`.

## tutorial

Cogdevlab scripting tutorial located in the file `tutorial/datavyu_tutorial.md`, aimed towards beginners. The tutorial is not very detailed and focuses mostly on quickly making several columns with multiple `<codes>`, and also some basics on extracting data from Datavyu using Ruby. A more detailed guide can be found on the datavyu.org website here:

[http://datavyu.org/user-guide/index.html](http://datavyu.org/user-guide/index.html)

## datavyur

This is an R package to help with getting data from Datavyu and into R and back into Datavyu again. It also provides useful functions to manage Datavyu data in R.

### How to install

#### Windows dependencies

If you're on Windows, you might need to install rtools first before you can use the `devtools` package in step 1. To install, see here:

[http://cran.r-project.org/bin/windows/Rtools/](http://cran.r-project.org/bin/windows/Rtools/)

#### Step 1.

First, open RStudio and then install the package `devtools` from CRAN. This is so you can get the package from the internet (GitHub) and build it.

```r
install.packages("devtools")
```

#### Step 2.

Once the `devtools` package is installed, you'll use the `install_github` function from the package to download and install this `datavyur` package from this GitHub repository. Copy all the code below and paste it into the console to install the package along with all the other required packages:

```r
devtools::install_github("iamamutt/datavyu/datavyur", build_vignettes = TRUE, dependencies = TRUE)
```

#### Step 3.

The package should now be installed. Load the package as you normally would any other package (see below). Repeat Step 2 if there are updates to the `datavyur` package. You should now see it in your packages tab within RStudio (after clicking refresh).

```r
library(datavyur)
```

Once the `datavyur` package has been installed, view the tutorial to get started on using the functions from the package. In R, run the following code to see the tutorial:

```r
vignette(topic = "tutorial", package = "datavyur")
```

