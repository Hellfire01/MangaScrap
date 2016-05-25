$nb_tries = -1
$between_sleep = -1
$failure_sleep = -1

#inits the global variables
def init_utils(db)
  params = db.get_params()
  $between_sleep = params[2]
  $failure_sleep = params[3]
  $nb_tries = params[4]
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
      puts error.message
      abort("connection is lost, stopping programm")
    end
  end
  return false
end  

# conect to link and download page
def get_link(link)
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
      puts 'could not get ' + link + ' after ' + $nb_tries.to_s + ' tries'
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
  rescue URI::InvalidURIError
    puts "Warning : bad url"
    puts link
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

# open -t option file and return array
def get_mangas()
  ret = Array.new
  if (ARGV[1] == "-t")
    line_num = 0
    begin
      text = File.open(ARGV[2]).read
    rescue Exception => e
      abort(e.message)
    end
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      elems = line.split(" ")
      if (elems.size > 2)
	abort("there is more than one space on line #{line_num}")
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
