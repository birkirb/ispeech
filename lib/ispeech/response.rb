require 'cgi'
require 'net/http'
require 'tempfile'
require 'securerandom'

module Ispeech
  class Response

    RESPONSE_ERROR_MESSAGE = 'message'
    RESPONSE_ERROR_CODE = 'code'
    ERROR_UNEXPECTED_RESPONSE = Error.new("Response was not a valid HTTP response.")

    def initialize(response)
      if response.is_a?(Net::HTTPResponse)
        if 200 == response.code.to_i
          @response = response
        else
          if response.content_length.to_i > 0
            params = CGI::parse(response.body)
            raise ServiceError.new(params[RESPONSE_ERROR_MESSAGE].first, params[RESPONSE_ERROR_CODE].first)
          else
            raise ServiceError.new(response.code_type, response.code)
          end
        end
      else
        raise ERROR_UNEXPECTED_RESPONSE
      end
    end

    def download_to_tempfile
      content = generated_file
      file = Tempfile.new(SecureRandom.uuid)
      file.binmode
      file.write(content)
      file.flush
      file # Leaving open. Will be closed once object is finalized.
    end

    private

    def generated_file
      @response.body
    end

  end
end
