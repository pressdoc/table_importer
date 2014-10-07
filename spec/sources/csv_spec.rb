# encoding: UTF-8
require 'spec_helper'
require 'smarter_csv'

describe TableImporter::Source do

  context 'when source is a csv file with headers' do
    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/with_headers.csv"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct headers" do
      @source.get_headers.should eql(["country", "medium", "salutation", "first_name", "last_name", "email", "phone_number", "tags"])
    end

    it "has the correct number of chunks" do
      @source.get_chunks(4).count.should eql(3)
    end

    it "does not have extra spaces in the final chunk" do
      last_chunk = @source.get_chunks(4).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(1)
    end

    it "can get the correct record separator" do
      @source.get_record_separator.should eql(:newline_mac)
    end

    it "can get the correct column separator" do
      @source.get_column_separator.should eql(:semicolon)
    end

    it "has the correct type" do
      @source.get_type.should eql("csv")
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is a csv file without headers it' do
    before(:each) do
      @source_headers = "false"
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/without_headers.csv"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "creates a source object" do
      TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/without_headers.csv"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct number of chunks" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/without_headers.csv"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"5", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "csv", :column_separator => :semicolon, :record_separator => :newline_mac, :compulsory_headers => {:email => true}})
      source.get_chunks(4).count.should eql(3)
    end

    it "does not have extra spaces in the final chunk" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/without_headers.csv"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"5", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "csv", :column_separator => :semicolon, :record_separator => :newline_mac, :compulsory_headers => {:email => true}})
      source.get_chunks(4).last[:lines].count.should eql(1)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is an edge-case csv file without headers' do
    before(:each) do
      @source_headers = "false"
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/edge_cases.csv"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "creates a source object" do
      TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/edge_cases.csv"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct number of chunks" do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/edge_cases.csv"].join), :headers_present => false, :headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"1", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks(4).count.should eql(3)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is a badly encoded file' do
    it 'can still get the correct chunks' do
      source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/mexico2013_pressdoc.csv"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      source.get_chunks.first[:lines].count.should eql(49)
    end
  end

  context 'when source is an empty csv file' do

    it 'raises an error when creating a source object' do
      begin
        TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/no_content.csv"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      rescue TableImporter::EmptyFileImportError => e
        e.message
      end
    end
  end

  context 'when source has empty lines at start' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/empty_lines_at_start.csv"].join), :headers_present => true, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "Gets the preview lines without error" do
      @source.get_preview_lines.count.should eql(7)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is badly encoded partway through the file' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/csv/partway.csv"].join), :headers_present => false, :headers => nil, :user_headers => nil, :type => "csv", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "Gets the first chunk without error" do
      @source.get_chunks[0][:lines].count.should eql(50)
    end

    after(:each) do
      @source = nil
    end
  end
end
