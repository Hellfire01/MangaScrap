#!/usr/bin/env ruby
# coding: utf-8

=begin

The unit tests are present to ensure that MangaScrap works correctly
it tests the installation and the environment

return values are :
0 : good
1 : file load error
2 : gem load error
3 : bad Ruby versionw
4 : bad argument given to UnitTests.rb
5 : error on class require

=end


##################################################################################
##################################################################################
# note : faire usage de bases de données temporaires pour tester toutes les
#        fonctionnalités de l'API de MangaScrap
##################################################################################
##################################################################################

puts 'needs to be updated'
exit 42

verbose = false
if ARGV.size != 0
  if ARGV[0] == 'verbose'
    verbose = true
  else
    puts 'unknown argument : "' + ARGV[0] + '"'
    exit 4
  end
end

def UnitTest_require_file(file)
  begin
    require_relative file
  rescue LoadError => e
    puts 'Error while loading ' + file + '. Message is : ' + e.message
    return false
  end
  true
end

def UnitTest_load_gem(gem)
  begin
    require gem
  rescue LoadError => e
    puts 'Error while loading the ' + gem + ' gem. Message is : ' + e.message
    return false
  end
  true
end


puts '====> Unit tests'
puts ''

puts '====> 1 - requiring init file'
begin
  if verbose
    puts 'requiring sources/init.rb'
  end
  require_relative 'sources/init'
rescue LoadError => e
  puts 'Error while loading the init file (it should have been at : ' + Dir.pwd + '/sources/init.rb)'
  puts 'aborting'
  exit 1
end
puts 'ok'
puts ''

puts '====> 2 requiring all gems'
failure = false
Init::get_gem_list.each do |gem|
  if verbose
    puts 'requiring ' + gem
  end
  failure = !(UnitTest_load_gem gem || failure)
end
if failure
  puts 'aborting'
  exit 2
end
puts 'ok'
puts ''

puts '====> 3 requiring all MangaScrap files'
failure = false
Init::get_file_list.each do |file|
  if verbose
    puts 'requiring sources/' + file
  end
  failure = !(UnitTest_require_file('sources/' + file) || failure)
end
puts 'ok'
puts ''

Struct.new('Arg', :name, :sub_args, :nb_args, :does_not_need_args?)
Struct.new('Sub_arg', :name, :nb_args)
Struct.new('Updated', :name, :downloaded)
Struct.new('Query_arg', :name, :arg_type, :sql_column, :sub_string)
Struct.new('HTML_data', :volume, :chapter, :date, :href, :nb_pages, :file_name)

puts '====> 4 getting the database'
begin
  params = Manga_database.instance.get_manga_list
  pp params
rescue Exception => e
  puts 'Error'
  pp e.class.to_s
  pp e.message
  exit 5
end
puts 'ok'
puts ''

puts '====> 5 getting the params'
begin
  params = Params.instance.get_params
  pp params
rescue Exception => e
  puts 'Error'
  pp e.class.to_s
  pp e.message
  exit 5
end
puts 'ok'
puts ''

puts '====> all good'
