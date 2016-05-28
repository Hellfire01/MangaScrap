class Download
  def cover()
    cover_link = @doc.xpath('//div[@class="cover"]/img').map{ |cover_l| cover_l['src'] }
    cover_buffer = get_pic(cover_link[0])
    if cover_buffer != nil
      open(@dir + 'cover.jpg', 'wb') do |pic|
	pic << cover_buffer.read()
      end
    else
      puts "WARNING : cover could not download cover"
    end
  end

  def get_volume_values()
    ret = []
    @links.reverse_each do |chapter|
      if @has_volumes == true
	chap_cut = chapter.split("/")
	tmp = chap_cut[chap_cut.size - 3]
	tmp.slice!(0)
	ret << tmp.to_i
      else
	ret << 0
      end
    end
    return ret
  end

  def get_chapter_values()
    ret = []
    @links.reverse_each do |chapter|
      chap_cut = chapter.split("/")
      tmp = chap_cut[chap_cut.size - 2]
      tmp.slice!(0)
      ret << tmp.to_f
    end
    return ret
  end

  def _extract_link(volume_nb, chapter_nb)
    i = 0
    link_ret = nil
    @links.reverse_each do |link|
      link_cut = link.split("/")
      if link_cut[link_cut.size - 1] != "1.html"
        link += "1.html"
      end
      if (@has_volumes == true)
	vol_tmp = link_cut[link_cut.size - 3]
	vol_tmp[0] = ''
	vol_value = vol_tmp.to_i
	if (volume_nb != vol_value)
          i += 1
	  next
	end
      end
      chap_tmp = link_cut[link_cut.size - 2]
      chap_tmp[0] = ''
      chap_value = chap_tmp.to_f
      if (chapter_nb != chap_value)
        i += 1
	next
      else
	link_ret = link
	break
      end
    end
    if (link_ret == nil)
      abort("Error, could not find volume #{volume_nb} / chapter #{chapter_nb} in links")
    end
    puts link_ret
    return link_ret
  end

  def _page(volume_nb, chapter_nb, page_nb, page, del = false)
    pic_link = page.xpath('//img[@id="image"]').map{ |img| img['src']}
    if pic_link[0] == nil
      puts "could not extract picture source link chapter #{chapter_nb} / page #{page_nb}"
      if (@db.add_todo(@manga_name, volume_nb, chapter_nb, page_nb) == true)
	puts "added link of page #{page_nb} to todo database ( pic will be downloaded on next update )"
      end
      return false
    end
    pic_buffer = get_pic(pic_link[0])
    if pic_buffer == nil
      return false
    end
    name_buffer = file_name(@dir, volume_nb, chapter_nb, page_nb)
    if pic_buffer != nil
      File.open(name_buffer + ".jpg", 'wb') do |pic|
	pic << pic_buffer.read
      end
      if (del == true)
	if (File.exists?(name_buffer + ".txt") == true)
	  File.delete(name_buffer + ".txt")
	end
      end
    else
      File.open(name_buffer + ".txt", 'w') do |pic|
	pic << "could not be downloaded"
      end
      if @db.add_todo(@manga_name, volume_nb, chapter_nb, page_nb) == true
	puts "added link of page #{page_nb} to todo database ( pic will be downloaded on next update )"
      end
    end
    return true
  end

  def page(volume_nb, chapter_nb, page_nb, del = false)
    chapter = _extract_link(volume_nb, chapter_nb)
    last_pos = chapter.rindex(/\//)
    link = chapter[0..last_pos].strip + page_nb.to_s + ".html"
    page = get_link(link)
    if (page == nil)
      puts "leaving programm => could not download data from #{link}"
      return false
    end
    puts "chapter #{chapter_nb}/#{@links.size} => #{chapter_nb.to_s} / page #{page_nb}"
    if (_page(volume_nb, chapter_nb, page_nb, page, del) == false)
      puts "link = " + link
      return false
    end
    return true
  end

  def _chapter(vol_value, chapter, chapter_nb)
    next_ = true
    last_pos = chapter.rindex(/\//)
    link = chapter[0..last_pos].strip + "1.html"
    page = get_link(link)
    if (page == nil)
      puts "could not get chapter #{chapter_nb} link, adding it to doto database"
      @db.add_todo(@manga_name, vol_value, chapter_nb, -1)
      return false
    end
    page_nb = 1
    while next_ == true
      if (_page(vol_value, chapter_nb, page_nb, page) == false)
	puts "link = " + link
      end
      page_nb += 1
      last_pos = chapter.rindex(/\//)
      link = chapter[0..last_pos].strip + page_nb.to_s + ".html"
      if (redirection_detection(link) == true)
	puts "end of chapter with #{page_nb - 1} pages"
	break
      end
      page = get_link(link)
    end
    @db.add_trace(@manga_name, vol_value, chapter_nb)
    return true
  end

  def chapter(volume_nb, chapter_nb)
    link = _extract_link(volume_nb, chapter_nb)
    ret = _chapter(volume_nb, link, chapter_nb)
    puts ""
    return ret
  end

  def manga()
    puts "getting data"
    chapters = get_chapter_values()
    volumes = get_volume_values()
    i = 0
    cover()
    update_data()
    while i < chapters.size
      puts "downloading volume #{volumes[i]} / chapter #{chapters[i]} ( link #{i + 1} / #{chapters.size} )"
      chapter(volumes[i], chapters[i])
      i += 1
    end
  end

  def update_data()
    @db.update_manga(@manga_name, @description)
  end

  def initialize(db, manga_name, site)
    @manga_name = manga_name
    @dir = db.get_params[1] + manga_name + "/"
    @db = db
    @site = site
    @doc = get_link(site + manga_name)
    if @doc == nil
      abort("failed to get manga " + manga_name + " chapter index")
    end
    @links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
    if (redirection_detection(site + manga_name) == true)
      abort ("could not find manga #{manga_name} at " + site + manga_name)
    end
    if @links == nil || @links.size == 0
      abort("failed to get manga " + manga_name + " chapter index")
    end
    @has_volumes = false
    if @links[0].split('/').size == 8
      @has_volumes = true
    end
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
    is_in_db = db.manga_in_data?(manga_name)
    if is_in_db == false
      puts "added #{manga_name} to database"
      @db.add_manga(manga_name, @description, site, site + manga_name, author, artist, type, status, genres, release)
    end
    dir_create(@dir)
    if is_in_db == false
      cover()
    end
    File.open(@dir + "description.txt", 'w') do |txt|
      txt << data_conc(manga_name, @description, site, site + manga_name, author, artist, type, status, genres, release)
    end
  end
end
