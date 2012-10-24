require 'spec_helper'
require 'ispeech/mock'

describe Ispeech::Mock do

  before(:each) do
    Ispeech::Mock.mock_on
  end

  after(:each) do
    Ispeech::VoiceService.expect_ok_response
    Ispeech::Mock.mock_off
  end

  context 'When mock is on' do
    text_string = 'This is a test'
    service = Ispeech::VoiceService.new

    it 'it should default to giving an working response without net access' do
      response = service.generate_sound(text_string)

      file = response.download_to_tempfile
      file.should be_kind_of(Tempfile)
      file.rewind
      contents = file.read
      file.close
      contents.should == File.read(RESPONSE_TEST_FILE)

      WebMock.should_not have_requested(:any, service.config.target_url.to_s)
    end

    it 'it should give an error response when that expectation has been set' do
      Ispeech::VoiceService.expect_error_response

      expect do
        service.generate_sound(text_string)
      end.to raise_error(Ispeech::Mock::FAKE_ERROR)

      WebMock.should_not have_requested(:any, service.config.target_url.to_s)
    end

    it 'once set to an error and set back to ok should not raise an error' do
      Ispeech::VoiceService.expect_error_response
      Ispeech::VoiceService.expect_ok_response

      expect do
        service.generate_sound(text_string)
      end.to_not raise_error

      WebMock.should_not have_requested(:any, service.config.target_url.to_s)
    end
  end

end
