#!/usr/bin/env ruby
# coding: utf-8

# sqlite3 tables :
#
# manga_list(id, name, site, link, chapters)
# <name_of_manga>_todo(id, chapter, page, link)

require 'open-uri'
require 'nokogiri'
require 'sqlite3'
#todo => regarder s'il ne serait pas possible déplacer
# les require dans le code pour un gain de performances
require_relative 'utils'
require_relative 'download'
require_relative 'db'
require_relative 'update'
require_relative 'help'
require_relative 'add'
require_relative 'list'
require_relative 'delete'

work_dir = Dir.home + "/Documents/web_tests/"

dir_create(work_dir)
db = DB.new()

if ARGV.size == 0
  update(db)
else
  case ARGV[0]
  when "-u", "--update"
    abort('update')
    update(db)
  when "-a", "--add"
    abort('add')
    add(gb)
  when "-dl", "--download"
    download(db, work_dir)
  when "-l", "--list"
    abort('list')
    list(db)
  when "-d", "--delete"
    abort('delete')
    delete(bd)
  when "-h", "--help"
    help()
  else
    puts "error, unknown instruction : " + ARGV[0]
    puts "--help for help"
  end
end
