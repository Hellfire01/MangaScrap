def add(db, work_dir)
  if ARGV.size < 2
    abort ('not enough arguments')
  end
  manga_name = ARGV[1]
  site = "http://mangafox.me/manga/"
  if (ARGV.size > 2)
    site = ARGV[2]
  end
  Download.new(db, manga_name, work_dir, site)
end
