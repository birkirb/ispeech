module Ispeech

  class Error < StandardError
    attr_accessor :original_error

    def initialize(message, original_error = nil)
      super(message)
      @original_error = original_error
    end

    def to_s
      if @original_error.nil?
        super
      else
        "#{super}\nCause: #{@original_error.to_s}"
      end
    end
  end

  class ServiceError < Error
    attr_accessor :code

    def initialize(message, code = '')
      super(message)
      @code = code
    end

    def to_s
      "Code: #{code}, Message: #{super}"
    end
  end

end
