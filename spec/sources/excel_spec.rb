# encoding: UTF-8
require 'spec_helper'
require 'roo'

describe TableImporter::Source do

  context 'when source is an xls file with headers' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "creates a source object" do
      TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct headers" do
      @source.get_headers.should eql(([:ExternalEmailAddress, :Name, :FirstName, :LastName, :StreetAddress, :City, :StateorProvince, :PostalCode, :Phone, :MobilePhone, :Pager, :HomePhone, :Company, :Title, :OtherTelephone, :Department, :CountryOrRegion, :Fax, :Initials, :Notes, :Office, :Manager]))
    end

    it "has the correct number of lines" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(1).count.should eql(6)
    end

    it "has the correct number of chunks" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(2).count.should eql(4)
    end

    it "does not have extra spaces in the final chunk" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      last_chunk = source.get_chunks(4).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(2)
    end

    it "gets the preview lines" do
      @source.get_preview_lines.count.should eql(5)
    end

    it "has the correct type" do
      @source.get_type.should eql("xls")
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is an xls file without headers' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/without_headers.xls"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "creates a source object" do
      TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/without_headers.xls"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct number of columns" do
      @source.get_headers.count.should eql(100)
    end

    it "has the correct number of lines" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(1).count.should eql(7)
    end

    it "has the correct number of chunks" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(2).count.should eql(4)
    end

    it "does not have extra spaces in the final chunk" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      last_chunk = source.get_chunks(4).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(3)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is an edge-case xls file without headers' do
    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/edge_cases.xls"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "creates a source object" do
      TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/edge_cases.xls"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct number of lines" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/edge_cases.xls"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(1).count.should eql(13)
    end

    it "has the correct number of chunks" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/edge_cases.xls"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(4).count.should eql(4)
    end

    it "does not have extra spaces in the final chunk" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/edge_cases.xls"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      last_chunk = source.get_chunks(4).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(1)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source has empty lines' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/empty_lines.xlsx"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "does not throw an error" do
      expect {@source.get_preview_lines}.to_not raise_error
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source has 20 empty lines at the beginning' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/empty_lines_at_start.xlsx"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "does not throw an error" do
      @source.get_preview_lines.count.should eql(6)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is an empty xls file' do

    it 'raises an error when creating a source object' do
      begin
        TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/no_content.xlsx"].join), :headers => "false", :type => "xls", :column_separator => "", :record_separator => ""})
      rescue TableImporter::EmptyFileImportError => e
        e.message
      end
    end
  end
end
