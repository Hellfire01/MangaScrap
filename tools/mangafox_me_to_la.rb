#!/usr/bin/env ruby
# coding: utf-8

require_relative '../sources/../sources/init'

$0="MangaScrap's mangafox migration"

def get_mangafox_mangas(db)
  db.exec_query('SELECT * FROM manga_list WHERE site=? ORDER BY name COLLATE NOCASE', 'error while getting the manga list', ['http://mangafox.me/'])
end

def update_mangafox_mangas(db, mangas)
  if mangas.size != 0
    puts 'updating + ' + mangas.size.to_s + ' mangas(s)'
    i = 1
    mangas.each do |manga|
      puts 'updating ' + i.to_s + ' / ' + mangas.size.to_s + '   ' + manga[1]
      # update website
      # update link
      args = ['http://mangafox.la', manga[4].gsub('mangafox.me', 'mangafox.la'), manga[0]]
      db.exec_query('UPDATE manga_list SET site=?, link=? WHERE id=?',
                    'could not update ' + manga[1], args)
      i += 1
    end
    puts ''
    puts 'done'
  else
    puts 'nothing to update'
  end
end

begin
  Init::initialize_mangascrap
  db = Manga_database.instance
  mangas = get_mangafox_mangas(db)
  update_mangafox_mangas(db, mangas)
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
