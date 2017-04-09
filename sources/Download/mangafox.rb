class Download_Mangafox
  private
  def link_err(data, chapter = false)
    if !chapter
      @db.add_todo(@manga_data, data[0], data[1], data[2])
      @aff.error_on_page_download('X')
    else
      @db.add_todo(@manga_data, data[0], data[1], -1)
      @aff.error_on_page_download('X')
    end
    false
  end

  public
  def get_links
    @links
  end

  # todo => vérifier s'il n'est pas possible de supprimer cette fonction
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
    link += '/' + page.to_s + '.html'
    if redirection_detection(link)
      puts 'Error : generated a bad link\nlink = ' + link
      return nil
    end
    link
  end

  def page_link(link, data)
    page = get_page(link, true)
    if page == nil
      return false
    end
    pic_link = page.xpath('//img[@id="image"]').map{|img| img['src']}
    if pic_link[0] == nil
      return link_err(data)
    end
    pic_buffer = get_pic(pic_link[0], true)
    if pic_buffer == nil || write_pic(pic_buffer, data, @dir) == false
      return link_err(data)
    end
    @downloaded_a_page = true
    true
  end

  def chapter_link(link, prep_display = '')
    data = data_extractor_MF(link)
    if data[0] == -42
      @aff.unmanaged_link(link)
      false
    end
    last_pos = link.rindex(/\//)
    link = link[0..last_pos].strip + '1.html'
    page = get_page(link, true)
    if page == nil
      return link_err(data, true)
    end
    @aff.prepare_chapter("downloading chapter #{data[1]}#{MF_volume_string(data[0])} of #{@manga_data.name}" + prep_display)
    number_of_pages = page.xpath('//div[@class="l"]').text.split.last.to_i
    page_nb = 1
    while page_nb <= number_of_pages
      data[2] = page_nb
      unless page_link(link, data)
        link_err(data)
      end
      @aff.downloaded_page(page_nb)
      page_nb += 1
      last_pos = link.rindex(/\//)
      link = link[0..last_pos].strip + page_nb.to_s + '.html'
      page = get_page(link, true)
      if page == nil
        return link_err(data, true)
      end
    end
    @aff.dump_chapter
    @db.add_trace(@manga_data, data[0], data[1], number_of_pages)
    HTML_buffer.instance.add_chapter(@manga_data, data[0], data[1])
    true
  end

  def todo
    todo = @db.get_todo(@manga_data)
    if todo.size != 0
      @aff.prepare_todo
      biggest = todo.map { |a| [a[2], 0].max }.max
      todo = todo.sort_by! { |a| [(a[2] < 0) ? (biggest + a[2] * -1) : a[2], -a[3]] }
      todo.each do |elem|
        volume_string = MF_volume_string(elem[2])
        if elem[4] != -1
          @aff.display_todo("downloading page #{elem[4]}, chapter #{elem[3]}" + ((elem[2] == -1) ? '' : ", volume #{elem[2]} "))
          data = []
          data << elem[2] << elem[3] << elem[4]
          if (link = link_generator(elem[2], elem[3], elem[4])) != nil && page_link(link, data) == true
            @db.delete_todo(elem[0])
          else
            @aff.todo_err("failed to download page #{elem[4]} of chapter #{elem[3]}" + volume_string)
          end
        else
          @aff.display_todo("downloading chapter #{elem[3]}" + ((elem[2] == -1) ? '' : ", volume #{elem[2]} "), true)
          if (link = link_generator(elem[2], elem[3], 1)) != nil && chapter_link(link) == true
            @db.delete_todo(elem[0])
          else
            @aff.todo_err("failed to download chapter #{elem[3]}" + volume_string, true)
          end
        end
      end
      @aff.end_todo
    end
    @downloaded_a_page
  end
  
  def missing_chapters(get_data = true)
    traces = @db.get_trace(@manga_data)
    i = 0
    @links.each do |link|
      data = data_extractor_MF(link)
      if traces.count{|_id, _manga_name, vol_value, chap_value| vol_value == data[0] && chap_value == data[1]} == 0
        prep_display = " ( link #{i + 1} / #{@links.size} )"
        chapter_link(link, prep_display)
      end
      i += 1
    end
    if @downloaded_a_page
      if get_data
        data
      end
    end
    @aff.dump
  end
  
  def update
    todo
    missing_chapters
    @downloaded_a_page
  end

  def data
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
    dir_create(@dir)
    write_cover(@doc, '//div[@class="cover"]/img', @dir + 'cover.jpg', @params[1] + 'mangafox/mangas/' + @manga_data.name + '.jpg')
    File.open(@dir + 'description.txt', 'w') do |txt|
      txt << data_conc(@manga_data.name, description_manipulation(description), @manga_data.site, @manga_data.link, author, artist, type, status, genres, release, html_name, alternative_names)
    end
    @aff.data_disp(@manga_data.in_db)
    if @manga_data.in_db
      @db.update_manga(@manga_data.name, description, author, artist, genres, html_name, alternative_names, rank, rating, rating_max)
    else
      @db.add_manga(@manga_data, description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max)
    end
  end

  def initialize(manga, download_data = true)
    @manga_data = manga
    @downloaded_a_page = false
    @params = Params.instance.get_params
    @dir = @params[1] + manga.site_dir + 'mangas/' + manga.name + '/'
    @db = Manga_database.instance
    # doc is the variable that stores the raw data of the manga's page
    @aff = DownloadDisplay.new('mangafox', manga.name)
    @doc = get_page(manga.link, true)
    if @doc == nil
      raise 'failed to get manga ' + manga.name + "'s chapter index"
    end
    if download_data
      data
    end
    @links = extract_links(@doc, manga.name, '//a[@class="tips"]', manga.link).reverse
  end
end
