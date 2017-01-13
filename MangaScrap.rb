#!/usr/bin/env ruby
# coding: utf-8

# thanks for downloading MangaScrap !
# if you have a question, please go here :
# https://github.com/Hellfire01/MangaScrap
#
# MangaScrap's return values :
# 0 : good
# 1 : fatal error ( ruby native code exceptions )
# 2 : db error
# 3 : connection error
# 4 : unexpected error ( not yet managed stuff )
# 5 : argument error

require 'singleton'
require 'open-uri'

# gems
require 'colorize'
require 'nokogiri'
require 'sqlite3'

require_relative 'Classes/html/html'
require_relative 'Classes/html/html_buffer'
require_relative 'Classes/Download/mangafox'
require_relative 'Classes/DownloadDisplay'
require_relative 'Classes/arguments/query'
require_relative 'Classes/arguments/argument_manager'
require_relative 'sources/scan/scan'
require_relative 'sources/scan/scan_utils'
require_relative 'sources/download'
require_relative 'sources/update'
require_relative 'sources/delete_diff'
require_relative 'sources/help'
require_relative 'sources/add'
require_relative 'sources/init'
require_relative 'sources/list'
require_relative 'sources/delete'
require_relative 'sources/params'
require_relative 'sources/clear'
require_relative 'sources/redl'
require_relative 'sources/html_manager'
require_relative 'sources/utils/utils_file'
require_relative 'sources/utils/utils_co'
require_relative 'sources/utils/utils_db'
require_relative 'sources/utils/utils_manga'
require_relative 'sources/utils/utils_html'
require_relative 'sources/utils/utils_debug'
require_relative 'Classes/DB/manga_db'
require_relative 'Classes/DB/params_db'

db = initialize_mangascrap(__dir__)

if ARGV.size == 0
  update(db)
else
  case ARGV[0]
  when '-u', '--update'
    update(db)
  when '-uf', '--update-fast'
    update(db, true)
  when '-a', '--add'
    add(db, false)
  when '-da', '--data'
    add(db, true)
  when '-ht', '--html'
    html_manager(db)
  when '-hti', '--html-index'
    HTML.new(db).generate_index
  when '-dl', '--download'
    download(db)
  when '-l', '--list'
    list(db)
  when '-d', '--delete'
    delete(db)
  when '-df', '--delete-files'
    delete(db, true)
  when '-pl', '--param_list'
    param_list
  when '-ps', '--param_set'
    param_set
  when '-pr', '--param_reset'
    param_reset
  when '-c', '--clear'
    clear(db)
  when '-redl', '--re-download'
    re_dl(db)
  #when '-sca', '--scan-add'
  #  scan(db, 'add')
  #when '-scc', '--scan-correct'
  #  scan(db, 'correct')
  when '-h', '--help'
    help
  else
    puts 'error, unknown instruction : ' + ARGV[0]
    puts '--help for help'
  end
end
