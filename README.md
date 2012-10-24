Ruby interface to Ispeech's API for generating speech from text. 
More info on their API at http://www.ispeech.org/api/

## Installation

    gem install ispeech

## Loading
  
    require 'ispeech'

## Config

  Automatically looks for a config/ispeech.yml file.
  Configuration only requires the 'api_key'

### Manual configuration

    Ispeech.config = Ispeech::Config.new('some_api_key_hash')

  or

    Ispeech.config = Ispeech::Config.read(path_to_my_own_yaml_config_file)

## Usage

  Get the voice service object:

    service = Ispeech.voice_service 

  or 
  
    service = Ispeech::VoiceService.new(my_config_object)

### Generate sounds 

    response = service.generate_sound('speak this text', language_or_voice_options)
 
  or

    response = service.generate_with_voice('speak this text', my_voice_object)


### Language and voice options

  All available voices are defined in [voices/default.rb](https://github.com/birkirb/ispeech/blob/master/lib/ispeech/voices/default.rb)

  You can specificy language, gender, voice name in any combination

    response = service.generate_sound('speak this text', {:language => :en, :gender => :male, :speaker => :usenglishfemale})

  If you have access to different set of voice there are rake tasks to generate a different voice map and any customization of the voice map should be easy.
  Refer to the spec for details of that.

### Saving generated sounds

  The response is saved to a tempfile which can be moved, copied or otherwise streamed.

    response = service.generate_sound('speak this text')
    tempfile = response.download_to_tempfile
    
    FileUtils.mv(tempfile.path, 'speak_this_text.mp3')

## Mocking
  
  For convinence purposes you can use an inbuilt mock to avoid web request while testing.

    require 'ispeech/mock'
    Ispeech::Mock.enable!

### Turning off

    Ispeech::Mock.disable!

### Expectations

  Only two expectations can be set

    Ispeech::VoiceService.expect_ok_response

  or

    Ispeech::VoiceService.expect_error_response


## Copyright

Copyright (c) 2012 Birkir A. Barkarson. See LICENSE for details.
