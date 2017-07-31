module Re_download_module
  # used to redownload an entire volume
  def self.redl_volume(element, volume)
    failure = true
    dw = element.get_download_class
    if dw == nil
      return false
    end
    links = dw.links
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
      puts 'did not find any links in the chapter index with the requested volume for ' + element[:name] + ' of ' + element[:website][:link]
    else
      puts 'done'
    end
    !failure
  end

  # used to re-download a chapter
  # todo : generate the required link and use it directly
  def self.redl_chapter(element, chapter, volume)
    failure = true
    dw = element.get_download_class
    if dw == nil
      return false
    end
    links = dw.links
    links.each do |link|
      data = element.extract_values_from_link(link)
      if data[0] == volume && data[1] == chapter
        failure = false
        dw.chapter_link(link)
        break
      end
    end
    if failure
      puts 'did not find any links in the chapter index with the requested chapter for ' + element[:name] + ' of ' + element[:website][:link]
    else
      puts 'done'
    end
    !failure
  end

  # used to re-download just a page
  # todo : generate the required link and use it directly
  def self.redl_page(element, page, chapter, volume)
    failure = true
    dw = element.get_download_class
    if dw == nil
      return false
    end
    links = dw.links
    links.each do |link|
      data = element.extract_values_from_link(link)
      if data[0] == volume && data[1] == chapter
        new_link = dw.link_generator(volume, chapter, page)
        failure = false
        puts "downloading page #{page} of chapter #{chapter}" + ((volume == -1) ? '' : ((volume == -2) ? ' of volume TBD' : " of volume #{volume}"))
        dw.page_link(new_link, element.extract_values_from_link(new_link))
        break
      end
    end
    if failure
      puts 'did not find any links in the chapter index with the requested page for ' + element[:name] + ' of ' + element[:website][:link]
    else
      puts 'done'
    end
    !failure
  end

  # this function calls the right function (page, chapter or volume) depending on the arguments
  def self.redl_manager(element, volume, chapter, page)
    if chapter != nil && page != nil # chapter + page ( volume optional )
      redl_page(element, page, chapter, volume)
    elsif chapter != nil && page == nil # chapter only ( volume optional )
      redl_chapter(element, chapter, volume)
    elsif volume != nil && chapter == nil && page == nil # volume only
      redl_volume(element, volume)
    else
     Utils_errors::critical_error("Unmanaged redl values : volume = #{volume} / chapter = #{chapter} / page = #{page}")
    end
    false
  end

  # ensures that the values are correctly given to the re-download function
  def self.check_redl_options(volume, chapter, page)
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
end # ! module Re_download_module
