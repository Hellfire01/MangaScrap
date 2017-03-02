def redl_volume(element, volume)
  failure = true
  dw = element.get_download_class
  if dw == nil
    return false
  end
  links = dw.get_links
  links.sort.each do |link|
    data = element.extract_values_from_link(link)
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
    puts 'did not find any links in the chapter index with the requested volume for ' + element.name + ' of ' + element.site
  else
    puts 'done'
  end
  !failure
end

def redl_chapter(element, chapter, volume)
  failure = true
  dw = element.get_download_class
  if dw == nil
    return false
  end
  links = dw.get_links
  links.each do |link|
    data = element.extract_values_from_link(link)
    if data[0] == volume && data[1] == chapter
      failure = false
      puts 'downloading chapter ' + chapter.to_s
      dw.chapter_link(link)
      break
    end
  end
  if failure
    puts 'did not find any links in the chapter index with the requested chapter for ' + element.name + ' of ' + element.site
  else
    puts 'done'
  end
  !failure
end

def redl_page(element, page, chapter, volume)
  failure = true
  dw = element.get_download_class
  if dw == nil
    return false
  end
  links = dw.get_links
  links.each do |link|
    data = element.extract_values_from_link(link)
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
    puts 'did not find any links in the chapter index with the requested page for ' + element.name + ' of ' + element.site
  else
    puts 'done'
  end
  !failure
end

def redl_manager(element, volume, chapter, page)
  if chapter != nil && page != nil # chapter + page ( volume optional )
    redl_page(element, page, chapter, volume)
  elsif chapter != nil && page == nil # chapter only ( volume optional )
    redl_chapter(element, chapter, volume)
  elsif volume != nil && chapter == nil && page == nil # volume only
    redl_volume(element, volume)
  else
    critical_error("Unmanaged redl values : volume = #{volume} / chapter = #{chapter} / page = #{page}")
  end
  false
end

def check_redl_options(volume, chapter, page)
  if volume != nil && volume < -4
    puts 'volume value cannot be < -4'
    puts 'values as :'
    puts '-2 => TBD'
    puts '-3 => NA'
    puts '-4 => ANT'
    false
  end
  if chapter != nil && chapter < 0
    puts 'chapter value cannot be negative'
    false
  end
  if page != nil && page < 0
    puts 'page value cannot be negative'
    false
  end
  if volume != nil && chapter == nil && page != nil # volume + page but no chapter
    puts 'error : you cannot request the page of a volume, the chapter value is needed'
    false
  end
  true
end

def re_download(args, instruction_class)
  page = nil
  chapter = nil
  volume = nil
  parser = get_data_parser('redl')
  parser.on('p', 1) do |_page|
    page = _page[0].to_i
  end
  parser.on('c', 1) do |_chapter|
    chapter = _chapter[0].to_i
  end
  parser.on('v', 1) do |_volume|
    volume = mangafox_volume_string_to_int(_volume[0])
  end
  parser.parse args
  data_to_prepare = instruction_class.data_to_prepare
  unless check_redl_options(volume, chapter, page)
    instruction_class.clear_data
    puts 'cannot execute redl instruction, ignoring it'.yellow
    return
  end
  filter = Manga_data_filter.new(data_to_prepare)
  elements = filter.run(false, true)
  instruction_class.clear_data
  elements.each do |e|
    if redl_manager(e, volume, chapter, page)
      HTML.new.generate_chapter_index(e)
    else
      return
    end
  end
end
