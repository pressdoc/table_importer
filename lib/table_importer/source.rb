module TableImporter

  class Source

    SEPARATORS = {comma: ",", space: " ", tab: "\t", newline_mac: "\n", semicolon: ";", newline_windows: "\r\n", old_newline_mac: "\r"}

    def initialize (data)
      case data[:type]
      when 'copy_and_paste'
        @source = CopyAndPaste.new(data)
      when 'csv'
        @source = CSV.new(data)
      when 'xls', 'xlsx'
        @source = Excel.new(data)
      else
        raise TableImporter::IncorrectFileError.new
      end
      @source
    end

    def get_type
      @source.get_type
    end

    def get_column_separator(first_line = "")
      SEPARATORS.key(@source.get_column_separator(first_line))
    end

    def get_record_separator(first_line = "")
      SEPARATORS.key(@source.get_record_separator(first_line))
    end

    def get_headers
      @source.get_headers
    end

    def get_lines(start_point = 0, number = -1)
      @source.get_lines(start_point, number)
    end

    def get_preview_lines
      @source.get_preview_lines
    end

    def get_chunks(chunk_size = 50)
      @source.get_chunks(chunk_size)
    end

    def default_headers(number = 100)
      return @default_headers if @default_headers
      @default_headers = 1.upto(number).collect do |n|
        "column_#{n}".to_sym
      end
    end

    def get_sep_count(first_line)
      SEPARATORS.values.collect do |sep|
        {sep => first_line.scan(sep).count}
      end
    end

    def sort_separators(separators)
      highest_value = 0
      highest_key = ""
      separators.each do |sep|
        if sep.values[0] >= highest_value
          highest_value = sep.values[0]
          highest_key = sep.keys[0]
        end
      end
      highest_key
    end

    def clean_chunks(chunks, compulsory_headers = {}, delete_empty_columns = false)
      result = []
      empty_headers = chunks.first.first.keys
      chunks.each do |chunk|
        new_chunk = { :lines => [], :errors => []}
        chunk.each_with_index do |line, index|
          line, line_empty = line_empty?(line)
          no_compulsory_headers, missing_header = check_compulsory_headers?(line, compulsory_headers)
          if line_empty || no_compulsory_headers
            new_chunk[:errors] << format_error(line, line_empty, no_compulsory_headers, compulsory_headers, missing_header)
          else
            if delete_empty_columns
              line.each do |key, value|
                if value.present? && value.to_s.gsub(/[^A-Za-z0-9]/, '').present?
                  empty_headers.delete(clean_item(key).to_sym)
                end
              end
            end
            new_chunk[:lines] << line
          end
        end
        result << new_chunk unless new_chunk[:lines] == [] && new_chunk[:errors] == []
      end
      if delete_empty_columns
        remove_empty_columns(result, empty_headers)
      end
      result
    end

    private
      def line_empty?(line)
        line = clean_line(line)
        return line, line.all?{ |item_key, item_value| line_item_is_garbage?(item_value)} && line.all?{ |item_key, item_value| line_item_is_garbage?(item_key)}
      end

      def clean_line(line)
        map = {}
        line.each_pair do |key,value|
          map[clean_item(key).to_sym] = clean_item(value)
        end
        map
      end

      def clean_item(item)
        item.to_s.delete("\u0000").to_s.delete("\x00")
      end

      def check_compulsory_headers?(line, compulsory_headers)
        if compulsory_headers.key?(:email)
          if line.key?(:email)
            line[:email] = clean_email(line[:email])
            return true, "email" if line[:email].nil? || !line[:email].to_s.match(/@\S/)
          end
          return true, "email" if !line.values.any?{ |value| /@\S/ =~ value.to_s }
        end
        # here perform other checks for other compulsory headers we might have.
        return false
      end

      def clean_email(email)
        if email
          email.to_s.gsub(/\A[^A-Za-z0-9]/, '').reverse.gsub(/\A[^A-Za-z0-9]/, '').reverse
        end
      end

      def line_item_is_garbage?(item_value)
        item_value.blank?
      end

      def format_error(line, line_empty, no_compulsory_headers, compulsory_headers, missing_header)
        message = line_empty ? "it did not have any content" : " it did not contain this/these required headers: #{missing_header}"
        {:level => :error, :message => "The following line was not imported because #{message}.", :data => {:line => line, :line_empty => line_empty, :headers => no_compulsory_headers}}
      end

      def remove_empty_columns(chunks, headers)
        chunks.each do |chunk|
          unless chunk[:lines].empty?
            headers.each do |header|
              chunk[:lines][0][header] = "empty_column"
            end
          end
        end
        chunks
      end
  end
end

require 'table_importer/csv'
require 'table_importer/copy_and_paste'
require 'table_importer/excel'
require 'table_importer/exceptions'
