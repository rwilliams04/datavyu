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

Run the script `fakedata.rb` so that we can generate some data that we'll use as an example for extracting coded data from Datavyu.


# API Reference

Look here for a list of examples of the types of methods (functions) you can use. You should check this often since the functions tend to change periodically because the program is still in beta.

[http://datavyu.org/user-guide/api/reference.html](http://datavyu.org/user-guide/api/reference.html)



