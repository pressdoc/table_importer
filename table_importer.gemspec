# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'table_importer/version'

Gem::Specification.new do |spec|
  spec.name          = "table_importer"
  spec.version       = TableImporter::VERSION
  spec.authors       = ["Nick Dowse"]
  spec.email         = ["nm.dowse@gmail.com"]
  spec.description   = %q{Given a file (or a string) containing a container, along with options, it will return a hash of those values. Great for importing poorly formatted CSV files.}
  spec.summary       = %q{Given a file (or a string) containing a container, along with options, it will return a hash of those values. Great for importing poorly formatted CSV files.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "spreadsheet", "0.9.1"
  spec.add_dependency 'roo'
  spec.add_dependency 'smarter_csv'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency 'activesupport', '~> 4.1.5'

end
