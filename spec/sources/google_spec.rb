# encoding: UTF-8
require 'vcr_setup'
require 'spec_helper'
require 'roo'
require 'google_drive'

describe TableImporter::Source do
  context 'when source is a google file' do
    before(:each) do
      VCR.use_cassette('google_authentication', :record => :new_episodes) do
        @source = TableImporter::Source.new({
          :content => 'CLIENT_ID, ACCESS_TOKEN',
          :headers_present => true,
          :user_headers => nil,
          :type => "google",
          :column_separator => "",
          :record_separator => "",
          :compulsory_headers =>
            { :email => true }
          })
      end
    end

    it "gets the correct type" do
      VCR.use_cassette('google_authentication') do
        @source.get_type.should eql("google")
      end
    end

    after(:each) do
      @source = nil
    end
  end
end
