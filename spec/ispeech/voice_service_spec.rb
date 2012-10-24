require 'spec_helper'

describe Ispeech::VoiceService do

  text_string = 'This is a test'

  context 'When create without parameters' do
    service = Ispeech::VoiceService.new

    it 'should use the default config' do
      service.config.should be_kind_of(Ispeech::Config)
      service.config.should == Ispeech.config
    end

    it 'should allow generation of MP3 sound' do
      if USE_MOCKS
        stub_ok_response(service)
      end

      sound_url = service.generate_sound(text_string, :language => :en)
      sound_url.should be_kind_of(Ispeech::Response)
    end
  end

  it 'should throw an error when created with nil config' do
    expect do
      service = Ispeech::VoiceService.new(nil)
    end.to raise_error(Ispeech::Error, Ispeech::VoiceService::ERROR_MISSING_CONFIG.message)
  end

  context 'When created with config with invalid api_key' do
    service = Ispeech::VoiceService.new(Ispeech::Config.read(test_config))

    it 'should raise the reported access error' do
       if USE_MOCKS
        stub_invalid_access_response(service)
       end

       expect do
         service.generate_sound(text_string, :language => :en)
       end.to raise_error(Ispeech::ServiceError, /Code: 1, Message: Invalid API key/)
    end
  end

  context 'When generating sound' do
    service = Ispeech::VoiceService.new

    it 'should allow low quality setting' do
      if USE_MOCKS
        stub_ok_response(service).with(:body => hash_including(:voice => DEFAULT_ENGLISH_FEMALE_TEST_VOICES.first))
        service.generate_sound(text_string, :speaker => DEFAULT_ENGLISH_FEMALE_TEST_VOICES.first, :quality => :low)
      else
        pending("Without mock, the returned file quality needs to be confirmed")
      end
    end

    it 'should allow custom voice setting' do
      if USE_MOCKS
        stub_ok_response(service).with(:body => hash_including(:voice => 'johnny'))
        voice = Ispeech::Voice.new('johnny', :male, 'en')
        service.generate_with_voice(text_string, voice)
      else
        pending("Without mock, the returned file quality needs to be confirmed")
      end
    end
  end

end
