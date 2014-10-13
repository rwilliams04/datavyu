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

1. Open up your text editor and save the file as `tutorial.rb`. You can save it to the desktop or wherever you want.

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
Running Script: tutorial.rb on project: (untitled)
*************************
Hello Lab

Script completed successfully.
```

You have now written your first script! Now let's do something more useful.

# Creating columns for coding

Before you start to make the columns that need to be coded you should plan ahead. A coding manual will help you think these things through, or making the manual while you code some data to experiment with what you need.

- What is it that I want coded, exactly?
    - Outline all the different behaviors you are interested in. These can potentially be different columns.
- How much information per cell do I need?
    - For each cell (duration of time), what will be my arguments? More on arguments later.
- What will all my codes be?
    - Know which codes you'll be using ahead of time (e.g., a code for each type of toy the parent is using)


# API Reference

Look here for a list of examples of the types of methods (functions) you can use. You should check this often since the functions tend to change periodically because the program is still in beta.

[http://datavyu.org/user-guide/api/reference.html](http://datavyu.org/user-guide/api/reference.html)



