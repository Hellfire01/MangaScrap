def update_manga(db, name, work_dir)
  manga = db.get_manga(name)
  todo = db.get_todo(name)
  dw = Download.new(db, name, work_dir, manga[3])
  if todo.size != 0
    puts "atempting download of pages of todo database"
    todo.each do |elem|
      chapter_nb = elem[1]
      page_nb = elem[2]
      if (dw.page(chapter_nb, page_nb) == true)
        db.delete_todo(name, elem[0])
      end
    end
  else
    puts "no elements in todo database"
  end
  puts "checking for missing data"
  traces = db.get_trace(name)
  chapters = dw.get_chapter_values()
  chapters.each do |chap|
    if (traces.select{|id, value| value == chap}.size == 0)
      puts "did not find #{chap}"
      dw.chapter(chap)
    end
  end
end

def update_all(db, work_dir)
  list = db.get_manga_list()

  puts "updating all mangas in database"  
  list.each do |elem|
    puts "updating " + elem[0]
    update_manga(db, elem[0], work_dir)
  end
end

def update(db, work_dir)
  case ARGV.size
  when 0, 1
    update_all(db, work_dir)
  when 2
    if (db.manga_in_data?(ARGV[1]) == true)
      update_manga(db, ARGV[1], work_dir)
    else
      abort('could not find ' + ARGV[1] + ' in database')
    end
  else
    abort('too many arguments for update, --help for help')
  end
end
