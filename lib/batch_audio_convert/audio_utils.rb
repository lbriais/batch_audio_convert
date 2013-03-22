################################################################################
# BatchAudioConvert
#
# Copyright (c) 2013 L.Briais under MIT license
# http://opensource.org/licenses/MIT
################################################################################

require 'tempfile'
require 'taglib'

module AudioUtils

  TAGS = [:title, :artist, :comment, :genre, :album, :track, :year]

  OGG_ENC_CMD = 'oggenc -q##OGGQUALITY## -o "##OGGFILE##" "##WAVFILE##"'
  FLAC_DEC_CMD = 'flac -d -f -o "##WAVFILE##" "##FLACFILE##"'

  def flac_to_ogg(origin, destination)
    logger.info "Transforming \"#{origin}\" into \"#{destination}\"."
    return if @application_config[:simulate]
    unless should_process_file? destination
      logger.info " - File exists. Skipping transformation..."
      return
    end
    verify_destination_folder(destination)
    begin
      temp_file = Tempfile.new(self.class.name)
      temp_file.close
      tags = flac_tags(origin)
      run_command build_flac_cmd(origin, temp_file.path)
      run_command build_ogg_cmd(temp_file.path, destination)
      set_ogg_tags destination, tags
      logger.info " - Done"
    ensure
      temp_file.unlink
    end
  end

  def flac_tags(file)
    logger.info " - Reading FLAC tags"
    tags = {}
    TagLib::FileRef.open(file) do |fileref|
      tag = fileref.tag
      TAGS.each do |tagname|
        tags[tagname] = tag.send(tagname)
      end
    end
    log.debug tags.inspect
    tags
  end

  def set_ogg_tags(file, tags)
    logger.info " - Writing OGG tags"
    TagLib::FileRef.open(file) do |fileref|
      tag = fileref.tag
      tags.each do |tagname, value|
        tag.send(tagname.to_s + "=", tags[tagname])
      end
      fileref.save
    end
  end

  def build_flac_cmd(origin, destination)
    cmd = FLAC_DEC_CMD.gsub '##WAVFILE##', destination
    cmd.gsub '##FLACFILE##', origin
  end

  def build_ogg_cmd(origin, destination)
    cmd = OGG_ENC_CMD.gsub '##WAVFILE##', origin
    cmd.gsub! '##OGGFILE##', destination
    cmd.gsub '##OGGQUALITY##', @application_config[:'ogg-quality'].to_s
  end

end
