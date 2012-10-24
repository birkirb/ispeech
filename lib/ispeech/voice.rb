require 'set'

module Ispeech
  class Voice
    attr_reader :languages, :speaker, :gender, :quality

    def initialize(speaker, gender, *languages)
      @speaker = speaker
      @gender = gender
      @quality = QUALITY_HIGH

      @languages = Set.new
      languages.each { |lang| @languages.add(lang) }
    end

    def id
      "#{speaker.downcase}"
    end

    def language
      languages.first
    end

    def low_quality!
      @quality = QUALITY_LOW
    end

    def high_quality!
      @quality = QUALITY_HIGH
    end

    def self.override_map(override_voice_map = {})
      current_map = self.map
      override_voice_map.each do |language, voices|
        language_sym = language.to_sym
        if voices.nil?
          # Remove voice directive.
          current_map.delete(language_sym)
        elsif voices.is_a?(String) || voices.is_a?(Symbol)
          # Map voice directive.
          current_map[language_sym] = self.map[voices]
        elsif voices.is_a?(Hash)
          # Replace/Override
          if entry = self.map[language_sym]
            new_entry = entry.dup
          else
            new_entry = Hash.new
          end

          voices.each do |gender, speakers|
            if gender.is_a?(Symbol) && speakers.is_a?(Array)
              new_entry[gender] = speakers
            end
          end
          current_map[language_sym] = new_entry
        end
      end
      @@map = current_map
    end

    def self.map
      reset_map unless defined?(@@map)
      @@map
    end

    def self.reset_map
      @@map = Voices::PER_LANGUAGE.dup
    end

    def self.extract_from_options(options = {})
      if speaker = options[:speaker]
        named_voice(speaker)
      else
        language = options[:language] || :en
        gender = options[:gender]
        speakers_for_language = self.map[language]

        speakers = case gender
        when GENDER_FEMALE
          speakers_for_language[GENDER_FEMALE]
        when GENDER_MALE
          speakers_for_language[GENDER_MALE]
        else
          speakers_for_language[GENDER_FEMALE] +
            speakers_for_language[GENDER_MALE]
        end

        if speakers.empty?
          nil
        else
          named_voice(speakers.sample)
        end
      end
    end

    def self.named_voice(speaker)
      unless defined?(@@voices)
        @@voices = Hash.new
        self.map.each do |language, voices|
          [GENDER_MALE, GENDER_FEMALE].each do |gender|
            voices[gender].each do |name|
              downcase_name = name.downcase.to_sym
              if @@voices[downcase_name].nil?
                @@voices[downcase_name] = Voice.new(name, gender, language.to_s)
              else
                @@voices[downcase_name].languages.add(language.to_s)
              end
            end
          end
        end
      end

      if info = @@voices[speaker.to_s.downcase.to_sym]
        info
      else
        raise Error.new("Voice does not exist.")
      end
    end

  end
end
