require 'net/http'

module Ispeech
  class VoiceService

    CLIENT_ENVIRONMENT = "RUBY_#{RUBY_VERSION}"

    ERROR_MISSING_CONFIG = Error.new("VoiceService requires configuration.")

    attr_reader :config

    def initialize(config = Ispeech.config)
      if config.is_a?(Ispeech::Config)
        @config = config
      else
        raise ERROR_MISSING_CONFIG
      end
    end

    def generate_sound(text, options = {})
      voice = Voice.extract_from_options(options)

      case options[:quality]
      when :low
        voice.low_quality!
      when :high
        voice.high_quality!
      end

      generate_with_voice(text, voice)
    end

    def generate_with_voice(text, voice)
      params = {
        # API Defaults:
        # :bitrate => 48,
        # :speed => 0,
        # :startpadding => 0,
        # :endpadding => 0,
        # :pitch => 100,
        # :format => 'mp3',
        # :bitdepth => 16,
        # :filename => 'rest'
        :voice => voice.id,
        :frequency => voice.quality,
        :text => text,
      }

      with_action(:convert, params)
    end

    def with_action(action, params)
      params[:action] = action
      Response.new(post(params))
    end

    private

    def post(params)
      params[:apikey] = @config.api_key
      Net::HTTP.post_form(@config.target_url, params)
    end

  end
end
