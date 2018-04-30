[![Gem Version](https://badge.fury.io/rb/table_importer.svg)](http://badge.fury.io/rb/table_importer) [![Build Status](https://travis-ci.org/pressdoc/table_importer.svg?branch=master)](https://travis-ci.org/pressdoc/table_importer) [![Coverage Status](https://coveralls.io/repos/pressdoc/table_importer/badge.png?branch=master)](https://coveralls.io/r/pressdoc/table_importer?branch=master) [![Code Climate](https://codeclimate.com/github/pressdoc/table_importer/badges/gpa.svg)](https://codeclimate.com/github/pressdoc/table_importer)

==============
Table Importer
==============

Given a file (or a string) containing a container, along with options, it will return a hash of those values. Great for importing poorly formatted CSV files. It can handle CSV, Excel (xls and xlsx), Google Drive Spreadsheet, and a copy and pasted string.

Only works  for ruby versions >= 1.9.3.

# Contributing to Table Importer

We love your contributions to Table Importer. Before submitting a pull request, please make sure that your changes are well tested.

Then, you'll need to install bundler and the gem dependencies:

  `gem install bundler && bundle install`

You should now be able to run the local tests:

  `bundle exec rake`

Interact with table_importer by creating a TableImporter instance, and then calling methods on that instance.

  `importer = TableImporter::Source.new({options})`

The options you pass in are:

```
  # The type of the spreadsheet/input you want to import
  :type => "google" # Google Drive spreadsheet
        => "csv" # CSV file
        => "xls" # Excel spreadsheet
        => "copy_and_paste" # Copy and pasted input
  
  # The content to input. Either a file, a string, or google oauth keys.
  :content => File.open("path/to/file") # for types csv, xls
           => "Name, Email, Phone Number
              Nick, nick@example.com, 6412345678" # For type copy_and_paste
           =>  "google_access_token, spreadsheet_id" # For type google
  
  # Whether the first row of input contains column headers
  :headers_present => true # First row of input is headers
                   => false # First row of input is not headers

  # Optionally you can provide mapping for the columns. (This can be incomplete).
  :user_headers => {
                      "email"=>"0", 
                      "organization"=>"4", 
                      "url"=>"9"
                   }
  # Used to separate columns. Pass in 'nil' if using Google Spreadsheet, Excel or you don't know.
  :column_separator => :comma # ','
                    => :space # ' '
                    => :tab # '\t'
                    => :semicolon # ';'
                       
  # Used to separate rows. Pass in 'nil' if using Google Spreadsheet, Excel or you don't know.
  :record_separator => :newline_mac # '\n'
                    => :newline_windows # '\r\n'
                    => :old_newline_mac # '\r' (from OSX 9 days)
  
  # A hash of compulsory headers. At the moment only "email" is supported.
  :compulsory_headers => {
                            :email => true, false # Does each record require an email address to be valid?
                          }

  # Whether nil values that are a string (ie strings that equal "NULL", "null", "nil", or "undefined") should be replaced with actual nil values.
  :remove_nil_values => true
  :remove_nil_values => false
  
```

There are a few ways to interact with the table importer:

```
  options = { type: "csv",  }
  importer = TableImporter::Source.new(options)

  # get the type
  puts importer.get_type
    => "csv"
    
  # get the column separator
  puts importer.get_column_separator
    => "semicolon"
    
  # get the row separator
  puts importer.get_record_separator
    => "newline_mac"
    
  # Get the headers (either the first row if headers are provided, or else default headers
  puts importer.get_headers
   => "column_1, column_2, column_3"
  
  # Get the first 8 lines (useful for providing a matching option for the user to map their own headers, like Mailchimp's contact import.
  puts importer.get_preview_lines
    => [{:column_1 => "r1c1", :column_2 => "r1c2", :column_3 => "r1c3"}, {:column_1 => "r2c1", :column_2 => "r2c2", :column_3 => "r2c3"} etc]
  
  # Get input chunked in an input size (size defaults to 50)
  puts importer.get_chunks
    => All input chunked into 50 line blocks.
  
  puts importer.get_chunks(25)
    => All input chunked into 25 line blocks.
  
  # The format for the returned chunks is not a simple array of hashes, like get_preview_lines, as it also includes per-row errors
  puts importer.get_chunks(2)
    => [{:lines => [{:column_1 => "r1c1", :column_2 => "r1c2", :column_3 => "r1c3"}, {:column_1 => "r2c1", :column_2 => "r2c2", :column_3 => "r2c3"}], :errors => []}, {:lines => [{:column_1 => "r3c1", :column_2 => "r3c2", :column_3 => "r3c3"}, {:column_1 => "r4c1", :column_2 => "r4c2", :column_3 => "r4c3"}], :errors => []}]

  # The errors hash is for lines that don't contain the compulsory headers, are blank/empty, or the entire line contains no alphanumeric characters.

  # Gets lines of input returned in an array of hashes (doesn't work for CSV yet)
  # Pass in start and end points
  puts importer.get_lines(0, 1)
    => [{:column_1 => "r1c1", :column_2 => "r1c2", :column_3 => "r1c3"}]
  
  # Or let it default to getting all lines
  puts importer.get_lines
    => All of the lines
    
  puts importer.get_lines(5, 25) 
    => Line 5 up to line 25
    
  puts importer.get_lines(5, -1)
    => Line 5 to the end of the input.
    
