def add_file(ret, db, data, html)
  ret.each do |name|
    site = 'http://mangafox.me/'
    if name.size != 1
      site == name[1]
    end
    if db.manga_in_data?(name[0]) == true && data == false
      puts name[0] + ' is already in database'
    else
      if site != 'http://mangafox.me/'
        puts 'sorry, MangaScrap does not deal with other sites than mangafox ( yet )'
        exit 4
      else
        if get_mf_class(db, name[0], data) == nil
          puts 'adding next element'
        end
        html.generate_chapter_index(name[0], false)
      end
    end
  end
end

def add(db, data)
  html = HTML.new(db)
  if ARGV.size == 1
    puts 'not enough arguments'
    exit 5
  end
  manga_name = ARGV[1]
  site = 'http://mangafox.me/'
  file = false
  if ARGV.size > 2
    ret = get_mangas
    if ret != nil
      file = true
      add_file(ret, db, data, html)
    else
      site = ARGV[2]
    end
  end
  unless file
    if db.manga_in_data?(manga_name) && data == false
      puts manga_name + ' is already in database'
    else
      if site != 'http://mangafox.me/'
        puts 'sorry, MangaScrap does not deal with other sites than mangafox ( yet )'
        exit 4
      else
        if get_mf_class(db, manga_name, data) == nil
          exit 3
        end
        html.generate_chapter_index(manga_name, false)
      end
    end
  end
  html.generate_index
  puts 'done'
end
