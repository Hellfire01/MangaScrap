#!/usr/bin/env ruby
# coding: utf-8

require 'open-uri'
require 'nokogiri'
require 'sqlite3'
require 'fileutils'

require_relative 'DB/manga_db'
require_relative 'DB/params_db'
require_relative 'mangafox/MF_download'
require_relative 'mangafox/MF_update'
require_relative 'sources/utils'
require_relative 'sources/update'
require_relative 'sources/help'
require_relative 'sources/add'
require_relative 'sources/list'
require_relative 'sources/delete'
require_relative 'sources/params'
require_relative 'sources/clear'

db = DB.new()
init_utils()

if ARGV.size == 0
  update(db)
else
  case ARGV[0]
  when "-u", "--update"
    update(db)
  when "-a", "--add"
    add(db)
  when "-dl", "--download"
    download(db)
  when "-l", "--list"
    list(db)
  when "-d", "--delete"
    delete(db)
  when "-pl", "--param_list"
    param_list()
  when "-ps", "--param_set"
    param_set()
  when "-pr", "--param_reset"
    param_reset()
  when "-c", "--clear"
    clear(db)
  when "-h", "--help"
    help()
  else
    puts "error, unknown instruction : " + ARGV[0]
    puts "--help for help"
  end
end
