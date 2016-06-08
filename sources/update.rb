def update_manga(db, name)
  puts "updating " + name
  manga = db.get_manga(name)
  if (manga[3] == "http://mangafox.me/")
    MF_update(db, name)
  else
    abort ("did not find " + manga[3] + " in available site list, aborting")
  end
end

def update_all(db)
  list = db.get_manga_list()
  puts "updating all mangas in database"  
  list.each do |elem|
    update_manga(db, elem[0])
  end
end

def update(db)
  case ARGV.size
  when 0, 1
    update_all(db)
  when 2
    if (db.manga_in_data?(ARGV[1]) == true)
      update_manga(db, ARGV[1])
    else
      abort('could not find ' + ARGV[1] + ' in database')
    end
  when 3
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        update_manga(db, name[0])
      end
    else
      abort("error while trying to get content of file ( -f option )")
    end
  else
    abort('bad number of arguments for update, --help for help')
  end
end
