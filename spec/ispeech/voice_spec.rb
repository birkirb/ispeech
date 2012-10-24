require 'spec_helper'

describe Ispeech::Voice do

  context 'When created' do
    speaker_name = 'tom'
    test_voice = Ispeech::Voice.new(speaker_name, Ispeech::Voice::GENDER_FEMALE)

    it 'with name and gender should report default values' do
      test_voice.speaker.should == speaker_name
      test_voice.gender.should == Ispeech::Voice::GENDER_FEMALE
      test_voice.quality.should == Ispeech::Voice::QUALITY_HIGH
      test_voice.languages.should be_kind_of(Set)
      test_voice.languages.should be_empty
      test_voice.language.should be_nil
      test_voice.id.should == "#{speaker_name}"
    end

    it 'should allow flipping quality setting' do
      test_voice.low_quality!
      test_voice.quality.should == Ispeech::Voice::QUALITY_LOW
      test_voice.high_quality!
      test_voice.quality.should == Ispeech::Voice::QUALITY_HIGH
    end
  end

  context 'With a set of defined voices' do
    it 'should throw an error if the voice does not exist' do
      expect do
        Ispeech::Voice.named_voice('Birkir')
      end.to raise_error(Ispeech::Error, "Voice does not exist.")
    end

    it 'should return the active voice map' do
      Ispeech::Voice.map.should == Ispeech::Voices::PER_LANGUAGE
    end

    context 'should find a voice' do
      it 'given an existing speaker name' do
        voice = Ispeech::Voice.named_voice(DEFAULT_ENGLISH_FEMALE_TEST_VOICES.first)
        voice.speaker.should == DEFAULT_ENGLISH_FEMALE_TEST_VOICES.first
        voice.language.should == 'en'
        voice.gender.should == Ispeech::Voice::GENDER_FEMALE
        voice.languages.to_a.should == ['en']
        voice.id.should == DEFAULT_ENGLISH_FEMALE_TEST_VOICES.first
      end

      it 'given an existing speaker name in lower case' do
        voice = Ispeech::Voice.named_voice('bruno')
        voice.speaker.should == 'Bruno'
        voice.gender.should == Ispeech::Voice::GENDER_MALE
        voice.language.should == 'fr'
      end

      it 'given an existing speaker name as a symbol' do
        voice = Ispeech::Voice.named_voice(:rosa)
        voice.speaker.should == 'Rosa'
        voice.gender.should == Ispeech::Voice::GENDER_FEMALE
        voice.language.should == 'es'
      end
    end

    context 'should extract a voice when given an option that' do
      it 'specifies nothing, defaulting to English' do
        voice = Ispeech::Voice.extract_from_options
        (DEFAULT_ENGLISH_FEMALE_TEST_VOICES + DEFAULT_ENGLISH_MALE_TEST_VOICES).should include(voice.speaker)
      end

      it 'specifies a speaker' do
        voice = Ispeech::Voice.extract_from_options(:speaker => 'antoine')
        voice.speaker.should == 'Antoine'
        voice.gender.should == Ispeech::Voice::GENDER_MALE
        voice.language.should == 'fr'
      end

      it 'specifies a language' do
        voice = Ispeech::Voice.extract_from_options(:language => :es)
        voice.speaker.should == 'Rosa'
      end

      it 'specifies a language and no gender' do
        voice = Ispeech::Voice.extract_from_options(:language => :fr)
        voice.should_not be_nil
        ['Antoine', 'Bruno'].should include(voice.speaker)
      end

      it 'specifies a language and gender' do
        voice = Ispeech::Voice.extract_from_options(:language => :es, :gender => Ispeech::Voice::GENDER_FEMALE)
        voice.speaker.should == 'Rosa'

        voice = Ispeech::Voice.extract_from_options(:language => :es, :gender => Ispeech::Voice::GENDER_MALE)
        voice.should be_nil
      end
    end
  end

  context 'Allows for voices to be overriden or changed' do
    after(:each) do
      Ispeech::Voice.reset_map
    end

    it 'should allow removing specific entries' do
      Ispeech::Voice.map[:en][:male].first.should == DEFAULT_ENGLISH_MALE_TEST_VOICES.first
      Ispeech::Voice.override_map(:en => nil)
      Ispeech::Voice.map[:en].should be_nil
    end

    it 'should allow mapping one entry to another' do
      Ispeech::Voice.map[:en][:male].first.should == DEFAULT_ENGLISH_MALE_TEST_VOICES.first
      Ispeech::Voice.override_map(:en => :fr)
      Ispeech::Voice.map[:en][:male].first.should == 'Antoine'
    end

    it 'should allow replacing an entry' do
      Ispeech::Voice.map[:en][:male].first.should == DEFAULT_ENGLISH_MALE_TEST_VOICES.first
      Ispeech::Voice.override_map(:en => {:male => ['Johnny']})
      Ispeech::Voice.map[:en][:male].should == ['Johnny']
      Ispeech::Voice.map[:en][:female].first.should == DEFAULT_ENGLISH_FEMALE_TEST_VOICES.first
    end

    it 'should allow adding an entry' do
      Ispeech::Voice.map[:is].should be_nil
      Ispeech::Voice.override_map(:is => {:male => ['Birkir'], :female => ['Harpa']})
      Ispeech::Voice.map[:is][:male].first.should == 'Birkir'
      Ispeech::Voice.map[:is][:female].first.should == 'Harpa'
    end
  end
end
