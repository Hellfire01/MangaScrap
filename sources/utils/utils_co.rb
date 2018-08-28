$download_params = nil

module Utils_connection
  private
  # used to know hom much sleep time is needed
  def self.sleep_manager(error)
    if error.class.to_s == 'SocketError' # connection error
      sleep($download_params[:error_sleep])
    else
      sleep($download_params[:failure_sleep])
    end
  end

  # exception manager for the utils_co.rb functions
  def self.download_rescue(tries, link, error, http_code, silent, type)
    if tries > 0
      tries -= 1
      sleep_manager(error)
      tries
    else
      raise Connection_exception.new(Struct::Connection_error.new(tries, link, error, http_code, silent, Download_type::related_char_error(type)))
    end
  end

  def self.download(link, silent, type)
    tries ||= $download_params[:nb_tries_on_fail]
    while tries != 0
      sleep($download_params[:between_sleep])
      request = Typhoeus::Request.new(link, accept_encoding: 'gzip', connecttimeout: $download_params[:connect_timeout], timeout: $download_params[:download_timeout], followlocation: false)
      request.on_complete do |response|
        if response.success?
          return response.body
        elsif response.timed_out?
          tries = download_rescue(tries, link, 'time out', response.code, silent, type)
        elsif response.code == 301 || response.code == 302 # redirections
          raise Connection_exception.new(Struct::Connection_error.new(link, 'redirection', tries, silent, response.code, 'r'))
        else # all other errors
          tries = download_rescue(tries, link, 'http error', response.code, silent, type)
        end
      end
      request.run
    end
    raise Connection_exception.new(Struct::Connection_error.new(link, 'could not connect', tries, silent, -1, '/'))
  end

  public
  # initialises the global variables
  def self.init_utils
    $download_params = Params.instance.download
  end

  # connects to link and download page
  def self.get_page(link, type, silent)
    Nokogiri::HTML(download(link, silent, type), 'utf-8')
  end

  # connects to link and download picture
  def self.get_pic(link, type, silent)
    download(link, silent, type)
  end

  # extracts the cover link, downloads it and writes it twice
  def self.write_cover(doc, xpath, path1, path2)
    cover_link = doc.xpath(xpath).map{ |cover_l| cover_l['src'] }
    if cover_link.size == 0
      Utils_errors::critical_error('Could not extract of element using the following xpath : "' + xpath + '"')
    end
    begin
      cover_buffer = get_pic(cover_link[0], Download_type::COVER, true)
    rescue Connection_exception
      cover_buffer = File.open('./pictures/other/404.png')
    end
    if cover_buffer != nil
      File.open(path1, 'wb') do |pic|
        pic << cover_buffer
      end
      File.open(path2, 'wb') do |pic|
        pic << cover_buffer
      end
    else
      puts 'WARNING : cover could not download cover'
    end
  end
end
