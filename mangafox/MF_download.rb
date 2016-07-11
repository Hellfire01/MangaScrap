class Download_mf
  def link_generator(volume, chapter, page)
    link = @site + "manga/" + @manga_name + "/"
    if (volume >= 0)
      vol_buffer = ((volume >= 10) ? "" : "0")
      link += "v" + vol_buffer + volume.to_s + "/"
    elsif (volume == -2)
      link += "vTBD/"
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
      puts "Error : generated a bad link"
      puts "link = " + link
      return nil
    end
    return link
  end

  def data_extractor(link)
    if (link[link.size - 1] == '/')
      page = 1
    end
    link += "1.html"
    link_split = link.split('/')
    page = link_split[link_split.size - 1].chomp(".html").to_i
    link_split[link_split.size - 2][0] = ''
    chapter = link_split[link_split.size - 2].to_f
    if (chapter % 1 == 0)
      chapter = chapter.to_i
    end
    if link_split.size == 8
      link_split[link_split.size - 3][0] = ''
      if link_split[link_split.size - 3] == "TBD"
        volume = -2
      else
        volume = link_split[link_split.size - 3].to_i
      end
    else
      volume = -1
    end
    ret = Array.new
    ret << volume << chapter << page
    return ret
  end

  def get_links()
    return @links
  end

  def page_link(link)
    page = get_page(link)
    if (page == nil)
      return false
    end
    data = data_extractor(link)
    pic_link = page.xpath('//img[@id="image"]').map{ |img| img['src']}
    if pic_link[0] == nil
      puts "added page #{data[2]}, chapter #{data[1]}" + ((data[0] == -1) ? "" : ", volume #{data[0]} ") + " to todo database"
      @db.add_todo(@manga_name, data[0], data[1], data[2])
      return false
    end
    pic_buffer = get_pic(pic_link[0])
    if pic_buffer == nil
      puts "added page #{data[2]}, chapter #{data[1]}" + ((data[0] == -1) ? "" : ", volume #{data[0]} ") + " to todo database"
      @db.add_todo(@manga_name, data[0], data[1], data[2])
      return false
    end
    if write_pic(pic_buffer, data, @dir) == false
      puts "added page #{data[2]}, chapter #{data[1]}" + ((data[0] == -1) ? "" : ", volume #{data[0]} ") + " to todo database"
      @db.add_todo(@manga_name, data[0], data[1], data[2])
      return false
    end
    return true
  end

  def page(volume, chapter, page)
    link = link_generator(volume, chapter, page)
    if (link == nil)
      return false
    end
    return page_link(link)
  end

  def chapter_link(link)
    puts "link is : " + link
    data = data_extractor(link)
    last_pos = link.rindex(/\//)
    link = link[0..last_pos].strip + "1.html"
    page = get_page(link)
    tmp_number_of_pages = page.xpath('//div[@class="l"]')
    number_of_pages = tmp_number_of_pages.text.split.last.to_i
    if (page == nil)
      puts "could not get data of " + link
      @db.add_todo(@manga_name, data[0], data[1], -1)
      printf "\n"
      STDOUT.flush
      return false
    end
    page_nb = 1
    while page_nb - 1 < number_of_pages
      data = data_extractor(link)
      if (page_link(link) == false)
        printf "\n"
        STDOUT.flush
        puts "error on " + ((data[0] != -1) ? "volume #{data[0]} /" : "") + " chapter #{data[1]} / page #{data[2]}"
        @db.add_todo(@manga_name, data[0], data[1], data[2])
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

  def chapter(volume, chapter)
    if (chapter % 1 == 0)
      chapter = chapter.to_i
    end
    link = link_generator(volume, chapter, 1)
    if (link == nil)
      return false
    end
    return chapter_link(link)
  end

  def download()
    if @db.manga_in_data?(@manga_name) == false
      @links.reverse_each do |link|
        data = data_extractor(link)
        puts link
        puts "downloading " + ((data[0] != -1) ? "volume #{data[0]} /" : "") + " chapter #{data[1]} / page #{data[2]}"
        chapter_link(link)
        puts ""
      end
    else
      puts @manga_name + " whas found in database, updating it"
      MF_update_dw(@manga_name, self, @db)
    end
  end

  def data()
    puts "downloading data for " + @manga_name
    i = 0
    genres = []
    release = 0
    author = ""
    artist = ""
    @doc.xpath('//td[@valign="top"]/a').each do |elem|
      case i
      when 0
        release = elem.text.to_i
      when 1
        author = elem.text
      when 2
        artist = elem.text
      else
        genres << elem
      end
      i += 1
    end
    @description = @doc.xpath('//p[@class="summary"]').text
    status = @doc.xpath('//div[@class="data"]/span')[0].text.gsub(/\s+/, "").split(',')[0]
    tmp_type = @doc.xpath('//div[@id="title"]/h1')[0].text.split(' ')
    type = tmp_type[tmp_type.size - 1]
    dir_create(@dir)
    cover_link = @doc.xpath('//div[@class="cover"]/img').map{ |cover_l| cover_l['src'] }
    cover_buffer = get_pic(cover_link[0])
    if cover_buffer != nil
      cover1 = File.new(@dir + 'cover.jpg', 'wb')
      cover2 = File.new(@params.get_params[1] + "mangafox" + "/" + @manga_name + ".jpg", 'wb')
      until cover_buffer.eof?
        chunk = cover_buffer.read(1024)
        cover1.write(chunk)
        cover2.write(chunk)
      end
      cover1.close
      cover2.close
    else
      puts "WARNING : cover could not download cover"
    end
    File.open(@dir + "description.txt", 'w') do |txt|
      txt << data_conc(@manga_name, @description, @site, @site + @manga_name, author, artist, type, status, genres, release)
    end
    if @db.manga_in_data?(@manga_name) == false
      @db.add_manga(@manga_name, @description, @site, @site + "manga/" + @manga_name, author, artist, type, status, genres, release)
      puts "added #{@manga_name} to database"
    end
  end

  def extract_links()
    tries = 3
    @links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
    while (@links == nil || @links.size == 0) && tries > 0
      puts "error while retreiving chapter index of " + @manga_name
      @doc = get_page(@site + @manga_name)
      if (@doc != nil)
        @links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
      end
      tries -= 1
    end
    if @links == nil || @links.size == 0
      raise "failed to get manga " + @manga_name + " chapter index"
    end
  end

  def initialize(db, manga_name, data)
    @manga_name = manga_name
    @params = Params.new()
    @dir = @params.get_params[1] + "mangafox" + "/" + manga_name + "/"
    @db = db
    @site = "http://mangafox.me/"
    if (redirection_detection(@site + "/manga/" + manga_name) == true)
      puts "could not find manga #{manga_name} at " + @site + "/manga/" + manga_name
      exit 3
    end
    @doc = get_page(@site + "/manga/" + manga_name)
    if @doc == nil
      raise "failed to get manga " + manga_name + " chapter index"
    end
    extract_links()
    if data == true || db.manga_in_data?(manga_name) == false
      data()
    end    
  end
end
