################################################################################
# BatchAudioConvert
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'find'

IMAGE_TYPE_FILES = ["jpg", "JPG", "jpeg", "JPEG"]

module FileUtils

  # Adds all files in a directory structure
  def populate_list_of_files_from_directory(file_list, entry)
    logger.debug "\"#{entry}\" is a directory. Processing..."
    Find.find(entry) do |file|
      next unless is_directory_to_process?(File.dirname file)
      file_list << file if File.file?(file)
    end

  end

  # Adds one file + its associated images if any
  def populate_list_of_files_from_file(file_list, entry)
    logger.debug "\"#{entry}\" is a file. Processing..."
    file_list << entry
    # Find images if any
    Find.find(File.dirname(entry)) do |file|
      file_list << file if (File.file?(file) && is_image?(file))
    end
  end

  def is_image?(file)
    IMAGE_TYPE_FILES.each do |img_ext|
      return true if file =~ /\.#{img_ext}$/
    end
    false
  end

  # Define destination name and transormation method to apply for a file.
  def analyze_file(file)
    method_name = :copy
    destination_file = String.new(file)
    app_config[:extensions].each do |origin_ext, destination_ext|
      if file =~ /\.#{origin_ext}$/i
        destination_file.gsub! /\.#{origin_ext}$/i, ".#{destination_ext}"
        method_name = origin_ext + '_to_' + destination_ext
        break
      end
    end
    replace_folder_in_destination! destination_file
    return {:method_name => method_name, :destination_file => destination_file}
  end

  def copy(origin, destination)
    logger.info "Copying \"#{origin}\" to \"#{destination}\"."
    return if app_config[:simulate]
    unless should_process_file? destination
       logger.info " - File exists. Skipping copy..."
      return
    end
    verify_destination_folder(destination)
    begin
      FileUtils.copy_file origin, destination
    rescue Exception => e
      logger.error "An error occurred during the copy - " + e.message
    end
  end

  def should_process_file?(file)
    return true if app_config[:force]
    return !File.exists?(file)
  end

  def replace_folder_in_destination!(file)
    file.gsub! /^(?<base>.*\/)(?<full_file>[^\/]+\/[^\/]+\/[^\/]+)$/, "#{app_config[:destination]}/\\k<full_file>"
  end

  def verify_destination_folder(file)
    dir = File.dirname file
    unless File.directory? dir
      logger.info "Creating directory \"#{dir}\"..."
      FileUtils.mkdir_p dir
    end
  end

  def is_directory_to_process?(dir)
    app_config[:extensions].keys.each do |filetype|
      Dir.foreach dir do |filename|
        return true if filename =~ /\.#{filetype}$/i
      end
    end
    logger.warn "Directory \"#{dir}\" discarded, as not containing files to convert..."
    false
  end

end
