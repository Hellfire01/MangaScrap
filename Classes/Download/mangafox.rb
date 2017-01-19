class Download_Mangafox
  private
  def link_err(data, chapter = false)
    if !chapter
      @db.add_todo(@manga_name, data[0], data[1], data[2])
      @aff.error_on_page_download('X')
    else
      @db.add_todo(@manga_name, data[0], data[1], -1)
      @aff.error_on_page_download('X')
    end
    false
  end

  public
  def get_links
    @links
  end

  def link_generator(volume, chapter, page)
    chapter = chapter.to_i if chapter % 1 == 0
    link = @site + 'manga/' + @manga_name + '/'
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
    @aff.prepare_chapter("downloading chapter #{data[1]}#{MF_volume_string(data[0])} of #{@manga_name}" + prep_display)
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
    @db.add_trace(@manga_name, data[0], data[1])
    HTML_buffer.instance.add_chapter(@manga_name, data[0], data[1])
    true
  end

  def todo
    todo = @db.get_todo(@manga_name)
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
  end
  
  def missing_chapters
    traces = @db.get_trace(@manga_name)
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
      data
      HTML.new(@db).generate_chapter_index(@manga_name)
    end
    @aff.dump
  end
  
  def update
    todo
    missing_chapters
  end

  def data
    alternative_names = @doc.xpath('//div[@id="title"]/h3').text
    raag_data = @doc.xpath('//td[@valign="top"]')
    release = raag_data[0].text.to_i
    author = raag_data[1].text.gsub(/\s+/, '').gsub(',', ', ')
    artist = raag_data[2].text.gsub(/\s+/, '').gsub(',', ', ')
    genres = raag_data[3].text.gsub(/\s+/, '').gsub(',', ', ')
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
    write_cover(@doc, '//div[@class="cover"]/img', @dir + 'cover.jpg', @params[1] + 'mangafox/mangas/' + @manga_name + '.jpg')
    File.open(@dir + 'description.txt', 'w') do |txt|
      txt << data_conc(@manga_name, description_manipulation(description), @site, @site + @manga_name, author, artist, type, status, genres, release, html_name, alternative_names)
    end
    @aff.data_disp(@manga_in_database)
    if @manga_in_database
      @db.update_manga(@manga_name, description, author, artist, genres, html_name, alternative_names, rank, rating, rating_max)
    else
      @db.add_manga(@manga_name, description, @site, (@site + 'manga/' + @manga_name), author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max)
    end
  end

  def initialize(db, manga_name, download_data)
    @downloaded_a_page = false
    @manga_name = manga_name
    @params = Params.instance.get_params
    @dir = @params[1] + 'mangafox/mangas/' + manga_name + '/'
    @db = db
    @site = 'http://mangafox.me/'
    @manga_in_database = db.manga_in_data?(manga_name)
    doc_link = @site + '/manga/' + manga_name
    @doc = get_page(doc_link, true)
    @aff = DownloadDisplay.new('mangafox', manga_name)
    if download_data == true || @manga_in_database == false
      if redirection_detection(@site + '/manga/' + manga_name)
        puts "could not find manga #{manga_name} at " + @site + '/manga/' + manga_name
        exit 3
      end
      data
    end
    if @doc == nil
      raise 'failed to get manga ' + manga_name + "'s chapter index"
    end
    @links = extract_links(@doc, @manga_name, '//a[@class="tips"]', doc_link).reverse
  end
end
