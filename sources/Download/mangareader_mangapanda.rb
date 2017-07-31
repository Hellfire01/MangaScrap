class Download_Mangareader_Pandamanga
  include Base_downloader
  
  private
  def extract_links(manga)
    tries = @params[4]
    links = @manga_data[:index_page].xpath('//table[@id="listing"]/tr/td/a').map{ |link| link['href'] }
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
      ret << @manga_data[:website][:link] + link[1..-1]
    end
    ret
  end

  # warning : the volume value is not used for both mangareader and pandamanga
  def link_generator(_volume, chapter, page)
    @manga_data[:website][:link] + @manga_data[:name] + '/' + ((chapter % 1 == 0) ? chapter.to_i.to_s : chapter.to_s) + '/' + page.to_s
  end

  public
  # downloads just a page from the link
  def page_link(link, data)
    get_page_from_link(link, data, '//img')
  end

  # downloads all of a chapter from the link
  def chapter_link(link, prep_display = '')
    get_chapter_from_link(link, prep_display, '') do |page|
      page.xpath('//option').last.text.to_i
    end
  end

  def self.volume_string_to_int(string)
    string.to_i
  end

  # used to get the volume, chapter and page of a link as an array
  def self.data_extractor(link)
    link_split = link.split('/')
    if link_split.size == 5
      page = 1
      chapter = link_split[link_split.size - 1].to_i
    else
      page = link_split[link_split.size - 1].to_i
      chapter = link_split[link_split.size - 2].to_i
    end
    ret = Array.new
    ret << -1 << chapter << page
    ret
  end

  def data
    unless @extracted_data
      @extracted_data = true
      tmp = @manga_data[:index_page].xpath('//div[@id="mangaproperties"]/table/tr')
      alternative_names = tmp[1].text.split(':')[1].strip
      release = tmp[2].text.split(':')[1].strip.to_i
      author = tmp[4].text.split(':')[1].strip
      artist = tmp[5].text.split(':')[1].strip
      genres = tmp[7].text.split(':')[1].strip
      description = @manga_data[:index_page].xpath('//div[@id="readmangasum"]/p')[0].text
      status = tmp[3].text.split(':')[1].strip
      rank = -1
      rating = -1
      rating_max = -1
      type = (tmp[6].text.split(':')[1].strip == 'Right to Left') ? 'Manga' : 'Manhwa'
      html_name = @manga_data[:index_page].xpath('//h2')[0].text
      validate_data(description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max, '//div[@id="mangaimg"]/img')
    end
  end
end
