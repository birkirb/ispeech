require 'spec_helper'

describe Ispeech::Config, 'When created' do

  default_config = YAML.load_file('config/ispeech.yml')
  default_config['api_key'].should_not == nil

  context 'with a given api_key' do
    it 'should report those and other default values' do
      config = Ispeech::Config.new(default_config['api_key'])
      config.target_url.should == URI.parse(Ispeech::Config::DEFAULT_TARGET_URL)
      config.api_key.should == default_config['api_key']
    end
  end

  context 'from a config file' do
    it 'should default to the local config/ispeech.yml' do
      config = Ispeech::Config.read
      config.api_key.should == default_config['api_key']
    end

    it 'should accept an arbitary config file argument' do
      config = Ispeech::Config.read(test_config)
      config.api_key.should_not be_nil
      config.api_key.should_not == default_config['api_key']
    end
  end

end
