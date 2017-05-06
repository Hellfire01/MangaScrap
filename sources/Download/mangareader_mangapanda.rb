class Download_Mangareader_Pandamanga
  private
  def extract_links(manga)
    tries = @params[4]
    links = @doc.xpath('//table[@id="listing"]/tr/td/a').map{ |link| link['href'] }
    while (links == nil || links.size == 0) && tries > 0
      puts ('error while retrieving chapter index of ' + manga.name).yellow
      doc = get_page(manga.link)
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
    link = @manga_data.site + @manga_data.name + '/' + chapter.to_s + '/' + page.to_s
    if Utils_connection::redirection_detection(link)
      puts 'Error : generated a bad link\nlink = ' + link
      return nil
    end
    link
  end

  def page_link(link, data)
    page = Utils_connection::get_page(link, true)
    if page == nil
      return false
    end
    pic_link = page.xpath('//img').map{|img| img['src']}
    if pic_link[0] == nil
      return link_err(data)
    end
    pic_buffer = Utils_connection::get_pic(pic_link[0], true)
    if pic_buffer == nil || Utils_file::write_pic(pic_buffer, data, @dir) == false
      return link_err(data)
    end
    @downloaded_a_page = true
    true
  end

  def chapter_link(link, prep_display = '')
    data = @manga_data.extract_values_from_link(link)
    page = Utils_connection::get_page(link, true)
    if page == nil
      return link_err(data, true)
    end
    @aff.prepare_chapter("downloading chapter #{data[1]} of #{@manga_data.name}" + prep_display)
    number_of_pages = page.xpath('//option').last.text.to_i
    page_nb = 1
    link += '/1'
    while page_nb <= number_of_pages
      data[2] = page_nb
      unless page_link(link, data)
        link_err(data)
      end
      @aff.downloaded_page(page_nb)
      last_pos = link.rindex(/\//)
      link = link[0..last_pos].strip + page_nb.to_s
      page = ''
      page = Utils_connection::get_page(link, true)
      if page == nil
        return link_err(data, true)
      end
      page_nb += 1
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
        if elem[4] != -1
          @aff.display_todo("downloading page #{elem[4]}, chapter #{elem[3]}")
          data = []
          data << -1 << elem[3] << elem[4]
          if (link = link_generator(-1, elem[3], elem[4])) != nil && page_link(link, data) == true
            @db.delete_todo(elem[0])
          else
            @aff.todo_err("failed to download page #{elem[4]} of chapter #{elem[3]}" + volume_string)
          end
        else
          @aff.display_todo("downloading chapter #{elem[3]}")
          if (link = link_generator(-1, elem[3], 1)) != nil && chapter_link(link) == true
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
      data = @manga_data.extract_values_from_link(link)
      if traces.count{|_id, _manga_name, _vol_value, chap_value| chap_value == data[1]} == 0
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
    if @downloaded_a_page && !@extracted_data
      data
    end
    @downloaded_a_page
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
    Utils_file::dir_create(@dir)
    Utils_connection::write_cover(@doc, '//div[@id="mangaimg"]/img', @dir + 'cover.jpg', @params[1] + 'mangareader/mangas/' + @manga_data.name + '.jpg')
    File.open(@dir + 'description.txt', 'w') do |txt|
      txt << Utils_file::data_concatenation(@manga_data.name, Utils_file::description_manipulation(description), @manga_data.site, @manga_data.link, author, artist, type, status, genres, release, html_name, alternative_names)
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
    @extracted_data = false
    @params = Params.instance.get_params
    @dir = @params[1] + manga.site_dir + 'mangas/' + manga.name + '/'
    @db = Manga_database.instance
    # doc is the variable that stores the raw data of the manga's page
    @aff = DownloadDisplay.new('mangareader', manga.name)
    @doc = Utils_connection::get_page(manga.link, true)
    if @doc == nil
      raise 'failed to get manga ' + manga.name + "'s chapter index"
    end
    if download_data
      data
    end
    @links = extract_links(manga)
  end
end
