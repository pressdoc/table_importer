module TableImporter

  class Excel < RooSpreadsheetSource

    def initialize(data)
      begin
        @type = File.extname(data[:content]) == ".xls" ? "xls" : "xlsx"
        @file_path = data[:content].path
        @headers_present = data[:headers_present]
        @file = get_file
        @compulsory_headers = data[:compulsory_headers]
        @delete_empty_columns = (File.size(@file_path) < 100000)
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

    def get_file
      begin
        if @type == "xls"
          Roo::Excel.new(@file_path).sheet(0)
        elsif @type == "xlsx"
          Roo::Excelx.new(@file_path).sheet(0)
        end
      rescue TypeError
        raise TableImporter::IncorrectFileError.new
      end
    end

    def get_type
      "xls"
    end
  end
end
