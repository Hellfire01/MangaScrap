def update_manga(db, name)
  puts ""
  manga = db.get_manga(name)
  todo = db.get_todo(name)
  dw = Download.new(db, name, manga[3])
  puts ""
  if todo.size != 0
    puts "atempting download of pages of todo database"
    todo.each do |elem|
      chapter_nb = elem[1]
      page_nb = elem[2]
      if (page_nb != -1)
	if (dw.page(chapter_nb, page_nb, true) == true)
	  db.delete_todo(name, elem[0])
	else
	  puts "failed to download page #{page_nb} of chapter #{chapter_nb}"
	end
      else
	if (dw.chapter(chapter_nb) == true)
	  db.delete_todo(name, elem[0])
	else
	  puts "failed to download chapter #{chapter_nb}"
	end
      end
    end
  else
    puts "no elements in todo database"
  end
  puts "checking for missing data"
  miss = false
  traces = db.get_trace(name)
  chapters = dw.get_chapter_values()
  volumes = dw.get_volume_values()
  i = 0
  chapters.each do |chap|
    if (traces.select{|id, vol_value, chap_value| vol_value == volumes[i] && chap_value == chap}.size == 0)
      if miss == false
        puts ""
	dw.cover()
	dw.update_data()
      end
      miss = true
      puts ""
      puts "did not find volume #{volumes[i]} chapter #{chap} in #{name}'s trace database"
      puts "downloading volume #{volumes[i]} chapter #{chap} ( link #{i + 1} / #{chapters.size} )"
      dw.chapter(volumes[i], chap)
    end
    i += 1
  end
  puts ""
  if (miss == true)
    puts "downloaded missing chapters for #{name}"
  else
    puts "no missing chapters for #{name}"
  end
  puts ""
end

def update_all(db)
  list = db.get_manga_list()

  puts "updating all mangas in database"  
  list.each do |elem|
    puts "updating " + elem[0]
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
      abort("error while trying to get content of file ( -t option )")
    end
  else
    abort('bad number of arguments for update, --help for help')
  end
end
