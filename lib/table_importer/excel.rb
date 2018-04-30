module TableImporter

  class Excel < RooSpreadsheetSource

    attr_accessor :remove_nil_values

    def initialize(data)
      begin
        @type = File.extname(data[:content]) == ".xls" ? "xls" : "xlsx"
        @headers_present = data[:headers_present]
        @file = get_file(data[:content].path)
        @compulsory_headers = data[:compulsory_headers]
        @delete_empty_columns = (File.size(data[:content].path) < 100000)
        @mapping = data[:user_headers]
        @remove_nil_values = data[:remove_nil_values] == true

        raise TableImporter::EmptyFileImportError.new if !@file.first_row
        @headers = @headers_present ? @file.row(1).map.with_index { |header, index| header.present? ? header.to_sym : "column_#{index}"} : default_headers
      rescue NoMethodError
        raise TableImporter::HeaderMismatchError.new
      end
    end

    def get_file(path)
      begin
        if @type == "xls"
          Roo::Excel.new(path).sheet(0)
        elsif @type == "xlsx"
          Roo::Excelx.new(path).sheet(0)
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
