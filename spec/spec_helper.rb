require 'table_importer'
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'rubygems'
require 'active_support/all'
require 'table_importer/exceptions'


# From rspec generator
ENV["RAILS_ENV"] ||= 'test'
require 'rspec/autorun'
if ENV["RAILS_ENV"] == "test"
  ENV["CODECLIMATE_REPO_TOKEN"] = 'a64b61ae04b5803d17610e71b1c55ff99afa1e540fa05cde9077ad663b8eb242'
end
RSpec.configure do |config|
  config.order = "random"
end
