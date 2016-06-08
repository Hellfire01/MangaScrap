def MF_volume_string(value)
  volume_string = ""
  if (value == -2)
    volume_string = " of volume TBD"
  elsif (value >= 0)
    volume_string = " of volume #{value}"
  end
  return volume_string
end

def MF_manga_todo(name, db, dw)
  todo = db.get_todo(name)
  if todo.size != 0
    puts "atempting download of pages of todo database"
    todo.each do |elem|
      chapter_nb = elem[3]
      page_nb = elem[4]
      volume_string = MF_volume_string(elem[2])
      if (page_nb != -1)
        if (dw.page(volume_nb, chapter_nb, page_nb) == true)
          db.delete_todo(elem[0])
        else
          puts "failed to download page #{page_nb} of chapter #{chapter_nb}" + volume_string
        end
      else
        if (dw.chapter(volume_nb, chapter_nb) == true)
          db.delete_todo(elem[0])
        else
          puts "failed to download chapter #{chapter_nb}" + volume_string
        end
      end
    end
  else
    puts "no element in todo database"
  end
end

def MF_manga_missing_chapters(name, db, dw)
  miss = false
  traces = db.get_trace(name)
  links = dw.get_links()
  i = 0
  links.reverse_each do |link|
    data = dw.data_extractor(link)
    if (traces.count{|id, manga_name, vol_value, chap_value| vol_value == data[0] && chap_value == data[1]} == 0)
      if (miss == false)
        puts "updating chapters"
        dw.data()
        miss = true
      end
      volume_string = MF_volume_string(data[0])
      puts ""
      puts "did not find chapter #{data[1]}" + volume_string + " in #{name}'s trace database"
      puts "downloading chapter #{data[1]}" + volume_string + " ( link #{i + 1} / #{links.size} )"
      dw.chapter(data[0], data[1])
    end
    i += 1
  end
  if (miss == true)
    puts "downloaded missing chapters for #{name}"
  else
    puts "no missing chapters for #{name}"
  end
end

def MF_manga_extra_chapters(name, db, dw)
end

def MF_update(db, name)
  pdb = Params.new()
  params = pdb.get_params()
  dw = Download_mf.new(db, name)
  MF_manga_todo(name, db, dw)
  MF_manga_missing_chapters(name, db, dw)
  if (params[6] == "true")
    MF_manga_extra_chapters(name, db, dw)
  end
end