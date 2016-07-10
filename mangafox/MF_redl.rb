def MF_redl_volume(dw, volume)
  failure = true
  links = dw.get_links()
  links.each do |link|
    data = dw.data_extractor(link)
    if data[0] == volume
      if failure == true
        failure = false
        puts "downloading volume " + volume.to_s
      end
      puts "downloading chapter " + chapter.to_s
      dw.chapter_link(link)
    end
  end
  if (failure == true)
    puts "did not find any links in the chapter index with the requested volume"
  else
    puts "done"
  end
end

def MF_redl_chapter(dw, chapter, volume)
  failure = true
  links = dw.get_links()
  links.each do |link|
    data = dw.data_extractor(link)
    if data[0] == volume && data[1] == chapter
      failure = false
      puts "downloading chapter " + chapter.to_s
      dw.chapter_link(link)
      break
    end
  end
  if (failure == true)
    puts "did not find any links in the chapter index with the requested chapter"
  else
    puts "done"
  end
end


def MF_redl_page(dw, page, chapter, volume)
  failure = true
  links = dw.get_links()
  links.each do |link|
    data = dw.data_extractor(link)
    if data[0] == volume && data[1] == chapter
      new_link = dw.link_generator(volume, chapter, page)
      if redirection_detection(new_link) == true
        break
      end
      failure = false
      puts "downloading page #{page} of chapter #{chapter}" + ((volume == -1) ? "" : ((volume == -2) ? " of volume TBD" : " of volume #{volume}"))
      dw.page_link(new_link)
      break
    end
  end
  if (failure == true)
    puts "did not find any links in the chapter index with the requested page"
  else
    puts "done"
  end
end

def MF_check_redl_options(volume, chapter, page)
  if (volume != nil && volume < -2)
    puts "volume value cannot be negative"
    exit 5
  end
  if (chapter != nil && chapter < 0)
    puts "chapter value cannot be negative"
    exit 5
  end
  if (page != nil && page < 0)
    puts "page value cannot be negative"
    exit 5
  end
end

def MF_redl_manager(db, manganame, volume, chapter, page)
  dw = Download_mf.new(db, manganame, false)
  if (volume != nil)
    if (chapter != nil)
      if (page != nil)
        MF_redl_page(dw, page, chapter, volume)
      else
        MF_redl_chapter(dw, chapter, volume)
      end
    else
      if (page != nil)
        puts "error : you cannot request the page of a volume, the chapter value is needed"
        exit 5
      else
        MF_redl_volume(dw, volume)
      end
    end
  else
    if (chapter != nil)
      if (page != nil)
        MF_redl_page(dw, page, chapter, volume)
      else
        MF_redl_chapter(dw, chapter, volume)
      end
    else
      #error ( volume + chapter = nil )
    end
  end
end

def MF_redl(db, manganame)
  volume = nil
  chapter = nil
  page = nil

  ARGV.each do |elem|
    arg = elem.dup
    case arg[0]
    when 'v'
      arg[0] = ''
      if (arg == "TBD")
        volume = -2
      else
        volume = arg.to_i
      end
    when 'c'
      arg[0] = ''
      chapter = arg.to_f
      if (chapter % 1 == 0)
        chapter = chapter.to_i
      end
    when 'p'
      arg[0] = ''
      page = arg.to_i
    else
      puts "argument error :"
      puts "the first character of the values should be 'v', 'c', or 'p', not '" + arg[0] + "'"
      puts "./MangaScrap -h for help"
      exit 5
    end
  end
  if volume == nil
    volume = -1
  end
  MF_check_redl_options(volume, chapter, page)
  MF_redl_manager(db, manganame, volume, chapter, page)
end
