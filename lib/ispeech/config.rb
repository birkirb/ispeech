require 'yaml'
require 'uri'

module Ispeech
  class Config
    attr_reader :api_key,
                :target_url

    DEFAULT_TARGET_URL = 'http://api.ispeech.org/api/rest'

    def initialize(api_key, target_url = nil)
      @api_key = api_key
      @target_url = URI.parse(target_url || DEFAULT_TARGET_URL)
    end

    def self.read(config_file = nil)
      config_file ||= File.join('config', 'ispeech.yml')
      begin
        yaml = YAML.load_file(config_file)
        self.new(yaml['api_key'], yaml['target_url'])
      rescue => err
        raise Error.new("Failed to read configuration file", err)
      end
    end

  end
end
