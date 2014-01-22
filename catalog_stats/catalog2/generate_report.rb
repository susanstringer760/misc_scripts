#!/bin/env ruby
#
require "rubygems"
require 'mysql2'
require "active_record"
require File.join(File.dirname(__FILE__), 'generate_report.include.rb')

# generate the field catalog stats
#
# load catalog models
load_models()

xx = get_categories()

#xx = Category.find(28)
puts "#{xx.class}"
