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
  MP3_ENC_CMD = 'lame -h -b ##MP3QUALITY## "##WAVFILE##" "##MP3FILE##"'

  def flac_to_ogg (origin, destination)
    flac_to origin, destination do |temp_file, tags|
      run_command build_ogg_cmd(temp_file.path, destination)
      set_ogg_tags destination, tags
    end
  end

  def flac_to_mp3 (origin, destination)
    flac_to origin, destination do |temp_file, tags|
      run_command build_mp3_cmd(temp_file.path, destination)
      set_mp3_tags destination, tags
    end
  end

  # flac to whatever block statement you provide
  # In two steps:
  #  1. flac to wav
  #  2. wav to whatever
  def flac_to (origin, destination)
    puts_and_logs "Transforming \"#{origin}\" into \"#{destination}\"."
    return if app_config[:simulate]
    unless should_process_file? destination
      puts_and_logs " - File exists. Skipping transformation..."
      return
    end
    verify_destination_folder(destination)
    begin
      temp_file = Tempfile.new(self.class.name)
      temp_file.close
      tags = flac_tags(origin)
      run_command build_flac_cmd(origin, temp_file.path)
      yield temp_file, tags
      puts_and_logs " - Done"
    ensure
      temp_file.unlink
    end
  end

  def flac_tags(file)
    puts_and_logs " - Reading FLAC tags"
    tags = {}
    TagLib::FileRef.open(file) do |fileref|
      tag = fileref.tag
      TAGS.each do |tagname|
        tags[tagname] = tag.send(tagname)
      end
    end
    logger.debug tags.inspect
    tags
  end

  def set_ogg_tags(file, tags)
    puts_and_logs " - Writing OGG tags"
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
    app_config[:'ogg-quality'] = 6 if app_config[:'ogg-quality'].nil?

    cmd = OGG_ENC_CMD.gsub '##WAVFILE##', origin
    cmd.gsub! '##OGGFILE##', destination
    cmd.gsub '##OGGQUALITY##', app_config[:'ogg-quality'].to_s
  end

  def set_mp3_tags(file, tags)
    puts_and_logs " - Writing MP3 tags"
    TagLib::MPEG::File.open(file) do |fileref|
      tag = fileref.id3v2_tag(true)
      tags.each do |tagname, value|
        tag.send(tagname.to_s + "=", tags[tagname])
      end
      fileref.save
    end
  end  

  def build_mp3_cmd(origin, destination)
    app_config[:'mp3-quality'] = 256 if app_config[:'mp3-quality'].nil?

    cmd = MP3_ENC_CMD.gsub '##WAVFILE##', origin
    cmd.gsub! '##MP3FILE##', destination
    cmd.gsub '##MP3QUALITY##', app_config[:'mp3-quality'].to_s
  end


end
