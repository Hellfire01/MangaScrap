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
    link += "c" + chap_buffer + chapter.to_s + "/"
    link += page.to_s + ".html"
    if (redirection_detection(link) == true)
      puts "Error : generated a bad link"
      puts "link = " + link
      return nil
    end
    puts link
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

  def write_pic(pic_buffer, data)
    name_buffer = file_name(@dir, data[0], data[1], data[2])
    if pic_buffer != nil
      File.open(name_buffer + ".jpg", 'wb') do |pic|
        pic << pic_buffer.read
      end
      if (File.exists?(name_buffer + ".txt") == true)
        File.delete(name_buffer + ".txt")
      end
    else
      File.open(name_buffer + ".txt", 'w') do |pic|
        pic << "could not be downloaded"
      end
      puts "Error : no picture to save"
      return false
    end
    return true
  end

  def page_link(link)
    page = get_page(link)
    data = data_extractor(link)
    pic_link = page.xpath('//img[@id="image"]').map{ |img| img['src']}
    if pic_link[0] == nil
      return false
    end
    pic_buffer = get_pic(pic_link[0])
    if pic_buffer == nil
      return false
    end
    return write_pic(pic_buffer, data)
  end

  def page(volume, chapter, page)
    link = link_generator(volume, chapter, page)
    if (link == nil)
      return false
    end
    return page_link(link)
  end

  def chapter_link(link)
    data = data_extractor(link)
    next_ = true
    last_pos = link.rindex(/\//)
    link = link[0..last_pos].strip + "1.html"
    page = get_page(link)
    if (page == nil)
      puts "could not get data of " + link
      @db.add_todo(@manga_name, data[0], data[1], -1)
      return false
    end
    page_nb = 1
    while next_ == true
      data = data_extractor(link)
      if (page_link(link) == false)
        puts "error on " + ((data[0] != -1) ? "volume #{data[0]} /" : "") + " chapter #{data[1]} / page #{data[2]}"
        @db.add_todo(@manga_name, data[0], data[1], data[2])
      end
      page_nb += 1
      last_pos = link.rindex(/\//)
      link = link[0..last_pos].strip + page_nb.to_s + ".html"
      if (redirection_detection(link) == true)
        puts "end of chapter with #{page_nb - 1} pages"
        next_ = false
      else
        page = get_page(link)
      end
    end
    @db.add_trace(@manga_name, data[0], data[1])
    return true
  end

  def chapter(volume, chapter)
    link = link_generator(volume, chapter, 1)
    if (link == nil)
      return false
    end
    return chapter_link(link)
  end

  # entry point only ( not used by the class )
  def volume(volume)
  end

  def download()
    if db.manga_in_data?(manga_name) == false
      @links.reverse_each do |link|
        data = data_extractor(link)
        puts link
        puts "downloading " + ((data[0] != -1) ? "volume #{data[0]} /" : "") + " chapter #{data[1]} / page #{data[2]}"
        chapter_link(link)
        puts ""
      end
    else
      puts @manga_name + " whas found in database, updating it"
      update(@manga_name)
    end
  end

  def data()
    puts "downloading data"
    i = 0
    genres = []
    release = 0
    author = ""
    artist = ""
    @doc.xpath('//td[@valign="top"]/a').each do |elem|
      if i == 0
        release = elem.text.to_i
      elsif i == 1
        author = elem.text
      elsif i == 2
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
      open(@dir + 'cover.jpg', 'wb') do |pic|
      	pic << cover_buffer.read()
      end
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
    tries = 10
    @links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
    while (@links == nil || @links.size == 0) && tries > 0
      puts "error while retreiving chapter index of " + @manga_name
      @doc = get_page(@site + @manga_name)
      if (doc != nil)
        @links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
      end
      tries -= 1
    end
    if @links == nil || @links.size == 0
      abort("failed to get manga " + @manga_name + " chapter index")
    end
  end

  def initialize(db, manga_name)
    @manga_name = manga_name
    @params = Params.new()
    @dir = @params.get_params[1] + "magafox" + "/" + manga_name + "/"
    @db = db
    @site = "http://mangafox.me/"
    if (redirection_detection(@site + "/manga/" + manga_name) == true)
      abort ("could not find manga #{manga_name} at " + @site + "/manga/" + manga_name)
    end
    @doc = get_page(@site + "/manga/" + manga_name)
    if @doc == nil
      abort("failed to get manga " + manga_name + " chapter index")
    end
    extract_links()
    if db.manga_in_data?(manga_name) == false
      data()
    end    
  end
end
