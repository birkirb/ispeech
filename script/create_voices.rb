require 'net/http'
require 'set'
require 'fileutils'
require 'json'
require 'ispeech'
include Ispeech::Scripts

DEFAULT_VOICES_RUBY_FILE = File.join('lib', 'ispeech', 'voices', 'default.rb')
VOICE_KEY_FIELDS = /voice-([^-\d]*)-?(\d+)-?\d*$/

def save_uri_to_file_if_missing(filename)
  if !File.exists?(filename)
    FileUtils.mkdir_p(LOCAL_TEMP_DIR)
    response = Ispeech.voice_service.with_action('information', :output => :json)
    file = response.download_to_tempfile
    FileUtils.mv(file.path, filename)
  end
end

def convert_text_to_voices(text)
  raw_voices = JSON.parse(text)
  structured_voices = Hash.new { |h,k| h[k] = Hash.new}

  raw_voices.each do |key,value|
    if match = VOICE_KEY_FIELDS.match(key)
      if match[1].empty?
        structured_voices[match[2].to_i][:speaker] = value
      else
        structured_voices[match[2].to_i][match[1].to_sym] = value
      end
    else
      if $VERBOSE
        puts "Failed to parse: #{key}=#{value}"
      end
    end
  end

  voices = Array.new
  structured_voices.each do |number, hash|
    voices << {'language_locale' => hash[:locale], 'speaker' => hash[:speaker], 'gender' => hash[:gender]}
  end

  voices
end

def gender_code_to_symbol(gender)
  case gender.downcase
  when 'f','female'
    Ispeech::Voice::GENDER_FEMALE
  when 'm','male'
    Ispeech::Voice::GENDER_MALE
  else
    raise "Unknown gender code: #{gender}"
  end
end

def qualified_locale(locale)
  split = locale.split('-') || locale.split('_')

  if split.size > 1
    "#{split.first}_#{split.last.upcase}"
  else
    split.first
  end
end

def simple_language_code(locale)
  locale.split('_').first
end

class Set
  def inspect
    self.to_a.inspect
  end
end

def voice_array_to_voices_per_language(voices)
  language_voices = Hash.new { |h,v| h[v] = { :female => Set.new, :male => Set.new } }

  voices.each do |voice_hash|
    gender = gender_code_to_symbol(voice_hash['gender'])
    locale = qualified_locale(voice_hash['language_locale'])
    simple_locale = simple_language_code(locale)

    language_voices[locale][gender].add(voice_hash['speaker'])
    language_voices[simple_locale][gender].add(voice_hash['speaker'])
  end

  # Clean up instance where specific locale is same as generic one.
  language_voices.delete_if do |key,value|
    simple_locale = simple_language_code(key)
    if key != simple_locale && language_voices[simple_locale] == value
      true
    else
      false
    end
  end

  language_voices
end

def construct_class(voices_per_language)
  text_hashes = voices_per_language.keys.sort.map do |key|
    "".rjust(6) + ":" + key.to_s.ljust(8) + "=>".ljust(4) + voices_per_language[key].inspect
  end

  klass_text = <<-CLASS
module Ispeech
  module Voices
    PER_LANGUAGE = {
#{text_hashes.join(",\n")}
    }
  end
end
CLASS
  klass_text
end

def write_klass(klass)
  klass_dir = File.dirname(DEFAULT_VOICES_RUBY_FILE)

  if !File.exist?(klass_dir)
    FileUtils.mkdir_p(klass_dir)
  end

  File.open(DEFAULT_VOICES_RUBY_FILE, 'w') do |f|
    f.write(klass)
  end
end

def main
  save_uri_to_file_if_missing(VOICES_ENUMERATOR_FILE)
  voices = convert_text_to_voices(File.read(VOICES_ENUMERATOR_FILE))

  voices_per_language = voice_array_to_voices_per_language(voices)
  klass = construct_class(voices_per_language)
  write_klass(klass)
  puts "Done."
end

if $0 == __FILE__
  main
end
