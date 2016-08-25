$nb_tries = -1
$between_sleep = -1
$failure_sleep = -1
$error_sleep = -1
$catch_fatal = "false"

#inits the global variables
def init_utils()
  db = Params.new()
  params = db.get_params()
  $between_sleep = params[2]
  $failure_sleep = params[3]
  $nb_tries = params[4]
  $error_sleep = params[5]
  $catch_fatal = params[7]
end

def sleep_manager(error)
  if error.class.to_s == "SocketError" # connection error
    sleep($error_sleep)
  else
    sleep($failure_sleep)
  end
end

def download_rescue(tries, link, error, message)
  if tries > 0
    tries -= 1
    sleep_manager(error)
    return tries
  else
    print "\n"
    STDOUT.flush
    puts message + ' ' + link + ' after ' + $nb_tries.to_s + ' tries'
    puts "message is : " + error.message
    return nil
  end
end

def rescue_fatal(error)
  if $catch_fatal == "false"
    print "\n"
    STDOUT.flush
    puts "Warning : exception occured, message is : " + error.message
    puts "Exception class is : " + error.class.to_s
    puts "raising it again"
    puts ""
    raise error
  else
    if error.class.to_s != "fatal"
      raise error
    end
  end
end

# detects if there whas a redirection on the required link
def redirection_detection(url)
  tries ||= $nb_tries
  begin
    open(url) do |resp|
      if (resp.base_uri.to_s != url)
        return true
      end
    end
  rescue StandardError => error
    if tries > 0
      tries -= 1
      sleep_manager(error)
      retry
    else
      puts "connection is lost or could not find manga, stopping programm"
      puts url
      puts "message is : " + error.message
      exit 3
    end
  rescue Exception => error
    rescue_fatal(error)
  end
  return false
end  

# conect to link and download page
def get_page(link)
  tries ||= $nb_tries
  begin
    page = Nokogiri::HTML(open(link, "User-Agent" => "Ruby/#{RUBY_VERSION}")) do |noko|
      noko.noblanks.noerror
    end
  rescue StandardError => error
    tries = download_rescue(tries, link, error, 'could not download picture')
    if (tries == nil)
      return nil
    end
    retry
  rescue Exception => error
    rescue_fatal(error)
  end
  sleep($between_sleep)
  return page
end

# conect to link and download picture
def get_pic(link)
  safe_link = link.gsub(/[\[\]]/) { '%%%s' % $&.ord.to_s(16) }
  tries ||= $nb_tries
  begin
    page = open(safe_link, "User-Agent" => "Ruby/#{RUBY_VERSION}")
  rescue URI::InvalidURIError => error
    puts "Warning : bad url"
    puts link
    puts "message is : " + error.message
    return nil
  rescue StandardError => error
    tries = download_rescue(tries, link, error, 'could not download picture')
    if (tries == nil)
      return nil
    end
    retry
  rescue Exception => error
    rescue_fatal(error)
  end
  sleep($between_sleep)
  return page
end

def data_extractor_MF(link)
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
    if link_split[link_split.size - 3] =~ /\A\d+\z/
      volume = link_split[link_split.size - 3].to_i
    else
      if link_split[link_split.size - 3] == "NA"
        volume = -3
      elsif link_split[link_split.size - 3] == "TBD"
        volume = -2
      elsif link_split[link_split.size - 3] == "ANT"
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
  return ret
end
