#!/usr/bin/env ruby
# coding: utf-8

require_relative '../sources/../sources/init'

$0="MangaScrap's mangafox migration"

def get_mangafox_mangas(db)
  db.exec_query('SELECT * FROM manga_list WHERE site=? ORDER BY name COLLATE NOCASE', 'error while getting the manga list', ['http://mangafox.la/'])
end

def update_mangafox_mangas(db, mangas)
  if mangas.size != 0
    puts 'updating + ' + mangas.size.to_s + ' mangas(s)'
    i = 1
    mangas.each do |manga|
      puts 'updating ' + i.to_s + ' / ' + mangas.size.to_s + '   ' + manga[1]
      # update website
      # update link
      args = ['http://fanfox.net/', manga[4].gsub('mangafox.la', 'fanfox.net'), manga[0]]
      if args[1][-1, 1] != '/'
        args[1] += '/'
      end
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
