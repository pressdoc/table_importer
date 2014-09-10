module TableImporter

  class Excel < Source

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

    def get_headers
      @headers
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

    def get_preview_lines(start_point = 0, end_point = 10)
      begin
        lines = clean_chunks([get_lines(start_point, end_point)], @compulsory_headers)[0][:lines]
        if lines.first.nil?
          get_preview_lines(start_point+10, end_point+10)
        else
          @headers = @mapping.present? ? convert_headers : @headers
          lines[0..8]
        end
      rescue SystemStackError
        raise TableImporter::EmptyFileImportError.new
      end
    end

    def get_lines(start, number_of_lines)
      @last_row ||= @file.last_row
      finish = [@last_row, start + number_of_lines].min
      mapped_lines = []
      (start...finish).each do |row_number|
        mapped_lines << Hash[@headers.zip(@file.row(row_number))]
      end
      mapped_lines
    end

    def convert_headers
      new_headers = @headers_present ? @file.row(1) : default_headers
      new_headers = default_headers(new_headers.count)
      @mapping.each do |key, value|
        if value.to_i.to_s == value
          new_headers[value.to_i] = key.to_sym
        end
      end
      new_headers
    end

    def get_chunks(chunk_size)
      @headers = convert_headers
      @last_row ||= @file.last_row
      chunks = []
      start_point = @headers_present ? 2 : 1
      while chunks.count <= @last_row/chunk_size
        chunks << get_lines(start_point, chunk_size)
        start_point += chunk_size
      end
      chunks.last << Hash[@headers.zip(@file.row(@last_row))]
      clean_chunks(chunks, @compulsory_headers)
    end
  end
end
