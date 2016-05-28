def update_manga(db, name)
  puts "updating " + name
  manga = db.get_manga(name)
  todo = db.get_todo(name)
  dw = Download.new(db, name, manga[3])
  if todo.size != 0
    puts "atempting download of pages of todo database"
    todo.each do |elem|
      volume_nb = elem[2]
      chapter_nb = elem[3]
      page_nb = elem[4]
      if (page_nb != -1)
	if (dw.page(volume_nb, chapter_nb, page_nb, true) == true)
	  db.delete_todo(elem[0])
	else
	  puts "failed to download page #{page_nb} of chapter #{chapter_nb} of volume #{volume_nb}"
	end
      else
	if (dw.chapter(volume_nb, chapter_nb) == true)
	  db.delete_todo(elem[0])
	else
	  puts "failed to download chapter #{chapter_nb} of volume #{volume_nb}"
	end
      end
    end
  end
  miss = false
  traces = db.get_trace(name)
  chapters = dw.get_chapter_values()
  volumes = dw.get_volume_values()
  i = 0
  if traces.size != chapters.size
    miss = true
    dw.cover()
    dw.update_data()
    while i < chapters.size
      if (traces.select{|id, manga_name, vol_value, chap_value| vol_value == volumes[i] && chap_value == chapters[i]}.size == 0)
	puts ""
	puts "did not find volume #{volumes[i]} chapter #{chapters[i]} in #{name}'s trace database"
	puts "downloading volume #{volumes[i]} chapter #{chapters[i]} ( link #{i + 1} / #{chapters.size} )"
	dw.chapter(volumes[i], chapters[i])
      end
      i += 1
    end
  end
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
