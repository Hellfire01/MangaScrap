def add_file(ret, db, data)
  ret.each do |name|
    site = "http://mangafox.me/"
    if (name.size != 1)
      site == name[1]
    end
    if db.manga_in_data?(name[0]) == true && data == false
      puts name[0] + " is already in database"
    else
      if (site != "http://mangafox.me/")
        puts "sorry, MangaScrap does not deal with other sites than mangafox ( yet )"
        exit 4
      else
        if get_mf_class(db, name[0], data) == nil
          puts "adding next element"
        end
      end
    end
  end
end

def add(db, data)
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
    if db.manga_in_data?(manga_name) == true && data == false
      puts manga_name + " is already in database"
    else
      if (site != "http://mangafox.me/")
        puts "sorry, MangaScrap does not deal with other sites than mangafox ( yet )"
        exit 4
      else
        if get_mf_class(db, name[0], data) == nil
          exit 3
        end
      end
    end
  else
    add_file(ret, db, data)
  end
  puts "done"
end
