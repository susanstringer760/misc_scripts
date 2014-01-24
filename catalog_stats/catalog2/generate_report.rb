#!/bin/env ruby
#

require 'optparse'
require "rubygems"
require 'mysql2'
require "active_record"
require File.join(File.dirname(__FILE__), 'generate_report.include.rb')

if ( ARGV.length==0 )
  puts "USAGE: generate_report.pl -p [project_id]"
  exit
end

options = {:project_id => nil}

parser = OptionParser.new do|opts|
	opts.banner = "Usage: generate_report.rb [options]"
	opts.on('-n', '--project_id project_id', 'project id') do |project_id|
		options[:project_id] = project_id;
	end
end

parser.parse!

if options[:project_id] == nil
	print 'Enter Name: '
    options[:project_id] = gets.chomp
end

project_id = options[:project_id]

# load the models
load_models()
project_id = 382

# all the catalog datasets for this project
project_datasets = get_datasets(project_id)

category_hash = Hash.new{|hash, key| hash[key] = Array.new}
project_datasets.each {|d| 
  category = d.categories[0]
  category_hash[category.short_name].push(d) 
}

category_hash.each_key {|category|
  puts "#{category}: #{category_hash[category].length}"
}
