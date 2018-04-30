module TableImporter

  class CopyAndPaste < Source

    attr_accessor :remove_nil_values

    def initialize(data)
      @data = assign_data(data[:content])
      @column_separator, @record_separator = assign_separators(data[:column_separator], data[:record_separator])
      @headers, @headers_present = assign_headers(data[:headers_present])
      @mapping = data[:user_headers]
      @compulsory_headers = data[:compulsory_headers]
      @delete_empty_columns = @data.length < 50000
      @remove_nil_values = data[:remove_nil_values] == true
    end

    def assign_data(content)
      raise TableImporter::EmptyFileImportError.new if content.blank? || content[0..100].gsub(/[^A-Za-z0-9]/, '').blank?
      content.gsub!(/\r\n|\r/, "\n")
      return content
    end

    def assign_separators(col_sep, rec_sep)
      col_sep = SEPARATORS[col_sep.to_sym] if !col_sep.nil?
      rec_sep = SEPARATORS[rec_sep.to_sym] if !rec_sep.nil?
      col_sep, rec_sep = data_conforms_pattern(col_sep, rec_sep)
    end

    def data_conforms_pattern(col_sep, rec_sep)
      # Check to see if data is of bcc style
      first_item = @data.split("\n")[1]
      if first_item.present? && first_item.match(/\S@\S/) && !first_item.match(/;|,|\s/)
        rec_sep ||= "\n"
        col_sep ||= " "
      end
      first_item = @data.split(",").first
      if first_item.present? && first_item.match(/\S@\S/)
        if first_item.match(/<(\S+@\S+)/)
          rec_sep ||= ">, "
          col_sep ||= " <"
        end
      end
      return col_sep, rec_sep
    end

    def assign_headers(headers_present)
      headers = headers_present ? get_first_line : get_headers
      return headers, headers_present
    end

    def get_first_line
      @data.split(get_record_separator).first.split(get_column_separator).map(&:to_sym)
    end

    def get_type
      "copy_and_paste"
    end

    def get_headers
      return @headers if @headers.present?
      default_headers(100)
    end

    def get_preview_lines(start_point = @headers_present ? 1 : 0, end_point = 10)
      begin
        lines = clean_chunks([get_lines(start_point, end_point)], {}, @delete_empty_columns)[0][:lines]
        if lines.first.nil?
          get_preview_lines(start_point+10, end_point+10)
        else
          lines[0..7]
        end
      rescue StandardError
        raise TableImporter::EmptyStringImportError.new
      end
    end

    def get_lines(start_point, number_of_lines)
      number_of_lines = number_of_lines - 1 if number_of_lines != -1 # -1 means return all lines.
      mapped_lines = []
      get_column_separator
      @data.split(get_record_separator).each do |line|
        split_line = line.split(@column_separator)
        split_line = remove_whitespace(split_line)
        mapped_lines << Hash[@headers.zip split_line]
      end
      mapped_lines[start_point..(start_point+number_of_lines)]
    end

    def remove_whitespace(column)
      column.each do |column_item|
        column_item.strip!
      end
      column
    end

    def get_chunks(chunk_size)
      @headers = convert_headers(get_first_line, @mapping.present? ? @mapping : @headers, @headers_present)
      lines = get_lines(0, -1).in_groups_of(chunk_size, false)
      clean_chunks(lines, @compulsory_headers)
    end

    def convert_headers(provided_headers, mapped_headers, headers_present)
      new_headers = headers_present ? provided_headers : default_headers
      new_headers = default_headers(new_headers.count)
      mapped_headers.each do |key, value|
        if value.to_i.to_s == value
          new_headers[value.to_i] = key.to_sym
        end
      end
      new_headers
    end

    def get_column_separator(first_line = @data)
      return @column_separator if !@column_separator.nil? && @column_separator.length > 0
      separators = get_sep_count(first_line)
      separators.reject!{ |sep| sep.keys[0] == @record_separator} if @record_separator != nil
      @column_separator = sort_separators(separators)
    end

    def get_record_separator(first_line = @data)
      return @record_separator if !@record_separator.nil? && @record_separator.length > 0
      separators = get_sep_count(first_line)
      separators.reject!{ |sep| sep.keys[0] == get_column_separator}
      @record_separator = sort_separators(separators)
    end
  end
end
