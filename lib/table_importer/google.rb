module TableImporter

  class Google < RooSpreadsheetSource

    def initialize(data)
      begin
        @headers_present = data[:headers_present]
        @file = get_file(data[:content].split(", ")[1], data[:content].split(", ")[0])
        @compulsory_headers = data[:compulsory_headers]
        @delete_empty_columns = false
        @mapping = !data[:user_headers].blank? ? data[:user_headers] : data[:headers]
        raise TableImporter::EmptyFileImportError.new if !@file.first_row
        if !data[:headers].nil?
          @headers = data[:headers]
        else
          @headers = @headers_present ? @file.row(1).map.with_index { |header, index| header.present? ? header.to_sym : "column_#{index}"} : default_headers
        end
      rescue NoMethodError
        raise TableImporter::HeaderMismatchError.new
      end
    end

    def get_file(file_key, access_token)
      begin
        Roo::Google.new(file_key, {:access_token => access_token})
      rescue TypeError
        raise TableImporter::IncorrectFileError.new
      end
    end

    def get_type
      "google"
    end
  end
end
