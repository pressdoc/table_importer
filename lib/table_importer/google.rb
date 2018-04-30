module TableImporter

  class Google < RooSpreadsheetSource

    attr_accessor :remove_nil_values

    def initialize(data)
      begin
        @file = get_file(data[:content].split(", ")[1], data[:content].split(", ")[0])

        @headers_present    = data[:headers_present]
        @compulsory_headers = data[:compulsory_headers]
        @mapping            = data[:user_headers] if data[:user_headers].present?
        @remove_nil_values  = data[:remove_nil_values] == true

        @delete_empty_columns = false

        raise TableImporter::EmptyFileImportError.new if !@file.first_row

        @headers = @headers_present ? @file.row(1).map.with_index { |header, index| header.present? ? header.to_sym : "column_#{index}"} : default_headers
      rescue NoMethodError
        raise TableImporter::HeaderMismatchError.new
      end
    end

    def get_file(file_key, access_token)
      begin
        Roo::Google.new(file_key, { :access_token => access_token })
      rescue TypeError
        raise TableImporter::IncorrectFileError.new
      end
    end

    def get_type
      "google"
    end
  end
end
