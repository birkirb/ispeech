require 'spec_helper'

describe Ispeech do
  it 'should reference a config file' do
    config = Ispeech.config

    config.should_not be_nil
    config.should be_a_kind_of(Ispeech::Config)
  end

  it 'should allow setting of the config file' do
    default_config = Ispeech.config

    begin
      test_config = Ispeech::Config.read(test_config)

      Ispeech.config = test_config
      Ispeech.config.should == test_config
    ensure
      Ispeech.config = default_config
    end
  end

end
