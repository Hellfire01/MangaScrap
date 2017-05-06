#!/usr/bin/env ruby
# coding: utf-8

=begin

thanks for downloading MangaScrap !
if you have a question, please go here :
https://github.com/Hellfire01/MangaScrap

Note :
MangaScrap will install it's databases and templates
in ~/.MangaScrap/

MangaScrap's return values :
0 : good
1 : fatal error ( ruby native code exceptions )
2 : db error
3 : connection error
4 : unexpected error ( not yet managed stuff )
5 : argument error
6 : gem error
7 : interrupted by user

API :
should you want to use your own gui or use MangaScrap your own way,
the api can be found in ./sources/api/

=end

require_relative 'sources/init'

begin
  Init::initialize_mangascrap
  args = Instructions_exec.new
  args.run ARGV
rescue Interrupt
  puts ''
  puts ''
  puts 'MangaScrap was interrupted by user'.magenta
  puts ''
  puts 'backtrace'.yellow + ' is :'
  pp $!.backtrace
  puts ''
  exit 7
end
