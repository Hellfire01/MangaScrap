def add(db)
  if ARGV.size < 2
    abort ('not enough arguments')
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
        abort ("sorry, MangaScrap does not deal with other sites than mangafox ( yet )")
      else
        Download_mf.new(db, manga_name)
      end
    end
  else
    ret.each do |name|
      if (name.size == 1)
        site = "http://mangafox.me/"
      else
        site == name[1]
      end      
      if db.manga_in_data?(name[0]) == true
        puts name[0] + " is already in database"
      else
        if (site != "http://mangafox.me/")
          abort ("sorry, MangaScrap does not deal with other sites than mangafox ( yet )")
        else
          Download_mf.new(db, name[0])
        end
      end
    end
  end
end
