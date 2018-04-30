# encoding: UTF-8
require 'smarter_csv'

module TableImporter

  class CSV < Source

    attr_accessor :remove_nil_values

    def initialize(data)
      @headers_present = data[:headers_present] # user has indicated headers are provided
      @column_separator, @record_separator = initialize_separators(data[:column_separator], data[:record_separator])
      @compulsory_headers = data[:compulsory_headers]
      @file = data[:content]
      @delete_empty_columns = File.size(@file) < 100000
      @remove_nil_values = data[:remove_nil_values] == true

      begin
        first_line = get_first_line
        if first_line == 0
          raise ArgumentError
        end
        get_column_separator(first_line)
        raise TableImporter::EmptyFileImportError.new unless file_has_content
        @mapping = data[:user_headers]
        @headers = @headers_present ? first_line.split(@column_separator) : default_headers(100)
      rescue ArgumentError
        @file = clean_file(@file)
        @column_separator = get_column_separator
        retry
      end
    end

    def initialize_separators(col_sep, rec_sep)
      col_sep = SEPARATORS[col_sep.to_sym] if !col_sep.nil?
      rec_sep = !rec_sep.nil? && rec_sep.length > 0 ? SEPARATORS[rec_sep.to_sym] : "\n"
      return col_sep, rec_sep
    end

    def get_first_line
      begin
        SmarterCSV.process(@file.path, default_options({:col_sep => @column_separator.present? ? @column_separator : "\n", :row_sep => @record_separator != nil ? @record_separator : "\n", :chunk_size => 2})) do |chunk|
          if @headers_present
            return line_count(chunk.first.keys)
          else
            return line_count(chunk.first.values)
          end
        end
      rescue EOFError
        raise TableImporter::EmptyFileImportError.new
      end
    end

    def line_count(vals)
      vals.count == 1 ? vals[0].to_s : vals.join(@column_separator)
    end

    def file_has_content
      begin
        lines = get_preview_lines
        if lines.blank? || lines == 0
          return false
        else
          return true
        end
      rescue NoMethodError
        false
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

    def get_preview_lines(start = 0, finish = 7, chunk_size = 8)
      begin
        SmarterCSV.process(@file.path, default_options({:row_sep => @record_separator != nil ? @record_separator : "\n", :chunk_size => chunk_size})) do |chunk|
          cleaned_chunk = clean_chunks([chunk], @compulsory_headers, @delete_empty_columns)[0].symbolize_keys[:lines]
          return cleaned_chunk[start..finish] if cleaned_chunk.first.present?
          @headers_present = false
          get_preview_lines(start+8, finish+8, chunk_size+8)
        end
      rescue SmarterCSV::HeaderSizeMismatch
        raise TableImporter::HeaderMismatchError.new
      end
    end

    # this is horrendously slow
    def get_lines(start, number_of_lines)
      get_chunks(50)[start..(start + number_of_lines)]
    end

    def get_chunks(chunk_size)
      begin
        chunks = @headers_present ? chunks_with_headers(chunk_size) : chunks_without_headers(chunk_size)
        clean_chunks(chunks, @compulsory_headers, @delete_empty_columns)
      rescue ArgumentError
        @file = clean_file(@file)
        @column_separator = get_column_separator
        retry
      end
    end

    def chunks_with_headers(chunk_size)
      key_mapping = convert_headers(SmarterCSV.process(@file.path, default_options).first.keys, @mapping, @headers_present).delete_if{ |key, value| value.blank?}
      SmarterCSV.process(@file.path, default_options({:chunk_size => chunk_size, :key_mapping => key_mapping, :remove_unmapped_keys => true, :user_provided_headers => nil}))
    end

    def chunks_without_headers(chunk_size)
      user_provided_headers = convert_headers(SmarterCSV.process(@file.path, default_options).first.keys, @mapping, @headers_present).values
      SmarterCSV.process(@file.path, default_options({:chunk_size => chunk_size, :user_provided_headers => user_provided_headers, :remove_empty_values => true}))
    end

    def convert_headers(provided_headers, mapped_headers, headers_present)
      new_headers = []
      old_headers = headers_present ? provided_headers : default_headers
      old_headers.each_with_index do |key, index|
        new_headers << map_headers(mapped_headers, index)
      end
      Hash[old_headers.zip(new_headers)]
    end

    def map_headers(mapped_headers, index)
      key_to_add = "column_#{index}".to_sym
      mapped_headers.each do |new_key, value|
        if value.to_s == index.to_s
          key_to_add = new_key
        end
      end
      key_to_add
    end

    def default_options(options = {})
      {
        :col_sep => @column_separator,
        :row_sep => @record_separator,
        :force_simple_split => true,
        :strip_chars_from_headers => /[\-"]/,
        :remove_empty_values => false,
        :verbose => false,
        :headers_in_file => @headers_present,
        :convert_values_to_numeric => false,
        :user_provided_headers => @headers_present ? (@headers == nil || @headers == {} ? nil : @headers) : default_headers(100)
      }.merge(options)
    end

    def clean_file(file)
      contents = file.read
      import = Tempfile.new(["import", ".xls"], :encoding => "UTF-8")
      utf8_content = contents.force_encoding('UTF-8').encode('UTF-16', :invalid => :replace, :replace => '?').encode('UTF-8').gsub(/\r\n|\r/, "\n").squeeze("\n")
      clean_contents = utf8_content[0] == "\n" ? utf8_content[1..-1] : utf8_content
      import.write(clean_contents)
      import.close
      reset_separators
      return import
    end

    def reset_separators
      SEPARATORS.except!(:newline_windows, :old_newline_mac)
      @record_separator = "\n"
      @column_separator = ""
    end
  end
end
