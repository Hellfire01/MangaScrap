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
  def self.download_rescue(tries, link, error, message, silent = false)
    if tries > 0
      tries -= 1
      sleep_manager(error)
      tries
    else
      unless silent
        print "\n"
        STDOUT.flush
        puts message + ' ' + link + ' after ' + $download_params[:nb_tries_on_fail].to_s + ' tries'
        puts 'message is : ' + error
      end
      nil
    end
  end

  public
  # initialises the global variables
  def self.init_utils
    $download_params = Params.instance.download
  end

  def self.download(link, silent, error_message)
    tries ||= $download_params[:nb_tries_on_fail]
    while tries != 0
      sleep($download_params[:between_sleep])
      request = Typhoeus::Request.new(link, accept_encoding: 'gzip', connecttimeout: $download_params[:connect_timeout],
                                      timeout: $download_params[:download_timeout], followlocation: false)
      request.on_complete do |response|
        if response.success?
          return response.body
        elsif response.timed_out? # time out
          tries = download_rescue(tries, link, 'time out', error_message, silent)
          if tries == nil
            break
          end
        elsif response.code == 301 || response.code == 302 # redirections
          raise 'redirection'
        else # all other errors
          tries = download_rescue(tries, link, "http code error #{response.code}", error_message, silent)
          if tries == nil
            break
          end
        end
      end
      request.run
    end
    raise 'could not connect'
  end

  # connects to link and download page
  def self.get_page(link, silent = false)
    html = download(link, silent, 'could not download picture')
    if html == nil
      return nil
    end
    Nokogiri::HTML(html, 'utf-8')
  end

  # connects to link and download picture
  def self.get_pic(link, silent = false)
    download(link, silent, 'could not download picture')
  end

  # extracts the cover link, downloads it and writes it twice
  def self.write_cover(doc, xpath, path1, path2)
    cover_link = doc.xpath(xpath).map{ |cover_l| cover_l['src'] }
    if cover_link.size == 0
      Utils_errors::critical_error('Could not extract of element using the following xpath : "' + xpath + '"')
    end
    cover_buffer = get_pic(cover_link[0], true)
    if cover_buffer == nil
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
