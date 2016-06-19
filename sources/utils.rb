$nb_tries = -1
$between_sleep = -1
$failure_sleep = -1
$error_sleep = -1

#inits the global variables
def init_utils()
  db = Params.new()
  params = db.get_params()
  $between_sleep = params[2]
  $failure_sleep = params[3]
  $nb_tries = params[4]
  $error_sleep = params[5]
end

# used for the description.txt file of every manga
def data_conc(manga_name, description, site, link, author, artist, type, status, genres, release)
  ret =  "name         = " + manga_name + "\n"
  ret += "author       = " + author + "\n"
  ret += "artist       = " + artist + "\n"
  ret += "release year = " + release.to_s + "\n"
  ret += "type         = " + type + "\n"
  ret += "status       = " + status + "\n"
  ret += "genres       = " + genres.join(", ") + "\n"
  ret += "\n"
  ret += "site = " + site + "\n"
  ret += "link = " + link + "\n"
  ret += "\n"
  ret += "description :\n"
  ret += description
  ret += "\n"
  return ret
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
  rescue => error
    if tries > 0
	tries -= 1
	sleep($failure_sleep)
	retry
    else
      puts "connection is lost or could not find manga, stopping programm"
      puts url
      puts "message is : " + error.message
      abort()
    end
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
  rescue => error
    if tries > 0
      tries -= 1
      sleep($failure_sleep)
      retry
    else
      puts 'could not get page ' + link + ' after ' + $nb_tries.to_s + ' tries'
      puts "message is : " + error.message
      return nil
    end
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
  rescue => error
    if tries > 0
	tries -= 1
	sleep($failure_sleep)
	retry
    else
      puts 'could not get picture ' + safe_link + ' after ' + $nb_tries.to_s + ' tries'
      puts "message is : " + error.message
      return nil
    end
  end
  sleep($between_sleep)
  return page
end

# determines if directory exists
def dir_create(directory)
  if Dir.exists?(directory) == false
    puts directory + " does not exist, creating it"
    FileUtils.mkdir_p(directory)
  end
end

# get every file name
def list_dir(work_dir)
  puts "listing directory " + work_dir
  Dir.foreach(Dir.home + "/Documents/web_tests/.") do |file|
    puts file
  end
end

# open -f option file and return array
def get_mangas()
  ret = Array.new
  if (ARGV[1] == "-f")
    line_num = 0
    begin
      text = File.open(ARGV[2]).read
    rescue => e
      abort(e.message)
    end
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      elems = line.split(" ")
      if (elems.size > 2)
        abort("there is more than one space on line #{line_num} this should not be possible, ./MangaScrap -h for help")
      end
      if (elems.size == 1)
        elems << "http://mangafox.me/"
      end
      ret << elems
      line_num += 1
    end
  else
    return nil
  end
  ARGV.delete_at(2)
  ARGV.delete_at(1)
  return ret
end

# get file name
def file_name(dir, vol_value, chap_value, page_value)
  chap_str = chap_value.to_s
  val = chap_str.index('.')
  if (val != nil)
    chap_str[val] = ''
  else
    chap_str += '0'
  end
  if vol_value == -1
    vol_buffer = "XXXX"
  elsif vol_value == -2
    vol_buffer = "_TBD"
  else
    vol_buffer = ((vol_value >= 1000) ? "" : ((vol_value >= 100) ? "0" : ((vol_value >= 10) ? "00" : "000")))
    vol_buffer += vol_value.to_s
  end
  chap_buffer = ((chap_value >= 1000) ? "" : ((chap_value >= 100) ? "0" : ((chap_value >= 10) ? "00" : "000")))
  page_buffer = ((page_value >= 1000) ? "" : ((page_value >= 100) ? "0" : ((page_value >= 10) ? "00" : "000")))
  name_buffer = dir + "manga_v" + vol_buffer + "_c" + chap_buffer + chap_str + "_p" + page_buffer + page_value.to_s
  return name_buffer
end
