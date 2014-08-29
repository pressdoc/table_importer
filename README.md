[![Gem Version](https://badge.fury.io/rb/table_importer.svg)](http://badge.fury.io/rb/table_importer) [![Build Status](https://travis-ci.org/pressdoc/table_importer.svg?branch=master)](https://travis-ci.org/pressdoc/table_importer) [![Coverage Status](https://coveralls.io/repos/pressdoc/table_importer/badge.png?branch=master)](https://coveralls.io/r/pressdoc/table_importer?branch=master)

==============
Table Importer
==============

Given a file (or a string) containing a container, along with options, it will return a hash of those values. Great for importing poorly formatted CSV files.

Only works  for ruby versions >= 1.9.3.

# Contributing to Table Importer

We love your contributions to Table Importer. Before submitting a pull request, please make sure that your changes are well tested.

Then, you'll need to install bundler and the gem dependencies:

  `gem install bundler && bundle install`

You should now be able to run the local tests:

  `bundle exec rake`