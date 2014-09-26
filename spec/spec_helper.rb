require 'table_importer'
require 'rubygems'
require 'spork'
require 'active_support/all'
require 'coveralls'
require 'vcr'
Coveralls.wear!
require 'table_importer/exceptions'
require 'table_importer/source.rb'

Spork.prefork do

  # From rspec generator
  ENV["RAILS_ENV"] ||= 'test'
  require 'rspec/autorun'

  RSpec.configure do |config|
    config.order = "random"
  end

end
