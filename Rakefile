#!/usr/bin/env ruby

require 'rake'
require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'ispeech/constants'

RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ["-fd", "-c"]
end

namespace :generate do
  desc "Generates MP3 with test strings for all voices."
  task :test_voices do
    exec('ruby -I lib script/test_voices.rb')
  end

  desc "Generate default voice class based on a voice list retrieved from iSpeech's API"
  task :default_voices_class do
    exec('ruby -I lib script/create_voices.rb')
  end
end

desc "Clean up generated and downloaded files"
task :clean do
  include Ispeech::Scripts
  FileUtils.rm_rf(LOCAL_TEMP_DIR)
  FileUtils.rm(VOICES_ENUMERATOR_FILE) rescue nil
end

task :default => :spec
