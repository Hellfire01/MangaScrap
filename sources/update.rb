def update_manga(db, name, fast)
  manga = db.get_manga(name)
  if (manga == nil)
    puts "error : " + name + " no such manga in database"
    exit 5
  end
  if (manga[3] == "http://mangafox.me/")
    if (fast == true)
      if (manga[8] == "Ongoing")
        puts "updating " + name
        dw = get_mf_class(db, name, false)
        dw.update() if dw != nil
      end
    else
      puts "updating " + name
      dw = get_mf_class(db, name, false)
      dw.update() if dw != nil
    end
  else
    puts "did not find " + manga[3] + " in available site list, leaving"
    exit 5
  end
end

def update_all(db, fast)
  list = db.get_manga_list()
  puts "updating all mangas in database"  
  list.each do |elem|
    if update_manga(db, elem[0], fast) == false
      puts "error while trying to update #{elem[0]}"
      puts "updating next element"
    end
  end
end

def update(db, fast = false)
  case ARGV.size
  when 0, 1
    update_all(db, fast)
  when 2
    if (db.manga_in_data?(ARGV[1]) == true)
      update_manga(db, ARGV[1], fast)
    else
      puts 'could not find ' + ARGV[1] + ' in database'
      exit 5
    end
  when 3
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        update_manga(db, name[0], fast)
      end
    else
      puts "error while trying to get content of file ( -f option )"
      exit 5
    end
  else
    puts "bad number of arguments for update, --help for help"
    exit 5
  end
end
