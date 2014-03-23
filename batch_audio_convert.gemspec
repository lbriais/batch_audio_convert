# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'batch_audio_convert/version'

Gem::Specification.new do |spec|
  spec.name          = "batch_audio_convert"
  spec.version       = BatchAudioConvert::VERSION
  spec.authors       = ["L.Briais"]
  spec.email         = ["lbnetid+rb@gmail.com"]
  spec.description   = %q{Batch Audio Convert}
  spec.summary       = %q{Converts FLAC audio files to OGG or MP3 format while keeping tags and tree structure}
  spec.homepage      = "https://github.com/lbriais/batch_audio_convert"
  spec.license       = "MIT"
  spec.platform      = Gem::Platform::CURRENT

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "easy_app_helper", "~> 1.0"
  spec.add_runtime_dependency "taglib-ruby"

end
