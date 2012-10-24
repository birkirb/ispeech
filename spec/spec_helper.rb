RESPONSE_TEST_FILE = File.join('spec', 'test_data', 'test_file.mp3')
DEFAULT_ENGLISH_FEMALE_TEST_VOICES = ["usenglishfemale", "auenglishfemale"]
DEFAULT_ENGLISH_MALE_TEST_VOICES = ["usenglishmale"]
USE_MOCKS = true
CONFIG_DIR = 'config'
CONFIG_FILE = File.join(CONFIG_DIR, 'ispeech.yml')
DEFAULT_CONFIG_FILE = <<-YAML
api_key: 'developerdemokeydeveloperdemokey'
YAML

def create_missing_config_file
  unless File.exists?(CONFIG_FILE)
    Dir.mkdir(CONFIG_DIR)
    File.open(CONFIG_FILE, 'w') do |f|
      f.write(DEFAULT_CONFIG_FILE)
    end
  end
end

create_missing_config_file

require File.join(File.dirname(__FILE__), '..', 'init')
require 'bundler'
Bundler.require(:development)
require 'webmock/rspec'

if USE_MOCKS
  WebMock.disable_net_connect!
else
  WebMock.allow_net_connect!
end

def silence_warnings
  begin
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end
end

# Some test voices.
silence_warnings do
  Ispeech::Voices::PER_LANGUAGE = {
    :en => {:female => DEFAULT_ENGLISH_FEMALE_TEST_VOICES, :male => DEFAULT_ENGLISH_MALE_TEST_VOICES},
    :es => {:female => ["Rosa"], :male => []},
    :fr => {:female => [], :male => ["Antoine", "Bruno"]},
  }
end

# Helper methods

def test_config
  File.join('spec', 'test_data', 'test_config.yml')
end

def stub_invalid_access_response(service)
  body_string = "result=error&code=1&message=Invalid+API+key"
  stub_request(:any, service.config.target_url.to_s).to_return(:headers => {:content_length => body_string.size}, :body => body_string, :status => 202)
end

def stub_ok_response_for_url(target_url)
  body_string = File.new(RESPONSE_TEST_FILE)
  stub_request(:any, target_url.to_s).to_return(:headers => {:content_length => body_string.size}, :body => body_string, :status => 200)
end

def stub_ok_response(service)
  stub_ok_response_for_url(service.config.target_url)
end
