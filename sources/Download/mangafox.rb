class Download_Mangafox
  include Base_downloader

  private
  def extract_links(manga)
    tries = @params[4]
    links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
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
    links
  end

  public
  def link_generator(volume, chapter, page)
    chapter = chapter.to_i if chapter % 1 == 0
    link = @manga_data.site + 'manga/' + @manga_data.name + '/'
    if volume >= 0
      vol_buffer = ((volume >= 10) ? '' : '0')
      link += 'v' + vol_buffer + volume.to_s + '/'
    elsif volume == -2
      link += 'vTBD/'
    elsif volume == -3
      link += 'vNA/'
    elsif volume == -4
      link += 'vANT/'
    end
    chap_buffer = ((chapter < 10) ? '00' : ((chapter < 100) ? '0' : ''))
    link += 'c' + chap_buffer
    if chapter % 1 == 0
      link += chapter.to_i.to_s
    else
      link += chapter.to_s
    end
    link + '/' + page.to_s + '.html'
  end

  # downloads a page, with link = the link, data = [volume, chapter, page]
  def page_link(link, data)
    get_page_from_link(link, data, '//img[@id="image"]')
  end

  # downloads a chapter with link = the link and prep_display = small string displayed when announcing the download of the chapter
  def chapter_link(link, prep_display = '')
#    get_chapter_from_link(link, prep_display, '//div[@class="l"]', '.html')
    data = @manga_data.extract_values_from_link(link)
    @aff.prepare_chapter("downloading #{data_to_string(data)} of #{@manga_data.name}" + prep_display)
    if data[0] == -42
      @aff.unmanaged_link(link)
      false
    end
    last_pos = link.rindex(/\//)
    link = link[0..last_pos].strip + '1.html'
    begin
      if (page = Utils_connection::get_page(link, true)) == nil
        return link_err(data, true, 'X')
      end
    rescue RuntimeError
      return link_err(data, true, 'R')
    end
    number_of_pages = page.xpath('//div[@class="l"]').text.split.last.to_i
    if number_of_pages == 0
      return link_err(data, true, '?')
    end
    page_nb = 1
    while page_nb <= number_of_pages
      data[2] = page_nb
      page_link(link, data)
      last_pos = link.rindex(/\//)
      page_nb += 1
      link = link[0..last_pos].strip + page_nb.to_s + '.html'
    end
    @aff.dump_chapter
    @db.add_trace(@manga_data, data[0], data[1], number_of_pages)
    true
  end

  public
  def data
    unless @extracted_data
      @extracted_data = true
      alternative_names = @doc.xpath('//div[@id="title"]/h3').text
      release_author_artist_genres = @doc.xpath('//td[@valign="top"]')
      release = release_author_artist_genres[0].text.to_i
      author = release_author_artist_genres[1].text.gsub(/\s+/, '').gsub(',', ', ')
      artist = release_author_artist_genres[2].text.gsub(/\s+/, '').gsub(',', ', ')
      genres = release_author_artist_genres[3].text.gsub(/\s+/, '').gsub(',', ', ')
      description = @doc.xpath('//p[@class="summary"]').text
      data = @doc.xpath('//div[@class="data"]/span')
      status = data[0].text.gsub(/\s+/, '').split(',')[0]
      rank = data[1].text[/\d+/]
      rating = data[2].text[/\d+[.,]\d+/]
      rating_max = 5 # rating max is a constant in mangafox
      tmp_type = @doc.xpath('//div[@id="title"]/h1')[0].text.split(' ')
      type = tmp_type[tmp_type.size - 1]
      html_name = tmp_type.take(tmp_type.size - 1).join(' ')
      validate_data(description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max, '//div[@class="cover"]/img')
    end
  end
end
