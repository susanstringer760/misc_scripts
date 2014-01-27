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

project_id = options[:project_id].to_i

# load the models
load_models()

# hash where key is category and value is arr of
# category datafiles
stats_hash = get_datafiles_by_category(project_id)

print_stats(stats_hash)
