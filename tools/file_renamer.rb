#!/usr/bin/env ruby
# coding: utf-8

# this script should only be used if there is an issue with multiple file names
# please be very careful when using it

require 'singleton'
require 'sqlite3'
require_relative '../sources/DB/Params'
require_relative '../sources/DB/sub_params/params_module'
require_relative '../sources/DB/sub_params/Download'
require_relative '../sources/DB/sub_params/HTML'
require_relative '../sources/DB/sub_params/Misc'
require_relative '../sources/DB/sub_params/Threads'

if ARGV.size != 2
  puts 'this tool needs 2 arguments'
  puts '1 - pattern to replace'
  puts '2 - replacing pattern'
  exit 1
end

pattern_to_replace = ARGV[0]
replacing_pattern = ARGV[1]

def confirm_delete (pattern_to_replace, replacing_pattern)
  puts 'going to replace ' + pattern_to_replace + ' with ' + replacing_pattern + ' for all the pictures of all the mangas'
  puts "Write 'YES' to continue"
  ret = STDIN.gets.chomp
  puts ''
  if ret == 'YES'
    return true
  end
  false
end

unless confirm_delete(pattern_to_replace, replacing_pattern)
  puts 'cancelled modification'
  exit 0
end

# todo, enable the multi_sites
dirs = Dir[Params.instance.download[:manga_path] + '/mangafox/mangas/*']
dirs.delete_if {|dir| dir.include?('.jpg')}
dirs.sort.each do |dir|
  puts dir
  files = Dir[dir + '/*']
  files.sort.each do |file|
    if File.basename(file).include?(pattern_to_replace)
      puts 'replacing ' + file + ' with ' + file.gsub(pattern_to_replace, replacing_pattern)
      File.rename(file, file.gsub(pattern_to_replace, replacing_pattern))
    end
  end
end
