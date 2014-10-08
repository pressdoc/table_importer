# encoding: UTF-8
require 'spec_helper'

describe TableImporter::Source do

  context 'when source is a string it' do

    before(:each) do
      @source = TableImporter::Source.new({
        :content => "nick@pr.co\ndennis@pr.co\nlorenzo@pr.co",
        :headers_present => false, :headers => nil, :user_headers => nil, :type => "copy_and_paste", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "creates a source object" do
      TableImporter::Source.new({:content => "nick@pr.co, dennis@pr.co, lorenzo@pr.co", :headers_present => false, :headers => nil, :user_headers => nil, :type => "copy_and_paste", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "gets the correct copy and paste chunks" do
      source = TableImporter::Source.new({
        :content => "nick@pr.co, dennis@pr.co, lorenzo@pr.co",
        :headers_present => false, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :headers => nil, :type => "copy_and_paste", :column_separator => :space, :record_separator => :comma, :compulsory_headers => {:email => true}})
      source.get_chunks.first[:lines].first[:email].should eql("nick@pr.co")
    end

    it "has the correct number of lines" do
      source = TableImporter::Source.new({:content => "nick@pr.co, dennis@pr.co, lorenzo@pr.co", :headers_present => false, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :headers => nil, :type => "copy_and_paste", :column_separator => :space, :record_separator => :comma, :compulsory_headers => {:email => true}})
      source.get_chunks(1).count.should eql(3)
    end

    it "has the correct number of chunks" do
      source = TableImporter::Source.new({:content => "nick@pr.co, dennis@pr.co, lorenzo@pr.co", :headers_present => false, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :headers => nil, :type => "copy_and_paste", :column_separator => :space, :record_separator => :comma, :compulsory_headers => {:email => true}})
      source.get_chunks(2).count.should eql(2)
    end

    it "does not have extra spaces in the final chunk" do
      source = TableImporter::Source.new({:content => "nick@pr.co, dennis@pr.co, lorenzo@pr.co", :headers_present => false, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :headers => nil, :type => "copy_and_paste", :column_separator => :space, :record_separator => :comma, :compulsory_headers => {:email => true}})
      last_chunk = source.get_chunks(2).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(1)
    end

    it "gets the correct preview lines" do
      @source.get_preview_lines.count.should eql(3)
    end

    it "can get the correct record separator" do
      @source.get_record_separator.should eql(:newline_mac)
    end

    it "can get the correct column separator" do
      @source.get_column_separator.should eql(:space)
    end

    it "has the correct type" do
      @source.get_type.should eql("copy_and_paste")
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is a different string' do

    before(:each) do
      @source = TableImporter::Source.new({:content => "Nick Dowse <nick@pr.co>, Dennis van der Vliet <dennis@pr.co>, Jeroen Bos <jeroen@pr.co>", :headers_present => false, :user_headers => {"first_name"=>"0", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"1", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :headers => nil, :type => "copy_and_paste", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "gets the correct chunks" do
      @source.get_chunks.first[:lines].first[:email].should eql("nick@pr.co")
    end

    it "has the correct column_separator" do
      @source.get_column_separator.should eql(nil)
    end

    it "has the correct record_separator" do
      @source.get_record_separator.should eql(nil)
    end

    it "has the correct number of lines" do
      @source.get_chunks(1).count.should eql(3)
    end

    it "has the correct number of chunks" do
      @source.get_chunks(2).count.should eql(2)
    end

    it "does not have extra spaces in the final chunk" do
      last_chunk = @source.get_chunks(2).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(1)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source is a bad string' do

    before(:each) do
      @source = TableImporter::Source.new({
        :content => "Dennis,denni@pr.co,Amsterdam
          Nick@test.com,”
          “, Amsterdam
          jeroen@, \"jeroe
          adine, \"

          lorenzo,\"lorenzo@pr.co\"
          HÐ, “nick¯â@test”, ¾,€",
        :headers_present => false, :headers => nil, :user_headers => nil, :type => "copy_and_paste", :column_separator => :comma, :record_separator => :newline_mac, :compulsory_headers => {:email => true}})
    end

    it "has the correct number of lines" do
      @source.get_lines.count.should eql(8)
    end

    it "has the correct number of chunks" do
      @source.get_chunks(4).count.should eql(2)
    end

    it "does not have extra spaces in the final chunk" do
      last_chunk = @source.get_chunks(3).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(2)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when string is empty' do
    it 'raises an error when creating a source object' do
      expect{
        TableImporter::Source.new({:content => "", :headers_present => false, :headers => nil, :user_headers => nil, :type => "copy_and_paste", :column_separator => :comma, :record_separator => :newline_mac, :compulsory_headers => {:email => true}})
      }.to raise_error(TableImporter::EmptyFileImportError)
    end
  end
end
