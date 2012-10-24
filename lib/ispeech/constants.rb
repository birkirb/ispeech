require 'uri'

module Ispeech

  VERSION = "1.0.1"

  class Voice
    QUALITY_LOW = 8000
    QUALITY_HIGH = 22050
    GENDER_FEMALE = :female
    GENDER_MALE = :male
  end

  module Scripts
    LOCAL_TEMP_DIR = 'tmp'
    VOICES_ENUMERATOR_FILE = File.join('tmp', 'voice_enumerator.out')
  end

end
