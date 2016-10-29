def update_exec(name, db, params)
  puts "updating " + name
  # todo : site needs to be managed
  dw = get_mf_class(db, name, false)
  if dw != nil
    dw.update()
    if params[6] == "true"
      delete_diff(db, dw.get_links(), name)
    end
  end
end

def update_manga(db, name, fast, params)
  manga = db.get_manga(name)
  if (manga == nil)
    puts "error : " + name + " no such manga in database"
    exit 5
  end
  # todo : site needs to be managed
  if (manga[3] == "http://mangafox.me/")
    if (fast == true && manga[8] == "Ongoing")
        update_exec(name, db, params)
    elsif (fast == false)
      update_exec(name, db, params)
    end
  else
    puts "did not find " + manga[3] + " in available site list, leaving"
    exit 5
  end
end

def update_all(db, fast, params)
  list = db.get_manga_list()
  puts "updating all mangas in database"  
  list.each do |elem|
    if update_manga(db, elem[0], fast, params) == false
      puts "error while trying to update #{elem[0]}"
      puts "updating next element"
    end
  end
end

def update(db, fast = false)
  params = Params.instance.get_params
  case ARGV.size
  when 0, 1
    update_all(db, fast, params)
  when 2
    if (db.manga_in_data?(ARGV[1]) == true)
      update_manga(db, ARGV[1], fast, params)
    else
      puts 'could not find ' + ARGV[1] + ' in database'
      exit 5
    end
  when 3
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        update_manga(db, name[0], fast, params)
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
