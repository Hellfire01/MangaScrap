#!/usr/bin/env ruby
# coding: utf-8

# thanks for downloading MangaScrap !
# if you have a question, please go here :
# https://github.com/Hellfire01/MangaScrap
#
# Note :
# MangaScrap will install it's databases and templates
# in ~/.MangaScrap
#
# MangaScrap's return values :+
# 0 : good
# 1 : fatal error ( ruby native code exceptions )
# 2 : db error
# 3 : connection error
# 4 : unexpected error ( not yet managed stuff )
# 5 : argument error
# 6 : gem error

require 'singleton'
require 'open-uri'
require 'pp'

def load_gem(gem)
  begin
    require gem
  rescue Exception => e
    puts ''
    puts "exception while trying to load #{gem}, please follow the installation instructions in the install directory"
    puts 'message is : ' + e.message
    puts 'please note that a ruby update may require a re-download of the gems'
    puts ''
    exit 6
  end
end

# gems
load_gem 'colorize'
load_gem 'nokogiri'
load_gem 'sqlite3'

# files
require_relative 'sources/init'
require_relative 'sources/scan/scan'
require_relative 'sources/scan/scan_utils'
require_relative 'sources/instructions/delete_diff'
require_relative 'sources/instructions/basic_instructions'
require_relative 'sources/instructions/params'
require_relative 'sources/instructions/redl'
require_relative 'sources/utils/utils_file'
require_relative 'sources/utils/utils_args'
require_relative 'sources/utils/utils_co'
require_relative 'sources/utils/utils_manga'
require_relative 'sources/utils/utils_html'
require_relative 'sources/utils/utils_debug'
require_relative 'sources/Classes/html/html'
require_relative 'sources/Classes/html/html_buffer'
require_relative 'sources/Classes/Download/mangafox'
require_relative 'sources/Classes/DownloadDisplay'
require_relative 'sources/Classes/instructions/Parsers/Instruction_parser'
require_relative 'sources/Classes/instructions/Parsers/Data_parser'
require_relative 'sources/Classes/instructions/Parsers/Query_Parser'
require_relative 'sources/Classes/instructions/Parsers/File_parser'
require_relative 'sources/Classes/instructions/query'
require_relative 'sources/Classes/instructions/Instructions_exec'
require_relative 'sources/Classes/instructions/Manga_data_filter'
require_relative 'sources/Classes/DB/Manga_data'
require_relative 'sources/Classes/DB/Manga_database'
require_relative 'sources/Classes/DB/Params'

initialize_mangascrap

args = Instructions_exec.new
args.run

