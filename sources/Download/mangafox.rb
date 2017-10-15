class Download_Mangafox
  include Base_downloader

  private
  def extract_links(manga)
    links = @manga_data[:index_page].xpath('//a[@class="tips"]').map{ |link| link['href'] }
    if links == nil || links.size == 0
      raise ('failed to get manga '.red + manga[:name].yellow + ' chapter index'.red)
    end
    links
  end

  public
  def self.volume_string_to_int(string)
    case string
      when 'TBD'
        volume = -2
      when 'NA'
        volume = -3
      when 'ANT'
        volume = -4
      else
        volume = string.to_i
    end
    volume
  end

  def self.data_extractor(link)
    link += '1.html'
    link_split = link.split('/')
    page = link_split[link_split.size - 1].chomp('.html').to_i
    link_split[link_split.size - 2][0] = ''
    chapter = link_split[link_split.size - 2].to_f
    if chapter % 1 == 0
      chapter = chapter.to_i
    end
    if link_split.size == 8
      link_split[link_split.size - 3][0] = ''
      if link_split[link_split.size - 3] =~ /\A\d+\z/
        volume = link_split[link_split.size - 3].to_i
      else
        if link_split[link_split.size - 3] == 'NA'
          volume = -3
        elsif link_split[link_split.size - 3] == 'TBD'
          volume = -2
        elsif link_split[link_split.size - 3] == 'ANT'
          volume = -4
        else
          volume = -42 # error value
        end
      end
    else
      volume = -1 # no volume
    end
    ret = Array.new
    ret << volume << chapter << page
    ret
  end

  def link_generator(volume, chapter, page)
    chapter = chapter.to_i if chapter % 1 == 0
    link = @manga_data[:website][:link] + 'manga/' + @manga_data[:name] + '/'
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
    get_chapter_from_link(link, prep_display, '.html') do |page|
      page.xpath('//div[@class="l"]').text.split.last.to_i
    end
  end

  def data
    alternative_names = @manga_data[:index_page].xpath('//div[@id="title"]/h3').text
    release_author_artist_genres = @manga_data[:index_page].xpath('//td[@valign="top"]')
    release = release_author_artist_genres[0].text.to_i
    author = release_author_artist_genres[1].text.gsub(/\s+/, '').gsub(',', ', ')
    artist = release_author_artist_genres[2].text.gsub(/\s+/, '').gsub(',', ', ')
    genres = release_author_artist_genres[3].text.gsub(/\s+/, '').gsub(',', ', ')
    description = @manga_data[:index_page].xpath('//p[@class="summary"]').text
    data = @manga_data[:index_page].xpath('//div[@class="data"]/span')
    status = data[0].text.gsub(/\s+/, '').split(',')[0]
    rank = data[1].text[/\d+/]
    rating = data[2].text[/\d+[.,]\d+/]
    rating_max = 5 # rating max is a constant in mangafox
    tmp_type = @manga_data[:index_page].xpath('//div[@id="title"]/h1')[0].text.split(' ')
    type = tmp_type[tmp_type.size - 1]
    html_name = tmp_type.take(tmp_type.size - 1).join(' ')
    validate_data(description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max, '//div[@class="cover"]/img')
  end
end
