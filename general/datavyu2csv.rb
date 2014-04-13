require 'Datavyu_API.rb'
require 'rbconfig'
require 'pathname'

begin
  # create a folder chooser function
  def pickFolder
    os = case Config::CONFIG['host_os']
    when /darwin/ then :mac
    when /mswin|mingw/ then :windows
    else :unix
    end
    fc = Java::javax::swing::JFileChooser.new("JRuby panel")
    fc.set_dialog_title("Select a folder containing .opf files")
    fc.set_file_selection_mode(Java::javax::swing::JFileChooser::DIRECTORIES_ONLY)
    if os == :mac
      fc.setCurrentDirectory(java.io.File.new(File.expand_path("~/Desktop")))
    elsif os == :windows
      fc.setCurrentDirectory(java.io.File.new(File.expand_path("~/Desktop")))
    else
      fc.setCurrentDirectory(java.io.File.new("/usr/bin"))
    end
    success = fc.show_open_dialog(javax.swing.JPanel.new)
    if success == Java::javax::swing::JFileChooser::APPROVE_OPTION
      return Pathname.new(fc.get_selected_file.get_absolute_path)
    else
      nil
    end
  end

  # get path of chosen folder
  rootFolder = pickFolder()
  # change current directory to rootFolder then search for .opf files
  Dir.chdir(rootFolder)
  puts "\nTraversing through '#{rootFolder}' for .opf files..."
  opfFiles = Dir.glob("**/*.opf").sort
  # make output directory
  outputDir = "datavyu_output_" + Time.now.strftime("%m-%d-%Y_%H-%M")
  puts "\nCreating new directory '#{outputDir}'"
  Dir.mkdir(outputDir)

  puts "\n\n=================BEGIN EXTRACTION================="

  # iterate through each .opf file
  opfFiles.each do |opfFile|
    filebasename = opfFile[/.*(?=\..+$)/]
    puts "\n\nLoading file... '#{filebasename}.opf'"

    begin
      # load datavyu file
      $db,$pj = load_db(File.join(Dir.pwd, opfFile))
      # get list of column names
      columnList = getColumnList()
      if columnList.nil?
        puts "\nFile is empty!"
      else

        # start reading in columns one-by-one
        columnList.each do |col_str|
          puts "\n..Found column: #{col_str}"
          col = getColumn("#{col_str}")
          firstCell = col.cells[0] # used below to find argument names
          if firstCell.nil?
            puts "\n==No coded cells found! Skipping column==\n"
          else
            # get names of custom arguments
            args = firstCell.arglist
            puts "\n...Found arguments: #{args.join(', ')}"
            # create output file
            newFileStr = "#{col_str}__#{filebasename}.csv"
            csv_out = File.new(File.join(outputDir, newFileStr), "wb")
            csv_out.write("#{['file', 'column', 'ordinal', 'onset', 'offset', args].join(',')}")
            puts "\n....Writing cells to file: '#{newFileStr}'"

            # iterate through each of the cells from the current column
            col.cells.each do |cell|
              cell_codes = printCellCodes(cell)
              # replaces <arg> with a blank space
              # assumes first 3 args are ord, on, off and the rest are custom
              arg_num = 3
              cell_codes.drop(3).each do |blnk|
                if blnk == "<#{args[arg_num-3]}>"
                  cell_codes[arg_num] = ""
                end
                arg_num = arg_num+1
              end
              # write cell contents
              csv_out.write("\n#{[filebasename, col_str, cell_codes].join(',')}")
            end
            puts "\n.....done."
          end
          csv_out.close
        end
      end
    rescue
      puts"\n==Error with file.==\n"
    end
  end
  puts "\n=================END EXTRACTION================="
end
