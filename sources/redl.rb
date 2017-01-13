def redl_volume(db, manga_name, dw, volume)
  failure = true
  links = dw.get_links
  links.sort.each do |link|
    data = data_extractor_MF(link)
    if data[0] == volume
      if failure
        failure = false
        puts 'downloading volume ' + volume.to_s
      end
      puts 'downloading chapter ' + data[1].to_s
      dw.chapter_link(link)
    end
  end
  if failure
    puts 'did not find any links in the chapter index with the requested volume'
  else
    puts 'done'
    HTML.new(db).generate_chapter_index(manga_name)
  end
end

def redl_chapter(db, manga_name, dw, chapter, volume)
  failure = true
  links = dw.get_links
  links.each do |link|
    data = data_extractor_MF(link)
    if data[0] == volume && data[1] == chapter
      failure = false
      puts 'downloading chapter ' + chapter.to_s
      dw.chapter_link(link)
      break
    end
  end
  if failure
    puts 'did not find any links in the chapter index with the requested chapter'
  else
    puts 'done'
    HTML.new(db).generate_chapter_index(manga_name)
  end
end

def redl_page(dw, page, chapter, volume)
  failure = true
  links = dw.get_links
  links.each do |link|
    data = data_extractor_MF(link)
    if data[0] == volume && data[1] == chapter
      new_link = dw.link_generator(volume, chapter, page)
      if redirection_detection(new_link)
        break
      end
      failure = false
      puts "downloading page #{page} of chapter #{chapter}" + ((volume == -1) ? '' : ((volume == -2) ? ' of volume TBD' : " of volume #{volume}"))
      dw.page_link(new_link, data_extractor_MF(new_link   ))
      break
    end
  end
  if failure
    puts 'did not find any links in the chapter index with the requested page'
  else
    puts 'done'
  end
end

def check_redl_options(volume, chapter, page)
  if volume != nil && volume < -4
    puts 'volume value cannot be < -4'
    puts 'values as :'
    puts '-2 => TBD'
    puts '-3 => NA'
    puts '-4 => ANT'
    exit 5
  end
  if chapter != nil && chapter < 0
    puts 'chapter value cannot be negative'
    exit 5
  end
  if page != nil && page < 0
    puts 'page value cannot be negative'
    exit 5
  end
end

def redl_manager(db, manga_name, volume, chapter, page)
  dw = get_mf_class(db, manga_name, false)
  if dw == nil
    exit 3
  end
  if volume != nil && chapter == nil && page != nil # volume + page but no chapter
    puts 'error : you cannot request the page of a volume, the chapter value is needed'
    exit 5
  elsif chapter != nil && page != nil # chapter + page ( volume optional )
    redl_page(dw, page, chapter, volume)
  elsif chapter != nil && page == nil # chapter only ( volume optional )
    redl_chapter(db, manga_name, dw, chapter, volume)
  elsif volume != nil && chapter == nil && page == nil # volume only
    redl_volume(db, manga_name, dw, volume)
  else
    puts 'unmanaged error, please report it'
    puts "volume = #{volume} / chapter = #{chapter} / page = #{page}"
    exit 2
  end
end

def redl_arg_extract(db, manga_name)
  volume = nil
  chapter = nil
  page = nil
  ARGV.each do |elem|
    arg = elem.dup
    case arg[0]
    when 'v'
      arg[0] = ''
      volume = mangafox_volume_string_to_int(arg)
    when 'c'
      arg[0] = ''
      chapter = arg.to_f
      if chapter % 1 == 0
        chapter = chapter.to_i
      end
    when 'p'
      arg[0] = ''
      page = arg.to_i
    else
      puts "Error : the first character of the values should be 'v', 'c', or 'p', not '" + arg[0] + "'"
      puts './MangaScrap -h for help'
      exit 5
    end
  end
  if volume == nil
    volume = -1
  end
  check_redl_options(volume, chapter, page)
  redl_manager(db, manga_name, volume, chapter, page)
end

def re_dl(db)
  if ARGV.size < 3
    puts 'error : not enought arguments'
    puts 'MangaScrapp -h for help'
    exit 5
  end
  manga = db.get_manga(ARGV[1])
  if manga == nil
    puts 'manga \'' + ARGV[1] + '\' was not found in database'
    exit 5
  end
  if manga[3] == 'http://mangafox.me/'
    ARGV.delete_at(1)
    ARGV.delete_at(0)
    redl_arg_extract(db, manga[1])
  else
    puts 'site ' + manga[3] + ' is not yet managed'
  end
end
