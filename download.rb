require 'nokogiri'
require_relative 'get_link'

class Download
  def get_chapter_values()
    ret = []
    @links.reverse.each do |chapter|
      chap_cut = chapter.split("/")
      tmp = chap_cut[chap_cut.size - 2]
      tmp.slice!(0)
      ret << tmp.to_f
    end
    return ret
  end

  def _extract_link(chapter_nb)
    i = 0
    @links.each do |chapter|
      chap_cut = chapter.split("/")
      tmp = chap_cut[chap_cut.size - 2]
      tmp.slice!(0)
      @chapter_value = tmp.to_f
      if (@chapter_value == chapter_nb)
	break
      end
      i += 1
    end
    if (i == @links.size)
      puts "could not find the requested chapter (#{chapter_nb}) in the manga page"
      p @links
      abort()
    end
    return @links[i]
  end

  def _page(chapter_nb, page_nb, page)
    pic_link = page.xpath('//img[@id="image"]').map{ |img| img['src']}
    if pic_link[0] == nil
      abort("could not extract picture source link chapter #{chapter_nb} / page #{page_nb}")
    end
    pic_buffer = get_pic(pic_link[0])
    name_buffer = file_name(@dir, @chapter_value, page_nb)
    if pic_buffer != nil
      File.open(name_buffer + ".jpg", 'wb') do |pic|
	pic << pic_buffer.read
      end
    else
      File.open(name_buffer + ".txt", 'w') do |pic|
	pic << "could not be downloaded"
      end
      @db.add_todo(@manga_name, @chapter_value, page_nb)
      puts "added link of page #{page_nb} to todo database ( pic will be downloaded on next update )"
    end
  end

  def page(chapter_nb, page_nb)
    chapter = _extract_link(chapter_nb)
    last_pos = chapter.rindex(/\//)
    link = chapter[0..last_pos].strip + page_nb.to_s + ".html"
    page = get_link(link)
    if (page == nil)
      puts "leaving programm => could not download data from #{link}"
      return false
    end
    puts "chapter #{chapter_nb}/#{@links.size} => #{@chapter_value.to_s} / page #{page_nb}"
    _page(chapter_nb, page_nb, page)
    return true
  end

  def _chapter(chapter, chapter_nb)
    link = chapter
    next_ = true
    page = get_link(link)
    page_nb = 1
    while next_ == true
      _page(chapter_nb, page_nb, page)
      page_nb += 1
      last_pos = chapter.rindex(/\//)
      link = chapter[0..last_pos].strip + page_nb.to_s + ".html"
      previous = page
      page = get_link(link)
      if (page.xpath('//option[@selected="selected"]')[0].text == previous.xpath('//option[@selected="selected"]')[0].text)
	puts "end of chapter with #{page_nb - 1} pages"
	break
      end
    end
    @db.add_trace(@manga_name, @chapter_value)
  end

  def chapter(chapter_nb)
    chapter = _extract_link(chapter_nb)
    puts "downloading chapter #{chapter_nb}"
    _chapter(chapter, chapter_nb)
  end

  def cover()
    puts "downloading cover"
    cover_link = @doc.xpath('//div[@class="cover"]/img').map{ |cover_l| cover_l['src'] }
    cover_buffer = get_pic(cover_link[0])
    if cover_buffer != nil
      open(@dir + 'cover.jpg', 'wb') do |pic|
	pic << open(cover_buffer).read
      end
    else
      puts "WARNING : could not download cover"
    end
  end

  def manga()
    cover()
    puts "getting links"
    chapter_nb = 1
    @links.reverse.each do |chapter|
      chap_cut = chapter.split("/")
      tmp = chap_cut[chap_cut.size - 2]
      tmp.slice!(0)
      @chapter_value = tmp.to_f
      puts "chapter #{chapter_nb}/#{@links.size} => #{@chapter_value.to_s}"
      _chapter(chapter, chapter_nb)
      chapter_nb += 1
    end
  end

  def initialize(db, manga_name, work_dir, site)
    @manga_name = manga_name
    @dir = work_dir + manga_name + "/"
    @db = db
    @site = site
    @doc = get_link(site + manga_name)
    @links = @doc.xpath('//a[@class="tips"]').map{ |link| link['href'] }
    begin
      open(site + manga_name) do |resp|
	if (resp.base_uri.to_s != (site + manga_name))
	  abort ("could not find manga #{manga_name} at " + site + manga_name)
	end
      end
    rescue OpenURI::HTTPError => error
      puts "exception when trying to connect to site"
      puts error.message
    end
    if @doc == nil || @links == nil || @links.size == 0
      abort("failed to get manga " + manga_name + " chapter index")
    end
    if db.manga_in_data?(manga_name) == false
      @db.add_manga(manga_name, @doc.xpath('//p[@class="summary"]').text, site, site + manga_name, @links.size)
    end
    dir_create(@dir)
  end
end

def download(db, work_dir)
  if (ARGV.size == 1)
    puts "missing argument : --help for more information"
  else
    site = "http://mangafox.me/manga/"
    if (ARGV.size > 2)
      site = ARGV[2].to_s
    end
    name = ARGV[1].to_s
    if (db.manga_in_data?(name) == true)
      puts "manga was found in database, updating it"
      update(db, work_dir)
    else
      dl = Download.new(db, name, work_dir, site)
      dl.manga()
    end
  end
end
