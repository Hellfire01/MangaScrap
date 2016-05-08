#!/usr/bin/env ruby
# coding: utf-8

require 'open-uri'
require 'nokogiri'
require 'sqlite3'
require_relative 'utils'
require_relative 'download'
require_relative 'db'
require_relative 'update'
require_relative 'help'
require_relative 'add'
require_relative 'list'

work_dir = Dir.home + "/Documents/mangas/"

dir_create(work_dir)
db = DB.new()

if ARGV.size == 0
  update(db, work_dir)
else
  case ARGV[0]
  when "-u", "--update"
    update(db, work_dir)
  when "-a", "--add"
    add(db, work_dir)
  when "-dl", "--download"
    download(db, work_dir)
  when "-l", "--list"
    list(db)
  when "-d", "--delete"
    if (ARGV.size < 2)
      puts "need a manga's name to delete"
    elsif (ARGV.size == 2)
      db.delete_manga(ARGV[1])
      puts "deleted #{ARGV[1]} from database"
    else
      ret = get_mangas()
      if (ret != nil)
	ret.each do |name|
	  db.delete_manga(name[0])
	  puts "deleted #{name[0]} from database"
	end
      else
	abort("error while trying to get content of file ( -t option )")
      end
    end
  when "-h", "--help"
    help()
  else
    puts "error, unknown instruction : " + ARGV[0]
    puts "--help for help"
  end
end
