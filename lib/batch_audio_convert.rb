################################################################################
# BatchAudioConvert
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require "batch_audio_convert/version"


module BatchAudioConvert

#  include FileUtils
#  include AudioUtils


  # Determine files to process
  def build_file_list
    display 'Finding files...'
    file_list = []
    app_config[:source].each do |entry|
      if File.directory?(entry)
        populate_list_of_files_from_directory(file_list, entry) 
        next
      end
      if File.file?(entry)
        populate_list_of_files_from_file(file_list, entry) 
        next
      end
      log.warn "\"#{entry}\" is neither a directory nor a regular file. Ignored..."
    end
    log.debug(file_list)
    file_list
  end

  # Generate destination directory
  def process_files(file_list)
    display 'Processing files...'
    file_list.each do |file|
      analysis_result = analyze_file file
      self.send analysis_result[:method_name], file, analysis_result[:destination_file]
    end
  end

end
