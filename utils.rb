#change this variable to set the number of tries per link and picture
$nb_tries = 25

#change this variable to set the sleeping time between downloads
#Warning !!! => setting these variables too low may result in an IP ban
$between_sleep = 0.25
$failure_sleep = 1

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
    page = Nokogiri::HTML(open(link, "User-Agent" => "Ruby/#{RUBY_VERSION}", "From" => "mat1994@free.fr")) do |noko|
      noko.noblanks.noerror
    end
  rescue => error
    if tries > 0
	tries -= 1
	sleep($failure_sleep)
	retry
    else
      puts 'could nor get ' + link + ' after ' + $nb_tries.to_s + ' tries'
      puts error.message
      return nil
    end
  end
  sleep($between_sleep)
  return page
end

# conect to link and download picture
def get_pic(link)
  tries ||= $nb_tries
  begin
    page = open(link, "User-Agent" => "Ruby/#{RUBY_VERSION}", "From" => "mat1994@free.fr")
  rescue => error
    if tries > 0
	tries -= 1
	sleep($failure_sleep)
	retry
    else
      puts 'could nor get picture ' + link + ' after ' + $nb_tries.to_s + ' tries'
      puts error.message
      return nil
    end
  end
  sleep($between_sleep)
  return page
end

# determines if directory exists
def dir_create(directory)
  if Dir.exists?(directory) == true
    puts "folder " + directory + " exists"
  else
    puts directory + " does not exist, creating it"
    Dir.mkdir(directory)
  end
end

# get every file name
def list_dir(work_dir)
  puts "listing directory " + work_dir
  Dir.foreach(Dir.home + "/Documents/web_tests/.") do |file|
    puts file
  end
end

# get file name
def file_name(dir, chap_value, page_nb)
  chap_str = chap_value.to_s
  val = chap_str.index('.')
  if (val != nil)
    chap_str[val] = ''
  else
    chap_str += '0'
  end
  chap_buffer = ((chap_value > 1000) ? "0" : ((chap_value > 100) ? "00" : ((chap_value > 10) ? "000" : "0000")))
  page_buffer = ((page_nb > 1000) ? "0" : ((page_nb > 100) ? "00" : ((page_nb > 10) ? "000" : "0000")))
  name_buffer = dir + "manga_c" + chap_buffer + chap_str + "_p" + page_buffer + page_nb.to_s
  return name_buffer
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
