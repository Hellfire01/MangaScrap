def add(db, work_dir)
  if ARGV.size < 2
    abort ('not enough arguments')
  end
  manga_name = ARGV[1]
  site = "http://mangafox.me/manga/"
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
    Download.new(db, manga_name, work_dir, site)
  else
    ret.each do |name|
      if (name.size == 1)
	site = "http://mangafox.me/manga/"
      else
	site == name[1]
      end
      Download.new(db, name[0], work_dir, site)
    end
  end
end
