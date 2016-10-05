def download_file(ret, db)
  tab_dw = []
  tab_name = []
  ret.each do |manga|
    if (manga.size == 1)
      site = "http://mangafox.me/"
    else
      site == manga[1]
    end      
    if db.manga_in_data?(manga[0]) == true
      puts manga[0] + " is already in database"
    else
      if (site != "http://mangafox.me/")
        puts "sorry, MangaScrap does not deal with other sites than mangafox ( yet )"
        exit 4
      end
    end
    elem = get_mf_class(db, manga[0], false)
    if elem == nil
      puts "error while downloading #{manga[0]}, going to next element"
      next
    end
    tab_dw << elem
    tab_name << manga[0]
  end
  i = 0
  tab_name.each do |manga|
    puts "downloading " + manga
    tab_dw[i].update()
    i += 1
  end
end

def download(db)
  if ARGV.size < 2
    puts 'not enough arguments'
    exit 5
  end
  file = false
  site = "http://mangafox.me/"
  if (ARGV.size > 2)
    ret = get_mangas()
    if (ret != nil)
      file = true
    else
      site = ARGV[2]
    end
  end
  if (file == false)
    if (site != "http://mangafox.me/")
      puts "sorry, sites other than mangafox are not yet managed"
      exit 4
    else
      dw = get_mf_class(db, ARGV[1], false)
      if dw == nil
        exit 3
      end
      dw.update()
    end
  else
    download_file(ret, db)
  end
end
