require 'spec_helper'
require 'cgi'

describe Ispeech::Response do

  it 'should throw an error when created with bogus parameters' do
    expect do
      Ispeech::Response.new('take this!')
    end.to raise_error(Ispeech::Error, Ispeech::Response::ERROR_UNEXPECTED_RESPONSE.message)
  end

  it 'should download and return a tempfile with the object contained in the response' do
    service_url = URI.parse('http://somewhere.com/api')
    stub_ok_response_for_url(service_url)
    service_response = Net::HTTP.get_response(service_url)

    response = Ispeech::Response.new(service_response)

    file = response.download_to_tempfile
    file.should be_kind_of(Tempfile)
    file.rewind
    contents = file.read
    file.close
    contents.should == File.read(RESPONSE_TEST_FILE)
  end

  it 'should raise an error when file download fails with non 200 response' do
    expect do
      Ispeech::Response.new(Net::HTTPNotFound.new("Body?", 404, "Something went wrong."))
     end.to raise_error(Ispeech::Error)
  end

end
