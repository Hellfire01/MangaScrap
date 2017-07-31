# this module is used by every download class
module Base_downloader
  attr_reader :links

  private
  def extract_links(manga)
    Utils_errors::critical_error('The "extract_links" method was not overridden after being included in a download class')
  end

  # used to display an error on a page or chapter download
  def link_err(data, chapter, disp)
    if chapter
      @db.add_todo(@manga_data, data[0], data[1], -1)
      @aff.error_on_page_download(disp)
      @aff.dump_chapter
    else
      @db.add_todo(@manga_data, data[0], data[1], data[2])
      @aff.error_on_page_download(disp)
    end
    false
  end

  def validate_data(description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max, cover_xpath)
    Utils_file::dir_create(@dir)
    Utils_connection::write_cover(@manga_data[:index_page], cover_xpath, @dir + 'cover.jpg', @params[:manga_path] + @manga_data[:website][:dir] + 'mangas/' + @manga_data[:name] + '.jpg')
    File.open(@dir + 'description.txt', 'w') do |txt|
      txt << Utils_file::data_concatenation(@manga_data, Utils_file::description_manipulation(description), author, artist, type, status, genres, release, html_name, alternative_names)
    end
    @aff.data_disp(@manga_data[:in_db])
    if @manga_data[:in_db]
      @db.update_manga(@manga_data[:name], description, author, artist, genres, html_name, alternative_names, rank, rating, rating_max)
    else
      @db.add_manga(@manga_data, description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max)
    end
  end

  def get_page_from_link(link, data, xpath)
    begin
      page = Utils_connection::get_page(link, true)
    rescue RuntimeError
      return link_err(data, false, 'r')
    end
    if page == nil
      return false
    end
    pic_link = page.xpath(xpath).map{|img| img['src']}
    if pic_link[0] == nil
      return link_err(data, false, 'x')
    end
    pic_buffer = Utils_connection::get_pic(pic_link[0], true)
    if pic_buffer == nil || Utils_file::write_pic(pic_buffer, data, @dir) == false
      return link_err(data, false, '!')
    end
    @downloaded_a_page = true
    @aff.downloaded_page(data[2])
    true
  end

  def get_chapter_from_link(pre_link, prep_display, add_to_link)
    data = @manga_data.extract_values_from_link(pre_link)
    @aff.prepare_chapter("downloading #{values_to_string(data[0], data[1], -1)} of #{@manga_data[:name]}" + prep_display)
    if data[0] == -42
      @aff.unmanaged_link(pre_link)
      false
    end
    end_of_link_pos = pre_link.rindex(/\//)
    link = pre_link[0..end_of_link_pos].strip + '1' + add_to_link
    begin
      page = Utils_connection::get_page(link, true)
      if page == nil
        return link_err(data, true, 'X')
      end
    rescue RuntimeError
      return link_err(data, true, 'R')
    end
    number_of_pages = yield page
    if number_of_pages == 0
      return link_err(data, true, '?')
    end
    page_nb = 1
    while page_nb <= number_of_pages
      link = link[0..end_of_link_pos].strip + page_nb.to_s + add_to_link
      data[2] = page_nb
      page_link(link, data)
      page_nb += 1
    end
    @aff.dump_chapter
    @db.add_trace(@manga_data, data[0], data[1], number_of_pages)
    true
  end

  # checks witch are the chapters that have not been downloaded ( they are not in the traces database )
  # the method first gets all of the links from the database and then compares with the links of the website
  def missing_chapters
    traces = @db.get_trace(@manga_data)
    if @todo.size != 0
      @todo = @todo.reject{|e| e[:page] != -1}
    end
    i = 0
    all_data = []
    @links.each do |link|
      all_data << Struct::Data.new(*@manga_data.extract_values_from_link(link), link)
    end
    Utils_misc::sort_chapter_list(all_data).each do |data|
      if traces.count{|_id, _manga_name, vol_value, chap_value| vol_value == data[:volume] && chap_value == data[:chapter]} == 0 &&
      @todo.count{|e| e[:chapter] == data[:chapter]} == 0
        prep_display = " ( link #{i + 1} / #{@links.size} )"
        chapter_link(data[:link], prep_display)
      end
      i += 1
    end
    @aff.dump
  end

  public
  # takes the data array [volume, chapter, page] and casts it into a string
  def self.data_extractor(link)
    Utils_errors::critical_error('The "data_extractor" static method was not overridden after being included in a download class')
  end

  def self.volume_string_to_int(string)
    Utils_errors::critical_error('The "volume_string_to_int" static method was not overridden after being included in a download class')
  end

  def values_to_string(volume, chapter, page)
    volume_string = ''
    chapter_string = ''
    page_string = ''
    case volume
      when -2
        volume_string = 'volume TBD '
      when -3
        volume_string = 'volume NA '
      when -4
        volume_string = 'volume ANT '
      else
        if volume >= 0
          volume_string = "volume #{volume} "
        end
    end
    chapter_string = "chapter #{chapter}" if chapter != nil || chapter == -1
    unless page == nil || page == -1
      page_string = "page #{page}"
      chapter_string += ' '
    end
    volume_string + chapter_string + page_string
  end

  def data_to_string(data)
    values_to_string(data[0], data[1], data[2])
  end

  def link_generator(volume, chapter, page)
    Utils_errors::critical_error('The "link_generator" method was not overridden after being included in a download class')
  end

  def page_link(link, data)
    Utils_errors::critical_error('The "page_link" method was not overridden after being included in a download class')
  end

  def chapter_link(link, prep_display = '')
    Utils_errors::critical_error('The "chapter_link" method was not overridden after being included in a download class')
  end

  # _todo is the method that downloads all the pages / chapters that could not be downloaded previously and where placed
  #     in the _todo database
  # once successfully downloaded, the _todo element is deleted from the _todo database
  # elem[0] = id of line in database ; elem[1] = id of manga in database
  # elem[2] = volume value ; elem[3] = chapter value ; elem[4] = page value
  def todo
    @todo = @db.get_todo(@manga_data)
    if @todo.size != 0
      @aff.prepare_todo
      Utils_misc::sort_chapter_list(@todo, true).each do |elem|
        if elem[:page] != -1 # if page
          data = [] << elem[:volume] << elem[:chapter] << elem[:page]
          if page_link(link_generator(elem[:volume], elem[:chapter], elem[:page]), data)
            @db.delete_todo(elem[:id])
          end
        else # if chapter
          if chapter_link(link_generator(elem[:volume], elem[:chapter], 1))
            @db.delete_todo(elem[:id])
          end
        end
      end
      @aff.end_todo
    end
    @downloaded_a_page
  end

  # the update method will first check for _todo elements to download then check for missing chapters
  # it only calls the data method if a page was downloaded
  def update
    todo
    missing_chapters
    if @downloaded_a_page
      data
    end
    @downloaded_a_page
  end

  # the data method is used to download the description, author and artists names, ...
  # by default it raises an exception and MUST be overridden in the class
  def data
    Utils_errors::critical_error('The "data" method was not overridden after being included in a download class')
  end

  # all download classes use the same initializer with a Manga_data as argument ( it must be resolved )
  # variables are :0
  # @manga_data => the Manga_data class
  # @downloaded_a_page => allows the class to know if a page was ( or not ) downloaded
  # @extracted_data => used to block multiple calls to the data method, does not download if set to true
  # @params => all of the download parameters
  # @dir => the directory in witch the mangas are placed
  # @db => the database instance todo : delete the variable
  # @aff => the attached DownloadDisplay class
  # @_todo => an arry containing all of the _todo elements. Used to avoid downloading the same chapter twice when updating
  def initialize(manga, download_data = true)
    @manga_data = manga
    @downloaded_a_page = false
    @extracted_data = !download_data
    @params = Params.instance.download
    @dir = @params[:manga_path] + manga[:website][:dir] + 'mangas/' + manga[:name] + '/'
    @db = Manga_database.instance
    # doc is the variable that stores the raw data of the manga's page
    @aff = DownloadDisplay.new(manga)
    @todo = []
    if manga[:index_page] == nil
      manga.set_index_page(Utils_connection::get_page(manga[:link], true))
      if manga[:index_page] == nil
        raise 'failed to get manga ' + manga[:name] + "'s chapter index"
      end
    end
    @links = extract_links(manga).reverse
    data if download_data || !manga[:in_db]
  end
end
