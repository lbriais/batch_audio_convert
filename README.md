# BatchAudioConvert

**The goal of this [gem][bacg] is to batch transform audio files from one format to another.**

It basically takes the assumption that the audio library is already correctly organized in the standard two levels directory structure that could be:

* artist/album
* various/compil

Nevertheless the files or directories specified could be located anywhere. Only the structure is assumed.

It actually replicates the original structure and copies all the tags (handled by [taglib](http://taglib.github.com/)) to the generated audio files.


It currently supports FLAC to OGG transformation.

## Installation

### System dependencies

This gem has some system dependencies.

     sudo apt-get install libtag1-dev vorbis-tools flac


It could probably work under Windows/Cygwin with some tweaking, but never tried...
It is based on the [easy_app_helper Gem][eahg]([sources][eahs]), but it will installed automatically by the gem/bundle mechanism.

### Gem installation

Add this line to your application's Gemfile:

    gem 'batch_audio_convert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install batch_audio_convert

### Minimum configuration

#### Where to define your config file and how to name it.

This is done through a [YAML](http://www.yaml.org/YAML_for_ruby.html) config file thanks to [EasyAppHelper::Config module][eahcm] of the [EasyAppHelper gem][eahg].

You should name your configuration file `batch_audio_convert.conf`

See the constants defined in [EasyAppHelper::Config::Instanciator module][eahcim] to know which extensions could be used and **where to place you config files**. Of course as this script is based on [EasyAppHelper][eahg], you still have the possiblity to directly pass a config file from the command line using the `--config-file` command line option.

To be clear, the easiest place to create your config should be:

    ~/.config/batch_audio_convert.conf


#### Config file content

```yaml
# Minimum configuration for batch_audio_convert

# Hash defining possible transformations.
:extensions:
  flac: ogg

# Quality of the generated ogg files.
:ogg-quality: 6

# An array of sources to process. Non valid entries are skipped.
:source:
  - list of files or directories
  - etc ...

# Where the transformed files will be created.
:destination: the root directory of where you want the transformed files to go (do not need to exist, only the parent dir).
```

## Usage

The inline help is provided by [EasyAppHelper gem][eahg] mechanism:

	$ batch_audio_convert --help
	Batch Audio Converter Version: 0.1.0

	This application batch-transforms audio files from your central media library from one
	format to another. It basically takes the assumption that the audio library is already
	correctly organized in two levels directory structure that could be:
	- artist/album
	- various/compil
	Nevertheless the files or directories specified could be located anywhere. Only the
	structure is assumed.
	
	It actually replicates the original structure and copies all the tags (handled by taglib)
	to the generated audio files.
	
	Currently only manages FLAC to OGG, all other files are copied untouched.
	
	-- Generic options -------------------------------------------
           	--auto              Auto mode. Bypasses questions to user.
    		--simulate          Do not perform the actual underlying actions.
	    -v, --verbose           Enable verbose mode.
	    -h, --help              Displays this help.
	    
	-- Debug and logging options ---------------------------------
	        --debug             Run in debug mode.
        	--debug-on-err      Run in debug mode with output to stderr.
         	--log-level         Log level from 0 to 5, default 2.
	        --log-file          File to log to.
		
	-- Configuration options -------------------------------------
           	--config-file       Specify a config file.
		
	-- Script specific options------------------------------------
	    -q, --ogg-quality       Defines encoding quality for OGG files.
	    -f, --force             Forces files override.


As you see could then override the ogg quality (defined in the config file) from the command line.

By default batch_audio_convert won't regenerate a file already present in the destination tree, but you can force this behaviour using the `--force` command line option.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Currently there is only flac to ogg conversion, but the program is ready to handle other potential transformations. Do not hesitate, you just have to implement one method named `<origin>_to_<dest>` in the `audio_utils.rb` file and add one supported extension in the config "`extensions`" hash.

Currently only the `flac_to_ogg` method exists and this is why the "`extensions`" hash in the config file contains:

```yaml
:extensions:
  flac: ogg
```




[eahg]: https://rubygems.org/gems/easy_app_helper        "Easy App Helper Gem"
[bacg]: https://rubygems.org/gems/batch_audio_convert        "Batch Audio Convert Gem"
[eahs]: https://github.com/lbriais/easy_app_helper          "Easy App Helper Sources"
[eahg]: https://rubygems.org/gems/easy_app_helper        "Easy App Helper Gem"
[eahcm]: http://rubydoc.info/github/lbriais/easy_app_helper/master/EasyAppHelper/Config        "EasyAppHelper::Config class documentation"
[eahcim]: http://rubydoc.info/github/lbriais/easy_app_helper/master/EasyAppHelper/Config/Instanciator      "EasyAppHelper::Config::Instanciator class documentation"
