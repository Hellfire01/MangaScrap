def re_dl(db)
  if (ARGV.size < 3)
    puts "error : not enought arguments"
    puts "MangaScrapp -h for help"
    exit 5
  end
  manga = db.get_manga(ARGV[1])
  if (manga == nil)
    abort ("manga \"" + ARGV[1] + "\" whas not found in database")
  end
  if (manga[3] == "http://mangafox.me/")
    ARGV.delete_at(1)
    ARGV.delete_at(0)
    MF_redl(db, manga[1])
  else
    puts "site " + manga[3] + " is not yet managed"
  end
end
