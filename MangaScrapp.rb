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
require_relative 'delete'
require_relative 'params'

db = DB.new()
init_utils(db)
dir_create(db.get_params[1])
puts ""

if ARGV.size == 0
  update(db, work_dir)
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
    param_list(db)
  when "-ps", "--param_set"
    param_set(db)
  when "-pr", "--param_reset"
    param_reset(db)
  when "-h", "--help"
    help()
  else
    puts "error, unknown instruction : " + ARGV[0]
    puts "--help for help"
  end
end
