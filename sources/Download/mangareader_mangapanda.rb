class Download_Mangareader_Pandamanga
  include Base_downloader
  
  private
  def extract_links(manga)
    tries = @params[4]
    links = @doc.xpath('//table[@id="listing"]/tr/td/a').map{ |link| link['href'] }
    while (links == nil || links.size == 0) && tries > 0
      puts ('error while retrieving chapter index of ' + manga.name).yellow
      doc = Utils_connection::get_page(manga.link)
      if doc != nil
        links = doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
      end
      tries -= 1
    end
    if links == nil || links.size == 0
      raise ('failed to get manga '.red + manga.name.yellow + ' chapter index'.red)
    end
    ret = []
    links.each do |link|
      ret << @manga_data.site + link[1..-1]
    end
    ret
  end

  # warning : the volume value is not used for both mangareader and pandamanga
  def link_generator(_volume, chapter, page)
    @manga_data.site + @manga_data.name + '/' + chapter.to_s + '/' + page.to_s
  end

  def page_link(link, data)
    get_page_from_link(link, data, '//img')
  end

  def chapter_link(link, prep_display = '')
    data = @manga_data.extract_values_from_link(link)
    begin
      if (page = Utils_connection::get_page(link, true)) == nil
        return link_err(data, true, 'X')
      end
    rescue RuntimeError
      return link_err(data, true, 'R')
    end
    @aff.prepare_chapter("downloading chapter #{data[1]} of #{@manga_data.name}" + prep_display)
    number_of_pages = page.xpath('//option').last.text.to_i
    if number_of_pages == 0
      return link_err(data, true, '?')
    end
    page_nb = 1
    link += '/1'
    while page_nb <= number_of_pages
      data[2] = page_nb
      page_link(link, data)
      last_pos = link.rindex(/\//)
      page_nb += 1
      link = link[0..last_pos].strip + page_nb.to_s
    end
    @aff.dump_chapter
    @db.add_trace(@manga_data, data[0], data[1], number_of_pages)
    true
  end

  def data
    @extracted_data = true
    tmp = @doc.xpath('//div[@id="mangaproperties"]/table/tr')
    alternative_names = tmp[1].text.split(':')[1].strip
    release = tmp[2].text.split(':')[1].strip.to_i
    author = tmp[4].text.split(':')[1].strip
    artist = tmp[5].text.split(':')[1].strip
    genres = tmp[7].text.split(':')[1].strip
    description = @doc.xpath('//div[@id="readmangasum"]/p')[0].text
    status = tmp[3].text.split(':')[1].strip
    rank = -1
    rating = -1
    rating_max = -1
    type = (tmp[6].text.split(':')[1].strip == 'Right to Left') ? 'Manga' : 'Manhwa'
    html_name = @doc.xpath('//h2')[0].text
    validate_data(description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max, '//div[@id="mangaimg"]/img')
  end
end
