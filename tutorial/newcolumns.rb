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