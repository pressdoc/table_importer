require 'coveralls'
require 'table_importer'
require 'rubygems'
require 'active_support/all'
require 'table_importer/exceptions'
Coveralls.wear!

  # From rspec generator
ENV["RAILS_ENV"] ||= 'test'
require 'rspec/autorun'

RSpec.configure do |config|
  config.order = "random"
end
