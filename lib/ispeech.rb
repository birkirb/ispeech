require 'ispeech/error'
require 'ispeech/config'
require 'ispeech/voices/default'
require 'ispeech/voice'
require 'ispeech/constants'
require 'ispeech/response'
require 'ispeech/voice_service'

if RUBY_VERSION < "1.9"
  require 'backports'
end

module Ispeech

  def self.config
    @@config ||= Ispeech::Config.read rescue nil
  end

  def self.config=(config)
    if config.is_a?(Ispeech::Config)
      @@config = config
    else
      raise Error.new("Ispeech configuration required. Not #{config.class}")
    end
  end

  def self.voice_service
    VoiceService.new(config)
  end

end
