def add_file(ret, db)
  ret.each do |name|
    site = "http://mangafox.me/"
    if (name.size != 1)
      site == name[1]
    end
    if db.manga_in_data?(name[0]) == true
      puts name[0] + " is already in database"
    else
      if (site != "http://mangafox.me/")
        puts "sorry, MangaScrap does not deal with other sites than mangafox ( yet )"
        exit 4
      else
        Download_mf.new(db, name[0])
      end
    end
  end
end

def add(db)
  if ARGV.size < 2
    puts 'not enough arguments'
    exit 5
  end
  manga_name = ARGV[1]
  site = "http://mangafox.me/"
  file = false
  if (ARGV.size > 2)
    ret = get_mangas()
    if (ret != nil)
      file = true
    else
      site = ARGV[2]
    end
  end
  if (file == false)
    if db.manga_in_data?(manga_name) == true
      puts manga_name + " is already in database"
    else
      if (site != "http://mangafox.me/")
        puts "sorry, MangaScrap does not deal with other sites than mangafox ( yet )"
        exit 4
      else
        Download_mf.new(db, manga_name)
      end
    end
  else
    add_file(ret, db)
  end
end
