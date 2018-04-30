# encoding: UTF-8
require 'spec_helper'
require 'roo'

describe TableImporter::Source do

  context 'when source is an xls file with headers' do
    context 'when mapping has not been set' do

      before(:each) do
        @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      end

      it "gets the preview lines" do
        @source.get_preview_lines.count.should eql(6)
      end

      it "has the correct type" do
        @source.get_type.should eql("xls")
      end

      after(:each) do
        @source = nil
      end
    end

    context 'when mapping has been set' do

      before(:each) do
        @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/with_headers.xls"].join), :headers_present => true, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      end

      it "has the correct headers" do
        @source.get_headers.should eql([:ExternalEmailAddress, :Name, :FirstName, :LastName, :StreetAddress, :City, :StateorProvince, :PostalCode, :Phone, :MobilePhone, :Pager, :HomePhone, :Company, :Title, :OtherTelephone, :Department, :CountryOrRegion, :Fax, :Initials, :Notes, :Office, :Manager])
      end

      it "has the correct number of lines" do
        @source.get_chunks(1).count.should eql(6)
      end

      it "gets the correct chunk content" do
        expect(@source.get_chunks[0][:lines].first[:email]).to eql("darrenp@fabrikam.com")
      end

      it "has the correct number of chunks" do
        @source.get_chunks(2).count.should eql(4)
      end

      it "does not have extra spaces in the final chunk" do
        last_chunk = @source.get_chunks(4).last
        (last_chunk[:lines].count + last_chunk[:errors].count).should eql(2)
      end

      after(:each) do
        @source = nil
      end
    end
  end

  context 'when source is an xls file without headers' do
    context 'when mapping has not been set' do
      before(:each) do
        @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/without_headers.xls"].join), :headers_present => false, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      end

      it "has the correct number of columns" do
        @source.get_headers.count.should eql(100)
      end

      after(:each) do
        @source = nil
      end
    end

    context 'when mapping has been set' do

      before(:each) do
        @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/without_headers.xls"].join), :headers_present => false, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
      end

      it "has the correct number of lines" do
        @source.get_chunks(1).count.should eql(6)
      end

      it "gets the correct chunk content" do
        expect(@source.get_chunks[0][:lines].first[:email]).to eql("darrenp@fabrikam.com")
      end

      it "has the correct number of chunks" do
        @source.get_chunks(2).count.should eql(4)
      end

      it "does not have extra spaces in the final chunk" do
        last_chunk = @source.get_chunks(4).last
        (last_chunk[:lines].count + last_chunk[:errors].count).should eql(2)
      end

      after(:each) do
        @source = nil
      end
    end
  end

  context 'when source is an edge-case xls file without headers' do
    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/edge_cases.xls"].join), :headers_present => false, :user_headers => {"first_name"=>"", "last_name"=>"", "salutation"=>"", "tag_list"=>"", "email"=>"0", "organization"=>"", "url"=>"", "phone"=>"", "job_title"=>"", "second_url"=>"", "notes"=>"", "twitter_username"=>"", "skype_username"=>"", "pinterest_username"=>"", "instagram_username"=>"", "facebook_username"=>"", "last_name_prefix"=>"", "second_email"=>"", "phone_mobile"=>"", "street"=>"", "street_number"=>"", "zipcode"=>"", "city"=>"", "country"=>""}, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
    end

    it "has the correct number of lines" do
      @source.get_chunks(1).count.should eql(13)
    end

    it "has the correct number of chunks" do
      @source.get_chunks(4).count.should eql(4)
    end

    it "does not have extra spaces in the final chunk" do
      last_chunk = @source.get_chunks(4).last
      (last_chunk[:lines].count + last_chunk[:errors].count).should eql(1)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'when source has empty lines' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/empty_lines.xlsx"].join), :headers_present => false, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
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
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/empty_lines_at_start.xlsx"].join), :headers_present => true, :user_headers => nil, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => {:email => true}})
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
        TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/no_content.xlsx"].join), :headers_present => "false", :type => "xls", :column_separator => "", :record_separator => ""})
      rescue TableImporter::EmptyFileImportError => e
        e.message
      end
    end
  end

  context 'premapped_1' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/premapped_1.xls"].join), :headers_present => "true", :type => "xls", :column_separator => "", :record_separator => "",
        :user_headers => {:first_name=>0, :last_name_prefix=>1, :last_name=>2, :organization=>3, :second_email=>5, :email=>6, :phone=>7, :phone_mobile=>8, :twitter_username=>9, :url=>10, :street=>11, :street_number=>12, :zipcode=>13, :country=>18},
        :compulsory_headers => {:email => true}
      })
    end

    it "has correct mapping" do
      expect(@source.get_preview_lines.first.keys.first).to eql(:first_name)
    end

    after(:each) do
      @source = nil
    end
  end

  context 'premapped_2' do

    before(:each) do
      @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/premapped_2.xls"].join), :headers_present => "true", :type => "xls", :column_separator => "", :record_separator => "",
        :user_headers => {:organization=>0, :salutation=>2, :first_name=>3, :last_name_prefix=>4, :last_name=>5, :street=>6, :zipcode=>9, :city=>10, :country=>11,
          :url=>12, :email=>13, :phone=>14, :notes=>18, :secondary_tags=>19, cached_tag_list: 24},
        :compulsory_headers => {:email => true}
      })
    end

    it "has correct mapping" do
      expect(@source.get_preview_lines.first.keys.first).to eql(:organization)
    end

    it "gets the correct number of preview lines" do
      expect(@source.get_preview_lines.count).to eql(1)
    end

    after(:each) do
      @source = nil
    end
  end

  context "it has only one line" do
    context "when mapping has not been set" do
      before(:each) do
        @source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/one_line.xls"].join), :headers_present => "true", :type => "xls", :column_separator => "", :record_separator => "",
          :compulsory_headers => {:email => true}
        })
      end

      it 'has the correct preview lines' do
        expect(@source.get_preview_lines.first[:Email]).to eql("mailto:john.smith@example.com")
      end

      after(:each) do
        @source = nil
      end
    end

    context "when mapping has been set" do
      before(:each) do
        @source = TableImporter::Source.new({content: File.open([Dir.pwd, "/spec/files/excel/one_line.xls"].join), headers_present: "true", type: "xls", column_separator: "", record_separator: "",
          compulsory_headers: {email: true}, user_headers: {"email" => "13"}
        })
      end

      it 'has the correct chunks' do
        expect(@source.get_chunks[0][:lines].first[:email]).to eql("mailto:john.smith@example.com")
      end

      after(:each) do
        @source = nil
      end
    end

    context 'when source has NULL values in it' do

      it "Skips the null values if specified" do
        source = TableImporter::Source.new({ content: File.open([Dir.pwd, "/spec/files/excel/null_values.xls"].join), :headers_present => false, :user_headers => { "email" => "0" }, :type => "xls", :column_separator => "", :record_separator => "", :compulsory_headers => { email: true }, remove_nil_values: true })
        expect(source.get_preview_lines.first[:column_2]).to eql(nil)
      end

      it "Doesn't skip the null values if not specified" do
        source = TableImporter::Source.new({:content => File.open([Dir.pwd, "/spec/files/excel/null_values.xls"].join), :headers_present => false, :user_headers => { "email" => "0" }, :type => "xls", :column_separator => "⁄", :record_separator => "", :compulsory_headers => { email: true }, remove_nil_values: false })
        expect(source.get_preview_lines.first[:column_2]).to eql("NULL")
      end
    end
  end
end
