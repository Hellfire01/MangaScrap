class Download_Mangafox
  def link_generator(volume, chapter, page)
    chapter = chapter.to_i if chapter % 1 == 0
    link = @site + "manga/" + @manga_name + "/"
    if (volume >= 0)
      vol_buffer = ((volume >= 10) ? "" : "0")
      link += "v" + vol_buffer + volume.to_s + "/"
    elsif (volume == -2)
      link += "vTBD/"
    elsif (volume == -3)
      link += "vNA/"
    elsif (volume == -4)
      link += "vANT/"
    end
    chap_buffer = ((chapter < 10) ? "00" : ((chapter < 100) ? "0" : ""))
    link += "c" + chap_buffer
    if (chapter % 1 == 0)
      link += chapter.to_i.to_s
    else
      link += chapter.to_s
    end
    link += "/" + page.to_s + ".html"
    if (redirection_detection(link) == true)
      puts "Error : generated a bad link\nlink = " + link
      return nil
    end
    return link
  end

  def link_err(data, chapter = false)
    if chapter == false
      puts "added page #{data[2]}, chapter #{data[1]}" + ((data[0] == -1) ? "" : ", volume #{data[0]} ") + " to todo database"
      @db.add_todo(@manga_name, data[0], data[1], data[2])
    else
      puts "added chapter #{data[1]}" + ((data[0] == -1) ? "" : ", volume #{data[0]} ") + " to todo database"
      @db.add_todo(@manga_name, data[0], data[1], -1)
      puts ""
    end
    return false
  end

  def page_link(link, data)
    page = get_page(link)
    if (page == nil)
      return false
    end
    pic_link = page.xpath('//img[@id="image"]').map{|img| img['src']}
    if pic_link[0] == nil
      return link_err(data)
    end
    pic_buffer = get_pic(pic_link[0])
    if pic_buffer == nil || write_pic(pic_buffer, data, @dir) == false
      return link_err(data)
    end
    return true
  end

  def chapter_link(link)
    data = data_extractor_MF(link)
    if data[0] == -42
      puts "unmanaged volume value in link : " + link
      return false
    end
    last_pos = link.rindex(/\//)
    link = link[0..last_pos].strip + "1.html"
    page = get_page(link)
    if (page == nil)
      return link_err(data, true)
    end
    number_of_pages = page.xpath('//div[@class="l"]').text.split.last.to_i
    page_nb = 1
    while page_nb <= number_of_pages
      data[2] = page_nb
      if (page_link(link, data) == false)
        printf "\n"
        STDOUT.flush
        link_err(data)
      end
      chapter_progression(page_nb)
      page_nb += 1
      last_pos = link.rindex(/\//)
      link = link[0..last_pos].strip + page_nb.to_s + ".html"
      page = get_page(link)
    end
    printf "\n"
    @db.add_trace(@manga_name, data[0], data[1])
    puts "downloaded " + (page_nb - 1).to_s + " page" + (((page_nb - 1) > 1) ? "s" : "")
    return true
  end

  def todo()
    todo = @db.get_todo(@manga_name)
    if todo.size != 0
      puts ""
      puts "downloading todo pages"
      todo.each do |elem|
        volume_string = MF_volume_string(elem[2])
        if (elem[4] != -1)
          puts "downloading page #{elem[4]}, chapter #{elem[3]}" + ((elem[2] == -1) ? "" : ", volume #{elem[2]} ")
          data << elem[2] << elem[3] << elem[4]
          if ((link = link_generator(elem[2], elem[3], elem[4])) != nil && page_link(link, data) == true)
            db.delete_todo(elem[0])
          else
            puts "failed to download page #{elem[4]} of chapter #{elem[3]}" + volume_string
          end
        else
          puts "downloading chapter #{elem[3]}" + ((elem[2] == -1) ? "" : ", volume #{elem[2]} ")
          if (link = link_generator(elem[2], elem[3], 1)) != nil && chapter(link) == true
            db.delete_todo(elem[0])
          else
            puts "failed to download chapter #{elem[3]}" + volume_string
          end
        end
      end
      puts "done"
    end
  end
  
  def missing_chapters()
    miss = false
    traces = @db.get_trace(@manga_name)
    i = 0
    html = HTML.new(@db)
    @links.reverse_each do |link|
      data = data_extractor_MF(link)
      if (traces.count{|_id, _manga_name, vol_value, chap_value| vol_value == data[0] && chap_value == data[1]} == 0)
        if (miss == false)
          puts ""
          puts "updating chapters"
          data()
          miss = true
        end
        volume_string = MF_volume_string(data[0])
        puts ""
        puts "downloading chapter #{data[1]}" + volume_string + " of #{@manga_name} ( link #{i + 1} / #{@links.size} )"
        chapter_link(link)
      end
      i += 1
    end
    if (miss == true)
      puts "downloaded missing chapters for #{@manga_name}"
      html.generate_chapter_index(@manga_name)
      puts ""
    else
      puts "no missing chapters for #{@manga_name}"
    end
  end
  
  def update()
    todo()
    missing_chapters()
  end

  def data()
    puts "downloading data for " + @manga_name
    raag_data = @doc.xpath('//td[@valign="top"]')
    release = raag_data[0].text.to_i
    author = raag_data[1].text.gsub(/\s+/, "").gsub(',', ", ")
    artist = raag_data[2].text.gsub(/\s+/, "").gsub(',', ", ")
    genres = raag_data[3].text.gsub(/\s+/, "").gsub(',', ", ")
    description = @doc.xpath('//p[@class="summary"]').text
    status = @doc.xpath('//div[@class="data"]/span')[0].text.gsub(/\s+/, "").split(',')[0]
    tmp_type = @doc.xpath('//div[@id="title"]/h1')[0].text.split(' ')
    type = tmp_type[tmp_type.size - 1]
    dir_create(@dir)
    write_cover(@doc, @manga_name, '//div[@class="cover"]/img', @dir + 'cover.jpg', @params[1] + "mangafox/mangas/" + @manga_name + ".jpg")
    File.open(@dir + "description.txt", 'w') do |txt|
      txt << data_conc(@manga_name, description_manipulation(description), @site, @site + @manga_name, author, artist, type, status, genres, release)
    end
    if @manga_in_database == false
      @db.add_manga(@manga_name, description, @site, @site + "manga/" + @manga_name, author, artist, type, status, genres, release)
      puts "added #{@manga_name} to database"
    else
      @db.update_manga(@manga_name, description, author, artist, genres)
    end
  end

  def initialize(db, manga_name, data)
    @manga_name = manga_name
    @params = Params.new().get_params()
    @dir = @params[1] + "mangafox/mangas/" + manga_name + "/"
    @db = db
    @site = "http://mangafox.me/"
    @manga_in_database = db.manga_in_data?(manga_name)
    @doc = get_page(@site + "/manga/" + manga_name)
    if data == true || @manga_in_database == false
      if (redirection_detection(@site + "/manga/" + manga_name) == true)
        puts "could not find manga #{manga_name} at " + @site + "/manga/" + manga_name
        exit 3
      end
      data()
    end    
    if @doc == nil
      raise "failed to get manga " + manga_name + " chapter index"
    end
    @links = extract_links(@doc, @manga_name, '//a[@class="tips"]')
  end
end
