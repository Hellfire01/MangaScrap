def MF_volume_string(value)
  volume_string = ""
  if (value == -2)
    volume_string = " of volume TBD"
  elsif (value >= 0)
    volume_string = " of volume #{value}"
    if value % 1 == 0
      volume_string += ' '
    end
  end
  return volume_string
end

def MF_manga_todo(name, db, dw)
  todo = db.get_todo(name)
  if todo.size != 0
    puts ""
    puts "downloading todo pages"
    todo.each do |elem|
      volume_nb = elem[2]
      chapter_nb = elem[3]
      page_nb = elem[4]
      volume_string = MF_volume_string(elem[2])
      if (page_nb != -1)
        puts "downloading page #{page_nb}, chapter #{chapter_nb}" + ((volume_nb == -1) ? "" : ", volume #{volume_nb} ")
        if (dw.page(volume_nb, chapter_nb, page_nb) == true)
          db.delete_todo(elem[0])
        else
          puts "failed to download page #{page_nb} of chapter #{chapter_nb}" + volume_string
        end
      else
        puts "downloading chapter #{chapter_nb}" + ((volume_nb == -1) ? "" : ", volume #{volume_nb} ")
        if (dw.chapter(volume_nb, chapter_nb) == true)
          db.delete_todo(elem[0])
        else
          puts "failed to download chapter #{chapter_nb}" + volume_string
        end
      end
    end
    puts "done"
  end
end

def MF_manga_missing_chapters(name, db, dw)
  miss = false
  traces = db.get_trace(name)
  links = dw.get_links()
  i = 0
  links.reverse_each do |link|
    data = data_extractor_MF(link)
    if (traces.count{|_id, _manga_name, vol_value, chap_value| vol_value == data[0] && chap_value == data[1]} == 0)
      if (miss == false)
        puts ""
        puts "updating chapters"
        dw.data()
        miss = true
      end
      volume_string = MF_volume_string(data[0])
      puts ""
      puts "downloading chapter #{data[1]}" + volume_string + " of #{name} ( link #{i + 1} / #{links.size} )"
      dw.chapter_link(link)
    end
    i += 1
  end
  if (miss == true)
    puts "downloaded missing chapters for #{name}"
    html_chapter_index(db, db.get_manga(name), Params.new().get_params())
    puts ""
  else
    puts "no missing chapters for #{name}"
  end
end

#used by Download_mf to avoid creating a second instance of the same class
def MF_update_dw(name, dw, db)
  pdb = Params.new()
  params = pdb.get_params()
  MF_manga_todo(name, db, dw)
  MF_manga_missing_chapters(name, db, dw)
  if (params[6] == "true")
    delete_diff(db, dw.get_links(), params[1] + "mangafox/mangas/" + name + "/", name)
  end
end

def MF_update(db, name)
  dw = get_mf_class(db, name, false)
  if dw == nil
    return false
  end
  MF_update_dw(name, dw, db)
  return true
end
