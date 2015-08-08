#######
# If a file was exported as a csv, this script will convert it back to .opf
# The script converts all .csv in a specified directory
#####

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
    fc.set_dialog_title("Select a folder containing .csv files")
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

  # change current directory to rootFolder then search for .csv files
  Dir.chdir(rootFolder)
  puts "\nTraversing through '#{rootFolder}' for .csv files..."
  csvFiles = Dir.glob("**/*.csv").sort

  # make output directory
  outputDir = "datavyu_opf_output_" + Time.now.strftime("%m-%d-%Y_%H-%M")
  puts "\nCreating new directory '#{outputDir}'"
  Dir.mkdir(outputDir)

  puts "\n=================BEGIN SAVING================="

  csvFiles.each do |csvFile|

    fullFile = File.join(Dir.pwd, csvFile)
    $db, $pj = load_db(fullFile)

    opfName = File.join(Dir.pwd, outputDir, File.basename(csvFile)[/.*(?=\..+$)/] + ".opf")
    save_db(opfName)

  end

  puts "\n=================END SAVING================="

end

