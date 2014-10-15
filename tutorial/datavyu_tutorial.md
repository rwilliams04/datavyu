% Datavyu Scripting
% Joseph Burling
% October 17th, 2014

--------------------

# Getting Started

You're going to have to learn some Ruby. It won't be that hard, you won't need to know that much, just enough to write some basic scripts.

## Installing Datavyu

Make sure you have the latest version of Datavyu already installed. You can get it from their website.

[http://datavyu.org/download.html](http://datavyu.org/download.html)

## Installing a text editor

You can use any text editor you want to write your code (please don't use Word). I suggest this one which is pretty basic.

[http://www.sublimetext.com/3](http://www.sublimetext.com/3)

# Running scripts

If you open up Datavyu then go to `Script` then `Run Script`, you'll be asked to locate a file that contains the code that needs to be run. It's up to you to write the code that will tell the program what to do, which is typically importing columns or exporting data from already coded columns.

Let's create a simple script that doesn't really do anything important.

1. Open up your text editor and save the file as `newcolumns.rb`. You can save it to the desktop or wherever you want.

2. Make sure the following line is at the top of your script. This line loads all the code already written by the Datavyu people to allow you to talk to their program using the Ruby language.


```{.ruby .numberLines}
require 'Datavyu_API.rb'
```

3. Next you'll need to create a section that has all the code you want to run through Datavyu. On the next ling copy the following code.

```{.ruby .numberLines}
begin
    # My code goes here in between these begin and end statements
    # Anything with a hash/pound/number sign before it won't be read by the program
    #    These are referred to as comments. You should get into the habit of making them
    #    so that other people (and your future self) can identify what you wrote.
end
```

4. Next, write a line of code that just prints a message to the console (the little thing that runs the scripts and outputs errors for you). You'll use the `puts` function which tries to print some output. This is useful for debugging. Your code should look like this below.

```{.ruby .numberLines}
require 'Datavyu_API.rb'
begin
    # My code goes here in between these begin and end statements
    # Anything with a hash/pound/number sign before it won't be read by the program
    #    These are referred to as comments. You should get into the habit of making them
    #    so that other people (and your future self) can identify what you wrote.

    # print text to console
    puts "Hello Lab"
end
```

5. Save the file and you can now run the script from within Datavyu. You should see the following output in your Scripting Console window.

```
*************************
Running Script: newcolumns.rb on project: (untitled)
*************************
Hello Lab

Script completed successfully.
```

You have now written your first script! Now let's do something more useful.

# Creating columns for coding

Before you start to make the columns that need to be coded you should plan ahead. A coding manual will help you think these things through, or even making the manual while you code some data to experiment with what you might need.

- What is it that I want coded, exactly?
    - Outline all the different behaviors you are interested in. These can potentially be different columns.
- How much information per cell do I need?
    - For each cell (duration of time), what will be my arguments? More on arguments later.
- What will all my codes be?
    - Know which codes you'll be using ahead of time (e.g., a code for each type of toy the parent is using)

Once you know this information you can start making your columns using a script. Note that you can make columns manually from within Datavyu, but I would not recommend this if you are coding multiple participants where each participant has their own file. You would have to make each column manually and make sure they are identical across all files by saving some common template `.opf` file. Often times, this template may be overwritten and altered accidentally, leading to errors when exporting data. Instead you can run a script that will automate this process.

1. The first thing you need to do is figure out what your column name is going to be. 
    - Example: If this column will hold participant information, you may call it `info`. Keep the naming of columns simple, since you may get errors for weird characters in your column name.

2. Next you are going to want to know the arguments that need to be filled in for each cell (these are sometimes called _codes_ in Datavyu).
    - Example: If your column is participant information, then codes/arguments that you might consider are `name`, `age`, `idnumber`, things like that. This is entirely dependent on what you want to accomplish with your column.

3. After you column is generated, actually do some coding. This will get you an idea of what it's like to code for the column you created, and you'll likely find that you need to make some changes to your column arguments or how you may have to split a column into separate columns. Sometimes you may find that you have more columns than you actually need, and you can just add more arguments to a single column to accomplish the same thing.

## createNewColumn

Add the code below to your `newcolumns.rb` file you've already started. Make sure the code is in between the `begin` and `end` statements.

```{.ruby .numberLines}
child_info_container = createNewColumn("info", "name", "agemonths", "id")
```

Let's understand what each section from the line above is doing.

- `child_info_container`
    - This is called a _variable_, and is a symbol for all the information that will be stored somewhere on your computer. In this example it's going to store information about the column you are trying to create. Information will be sent to this variable via the `=` sign.
- `createNewColumn`
    - This is called a function (in Ruby they are called `methods`, but that doesn't matter to you). What this does is compute how the column will be created. This function takes several input arguments (not to be confused with datavyu arguments/codes). Each input is separated by a `,`. The order in which you specify each argument is fixed.
- `("info", "name", "agemonths", "id")`
    - These are the actual input arguments and make up the bulk of what your column will look like.
    - Each input must be enclosed in quotes `"some text"`, which is called a `string`
    - The structure of this function takes arguments in this form:

```{.ruby .numberLines}
ruby_variable = createNewColumn("column name", "arg 1 name", "arg 2 name", ...)
```

## setColumn

Now add the next line of code to complete your single column creation. Again, make sure it's in between `begin` and `end`. 

```{.ruby .numberLines}
setColumn(child_info_container)
```

The line above is a different function that takes all the information that was created in your previous line, and then send that info to Datavyu and creates the column. This step is necessary, otherwise the info just lives in Ruby and doesn't reach the Datavyu program.

Let's add another column then run the script to see if it worked. Go ahead and add the rest of the code below, and make sure your file looks similar to this:

```{.ruby .numberLines}
require 'Datavyu_API.rb'
begin
    # My code goes here in between these begin and end statements
    # Anything with a hash/pound/number sign before it won't be read by the program
    #    These are referred to as comments. You should get into the habit of making them
    #    so that other people (and your future self) can identify what you wrote.

    # print text to console
    puts "Hello Lab"

    # create Ruby variable that holds all the information about your column
    child_info_container = createNewColumn("info", "name", "agemonths", "id")

    # use the Ruby variable to set the column within the Datavyu program
    setColumn(child_info_container)

    # Add another column for eye gaze timestamps
    eyegaze_container = createNewColumn("eyegaze", "trial", "direction")
    setColumn(eyegaze_container)
end
```

# Extracting Coded Data

Run the script `fakedata.rb` so that we can generate some data that we'll use as an example for extracting coded data from Datavyu. You should see some data in a `trial` and a `holding` column. These data are nested which means observations happen in the `holding` column that are contained within the `trial` column with no overlap between columns. To see how they are not overlapping, switch the view to `Temporal Alignment` by pressing `CTRL+t` or `CMD + t`.

You can always export the file from within Datavyu, be going to `File > Export File`, but this method doesn't handle nested data very well and also won't do any calculations or processing beforehand. If you're okay with this, then go right ahead. Otherwise, see below on exporting via the scripting console. Once you learn the scripting basics, you can do much more than just export. You can manipulate your data, find durations of time, frequencies of behaviors, etc., from within Ruby without having to do all this by hand in another program such as Excel.

## File pointer

The first thing you have to do is write code that will tell Datavyu where to save your exported data (based on the fake data that is currently loaded). As usual, everything will be in between `begin` and `end` statements, with the API loaded before that. See `extractdata.rb` for the final version of this script. You should probably open that file to see the complete code as we go along.

The function `makefile` (which you'll find at the top of the `extractdata.rb` script), takes a filename and gets ready to save it on the desktop. It returns an object called `toMyFile` that will be used to continually write data to the file you just started.

```{.ruby .numberLines}
    toMyFile = makefile("ryu-6mo-holding")
```

## Get Datavyu column data

the `Datavyu_API.rb` file provides methods to extract data from Datavyu using the function `getColumn`. You must tell it which column you are trying to get (by typing in the name exactly as it appears in Datavyu), and where to save the data (the variable name to the left side of the equals sign).

Below we are collecting data from the `trial` and `holding` columns within Datavyu.

```{.ruby .numberLines}
    trial = getColumn("trial")
    holding = getColumn("holding")
```

## Header names

This step will write names for each column that will be shown in your output file. This step can be skipped if you don't need these names for some reason (e.g., you only have one thing you are exporting), but it is recommended if you have a lot of data to export.

For each type of data you'll need to have a corresponding name. These names are presented as strings, separated by commas, and enclosed in brackets, the assigned to a Ruby variable.

```{.ruby .numberLines}
    csvNames = ["trialCell", "trialOnset", "trialOffset", "holdCell", "holdOnset", "holdOffset", "word", "toy"]
```

Next you have to write these names to your file using the `writenames` function. This function needs to know which file to write to, and which names to use.

```{.ruby .numberLines}
    writenames(toMyFile, csvNames)
```

## Looping through cells

Next we are going to cycle through each `trial` cell, and for each `trial` cell we will then cycle through each `holding` cell. So for example, if there are 8 trials and a total of 30 cells coded for `holding`, then we would do 240 loops in total.

The reason why we are doing this is because for each trial we have to check _all_ the holding cells to see which ones are contained within that specific trial. If they happen to be within the current trial, then print out the data to our file. If not, skip that particular combination of `trial` and `holding` cells and go to the next combination.

```{.ruby .numberLines}
    trial.cells.each do | thisTrialCell |
        holding.cells.each do | thisHoldCell |
            if thisHoldCell.is_within(thisTrialCell)
                lineData = [
                    thisTrialCell.ordinal,
                    thisTrialCell.onset,
                    thisTrialCell.offset,
                    thisHoldCell.ordinal,
                    thisHoldCell.onset,
                    thisHoldCell.offset,
                    thisTrialCell.word,
                    thisHoldCell.toy
                ]
                writedata(toMyFile, lineData)
            end # end `if` loop
        end # end `holding` loop  
    end # end `trial` loop
```

Some explanation of the code:

- `trial.cells.each do | thisTrialCell |`
    - `trial` is the trial data we extracted from earlier
    - `cells` is the portion of the data dealing only with coded data from that column
    - `each` is saying to cycle through each cell from the trial column
    - `do` is saying we are about to do something with each of these cells
    - `| thisTrialCell |` is saying to use `thisTrialCell` as the symbol for the current cell within the trial column. This is what will actually be used within the loop.
- `holding.cells.each do | thisHoldCell |`
    - Same as above except we are doing it for the `holding` column now too
- `if thisHoldCell.is_within(thisTrialCell)`
    - if this current cell from the holding column is within the current cell from the trial column, then...
    - `is_within` is a special function provide by Datavyu to compare timestamps between two cells
-  `lineData = [...]`
    - This is an array that will hold all the values that you choose to extract.
    - The stuff before the `.` is the current cell name
    - The stuff after the `.` is the argument name (`<code>`) from the current cell
    - `ordinal`, `onset`, and `offset` always exists, anything else is custom and must be entered exactly as it is shown in Datavyu.


After the data is collected in `lineData`, then you have to write it to your file using the `writedata` function, which works similarly to the `writenames` function.

```{.ruby .numberLines}
    writedata(toMyFile, lineData)
```


# API Reference

Look here for a list of examples of the types of methods (functions) you can use. You should check this often since the functions tend to change periodically because the program is still in beta.

[http://datavyu.org/user-guide/api/reference.html](http://datavyu.org/user-guide/api/reference.html)



