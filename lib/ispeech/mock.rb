module Ispeech
  module Mock

    RESPONSE_MP3_FILE = File.join(File.dirname(__FILE__), '..', '..', 'spec', 'test_data', 'test_file.mp3')
    FAKE_ERROR = Error.new("The mock wants you to fail!")
    EMPTY_PROC = proc {}

    def self.enable!
      Ispeech::Response.class_eval(<<-EVAL, __FILE__, __LINE__)
        def download_to_tempfile
          download_to_tempfile_with_mock
        end
        def initialize(response)
          initialize_with_fake_response
        end
      EVAL
      Ispeech::VoiceService.class_eval(<<-EVAL, __FILE__, __LINE__)
        def post(params)
          post_with_set_response(params)
        end
      EVAL
    end

    def self.disable!
      Ispeech::Response.class_eval(<<-EVAL, __FILE__, __LINE__)
        def download_to_tempfile
          download_to_tempfile_without_mock
        end
        def initialize(response)
          initalize_without_fake_response(response)
        end
      EVAL
      Ispeech::VoiceService.class_eval(<<-EVAL, __FILE__, __LINE__)
        def post(params)
          post_without_set_response(params)
        end
      EVAL
    end

  end
end

module Ispeech
  class Response

    private

    alias :download_to_tempfile_without_mock :download_to_tempfile
    alias :initalize_without_fake_response :initialize

    def download_to_tempfile_with_mock
      tempfile = Tempfile.new(SecureRandom.uuid)
      File.open(Mock::RESPONSE_MP3_FILE) do |f|
        tempfile.write(f.read)
        tempfile.flush
      end
      tempfile
    end

    def initialize_with_fake_response
      VoiceService.expected_response.call
    end

  end
end

module Ispeech
  class VoiceService

    @@expected_response = Mock::EMPTY_PROC

    def self.expected_response
      @@expected_response
    end

    def self.expect_ok_response
      @@expected_response = Mock::EMPTY_PROC
    end

    def self.expect_error_response
      @@expected_response = proc { raise Mock::FAKE_ERROR }
    end

    private

    alias :post_without_set_response :post

    def post_with_set_response(params)
      self.class.expected_response
    end

  end
end
