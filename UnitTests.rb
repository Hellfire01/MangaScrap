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


# get arguments from ARGV
verbose = true
high_verbose = false

# used to display an error if the file could not be loaded
module Unit_tests_API
  def self.require_file(file)
    begin
      require_relative file
    rescue LoadError => e
      puts 'Error while loading ' + file + '.rb'
      puts 'Message is : ' + e.message
      puts 'Error class is : ' + e.message
      return false
    end
    true
  end
end

puts 'starting unit tests' if verbose
puts '' if verbose
if !Unit_tests_API::require_file('sources/unitTests/Init') ||
!Unit_tests_API::require_file('sources/unitTests/Database') ||
!Unit_tests_API::require_file('sources/unitTests/Web')
  exit 1
end

init = UT_Init.new(verbose, high_verbose)
init.run
