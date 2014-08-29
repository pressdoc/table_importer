# encoding: UTF-8

module TableImporter

  class CSV < Source

    def initialize(data)
      @headers_present = data[:headers_present] # user has indicated headers are provided
      @headers = data[:headers]
      @column_separator = SEPARATORS[data[:column_separator].to_sym] if !data[:column_separator].nil?
      @record_separator = !data[:record_separator].nil? && data[:record_separator].length > 0 ? SEPARATORS[data[:record_separator].to_sym] : "\n"
      @compulsory_headers = data[:compulsory_headers]
      @file = data[:content]
      @delete_empty_columns = File.size(@file) < 100000
      begin
        first_line = get_first_line
        if first_line == 0
          raise ArgumentError
        end
        get_column_separator(first_line)
        @preview_lines = file_has_no_content
        @headers = @headers_present ? first_line.split(@column_separator) : default_headers(100) if @headers.blank?
      rescue ArgumentError
        @file = clean_file(@file)
        retry
      end
    end

    def get_first_line
      begin
        SmarterCSV.process(@file.path, default_options({:col_sep => @column_separator.present? ? @column_separator : "\n", :row_sep => @record_separator != nil ? @record_separator : "\n", :chunk_size => 8})) do |chunk|
          if @headers_present
            return chunk.first.keys[0].to_s
          else
            return chunk.first.values[0].to_s
          end
        end
      rescue EOFError
        raise Exceptions::EmptyFileImportError.new
      end
    end

    def file_has_no_content
      begin
        lines = get_preview_lines
        if lines.blank? || lines == 0
          raise Exceptions::EmptyFileImportError.new
        else
          return lines
        end
      rescue NoMethodError
        raise Exceptions::EmptyFileImportError.new
      end
    end

    def get_type
      "csv"
    end

    def get_headers
      @headers
    end

    def get_column_separator(first_line = get_first_line)
      return @column_separator if !@column_separator.nil? && @column_separator.length > 0
      separators = get_sep_count(first_line)
      separators.reject!{ |sep| sep.keys[0] == @record_separator} if @record_separator != nil
      @column_separator = sort_separators(separators)
    end

    def get_record_separator(first_line = get_first_line)
      return @record_separator if !@record_separator.nil? && @record_separator.length > 0
      separators = get_sep_count(first_line)
      separators.reject!{ |sep| sep.keys[0] == get_column_separator}
      @record_separator = sort_separators(separators)
    end

    def get_preview_lines
      begin
        return clean_chunks([@preview_lines], @compulsory_headers, @delete_empty_columns)[0].symbolize_keys[:lines] if !@preview_lines.blank?
        if @delete_empty_columns
          chunks = SmarterCSV.process(@file.path, default_options({:row_sep => @record_separator != nil ? @record_separator : "\n", :chunk_size => 50}))
          return clean_chunks(chunks, @compulsory_headers, true)[0].symbolize_keys[:lines][0..7]
        end
        SmarterCSV.process(@file.path, default_options({:row_sep => @record_separator != nil ? @record_separator : "\n", :chunk_size => 8})) do |chunk|
          return clean_chunks([chunk], @compulsory_headers)[0].symbolize_keys[:lines][0..7]
        end
      rescue SmarterCSV::HeaderSizeMismatch
        raise Exceptions::HeaderMismatchError.new
      end
    end

    # this is horrendously slow
    def get_lines(start, number_of_lines)
      get_chunks(50)[start..(start + number_of_lines)]
    end

    def get_chunks(chunk_size)
      begin
        chunks = []
        if @headers_present
          key_mapping = convert_headers(SmarterCSV.process(@file.path, default_options).first.keys, @headers, @headers_present).delete_if{ |key, value| value.blank?}
          chunks = SmarterCSV.process(@file.path, default_options({:chunk_size => chunk_size, :key_mapping => key_mapping, :remove_unmapped_keys => true, :user_provided_headers => nil}))
        else
          user_provided_headers = convert_headers(SmarterCSV.process(@file.path, default_options).first.keys, @headers, @headers_present).values
          chunks = SmarterCSV.process(@file.path, default_options({:chunk_size => chunk_size, :user_provided_headers => user_provided_headers, :remove_empty_values => true}))
        end
        clean_chunks(chunks, @compulsory_headers, @delete_empty_columns)
      rescue ArgumentError
        @file = clean_file(@file)
        retry
      end
    end

    def convert_headers(provided_headers, mapped_headers, headers_present)
      new_headers = []
      old_headers = headers_present ? provided_headers : default_headers
      old_headers.each_with_index do |key, index|
        key_to_add = "column_#{index}".to_sym
        mapped_headers.each do |new_key, value|
          if value.to_s == index.to_s
            key_to_add = new_key
          end
        end
        new_headers << key_to_add
      end
      Hash[old_headers.zip(new_headers)]
    end

    # fix quote_char
    # bit of a hack here to provide the correct number of default headers to the user (rather than just 100)
    def default_options(options = {})
      {:col_sep => @column_separator, :row_sep => @record_separator, :quote_char => "‱", :remove_empty_values => false,
        :verbose => false, :headers_in_file => @headers_present, :convert_values_to_numeric => false,
        :user_provided_headers => @headers_present ? (@headers == nil || @headers == {} ? nil : @headers) : default_headers(100)}.merge(options)
    end

    def clean_file(file)
      contents = file.read
      import = Tempfile.new(["import", ".xls"], :encoding => "UTF-8")
      import.write(contents.force_encoding('UTF-8').encode('UTF-16', :invalid => :replace, :replace => '?').encode('UTF-8').gsub!(/\r\n|\r/, "\n"))
      import.close
      return import
    end
  end
end
