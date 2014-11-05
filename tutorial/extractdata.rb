### Don't worry about these functions below. Skip to START HERE section.
### These functions are just helper functions to make things a little easier for you.

def makefile(pathname)
    desktopPointer = File.expand_path("~/Desktop/#{pathname}.csv")
    outfile = File.new(desktopPointer, 'w')
    return(outfile)
end

def writenames(outfile, colnames)
    outfile.write("#{colnames.join(',')}")
end

def writedata(outfile, data)
    outfile.write("\n#{data.join(',')}")
end

#####################
### START HERE ! #####
#####################

require 'Datavyu_API.rb'
begin

    # Start making the file you want to create
    #     all you need to input is the name of the file
    toMyFile = makefile("ryu-6mo-holding")

    # get information from the Datavyu column `trial`
    #     store this into the ruby variable called trial
    trial = getColumn("trial")

    # do the same fo the `holding` column
    holding = getColumn("holding")

    # These are the names that will go at the top of each .csv file. 
    #    it is up to you to make sure they match up correctly with the data
    #    this means same number of columns as data and same order
    # Notice the brackets, which means this is an array of strings
    # Each items is enclosed in quotes
    # Each item is separated by a comma expected for the last
    csvNames = [
        "trialCell",
        "trialOnset",
        "trialOffset",
        "holdCell",
        "holdOnset",
        "holdOffset",
        "word",
        "toy",
        "holdDuration"
    ]

    # actually write the names you made to the file you started using the following function
    # the function `writenames` takes on 2 arguments
    #      arg1 = the variable name of the file you started
    #      arg2 = the column names you made as an array of strings
    writenames(toMyFile, csvNames)

    # start going through each cell in the `trial` column
    #     call each cell `thisTrialCell`
    trial.cells.each do | thisTrialCell |

        # start going through each cell in the `holding` column
        #     call each cell `thisHoldCell`
        holding.cells.each do | thisHoldCell |

            # make sure the current holding cell is within the current trial cell
            #     this is based on onset/offset times
            #     if this is true, then collect data and write it to the file
            if thisHoldCell.is_within(thisTrialCell)

                # collect the data from cells
                # the stuff before the `.` is the current cell name
                # the stuff after the `.` is the data from the current cell
                # ordinal, onset, offset always exists, anything else is custom
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

                # write the data as a single line in your output file
                writedata(toMyFile, lineData)

            end # end `if` loop
        end # end `holding` loop  
    end # end `trial` loop
end # `end` begin statement
