# used for the description.txt file of every manga
def data_conc(manga_name, description, site, link, author, artist, type, status, genres, release)
  ret =  "name         = " + manga_name + "\n"
  ret += "author       = " + author + "\n"
  ret += "artist       = " + artist + "\n"
  ret += "release year = " + release.to_s + "\n"
  ret += "type         = " + type + "\n"
  ret += "status       = " + status + "\n"
  ret += "genres       = " + genres + "\n"
  ret += "\n"
  ret += "site = " + site + "\n"
  ret += "link = " + link + "\n"
  ret += "\n"
  ret += "description :\n"
  ret += "\n"
  ret += description
  ret += "\n"
  return ret
end

# determines if directory exists
def dir_create(directory)
  if directory[0, 1] == "~"
    directory["~"] = Dir.home
  end
  if Dir.exist?(directory) == false
    puts directory + " does not exist, creating it"
    list = directory.split('/')
    build = "/"
    list = list.reject {|elem| elem.empty?}
    list.each do |elem|
      build += elem + '/'
      if Dir.exist?(build) == false
        Dir.mkdir(build)
      end
    end
  end
end

# open -f option file and return array
def get_mangas()
  ret = Array.new
  if ARGV[1] == "-f"
    line_num = 0
    begin
      text = File.open(ARGV[2]).read
    rescue => e
      puts e.message
      exit 5
    end
    text.gsub!(/\r\n?/, "\n")
    text.each_line do |line|
      if (line == nil || line.size <= 1 || line[0] == '#' || line[0] == '\n')
        next
      end
      elems = line.split(" ")
      if (elems.size > 2)
        puts "there is more than one space on line #{line_num} this should not be possible, ./MangaScrap -h for help"
        exit 5
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

# function used to get the string equivalent of the volume value
def volume_int_to_string(vol_value)
  vol_buffer = ""
  if vol_value == -1
    vol_buffer = "####"
  elsif vol_value == -2
    vol_buffer = "_TBD"
  elsif vol_value == -3
    vol_buffer = "__NA"
  elsif vol_value == -4
    vol_buffer = "_ANT"
  else
    vol_buffer = vol_value.to_s
  end
  return vol_buffer
end

# get file name
def file_name(dir, vol_value, chap_value, page_value, correction = false)
  chap_str = chap_value.to_s
  val = chap_str.index('.')
  if (val != nil)
    chap_str[val] = ''
  else
    chap_str += '0'
  end
  if vol_value != -42
    if vol_value < 0
      vol_buffer = volume_int_to_string(vol_value)
    else
      vol_buffer = ((vol_value >= 1000) ? "" : ((vol_value >= 100) ? "0" : ((vol_value >= 10) ? "00" : "000")))
      vol_buffer += vol_value.to_s
    end
  end
  chap_buffer = ((chap_value >= 1000) ? "" : ((chap_value >= 100) ? "0" : ((chap_value >= 10) ? "00" : "000")))
  if correction == false
    page_buffer = ((page_value >= 1000) ? "" : ((page_value >= 100) ? "0" : ((page_value >= 10) ? "00" : "000")))
    name_buffer = dir + "manga_v" + vol_buffer + "_c" + chap_buffer + chap_str + "_p" + page_buffer + page_value.to_s
  else
    name_buffer = dir + "manga_v" + vol_buffer + "_c" + chap_buffer + chap_str + "_p*"
  end
  return name_buffer
end

# used to display the progression of the downloads
def chapter_progression(i)
  if i > 1
    if i % 50 == 0
      printf ';'
    elsif i % 10 == 0
      printf ','
    else
      printf '.'
    end
  else
    printf '.'
  end
  STDOUT.flush
end

# transforms the raw text into a more lisible format
def description_manipulation(description)
  ret = ""
  description.delete!("\C-M")
  description.tr("\t", '')
  description = description.squeeze(" ")
  description.each_line do |line|
    lock = true
    tmp_line = ""
    count = 0
    line.split(" ").each do |word|
      count += word.length
      if count > 120
        tmp_line += "\n"
        count = 0
      end
      if lock == true
        lock = false
      elsif count != 0
        tmp_line += " "
        count += 1
      end
      tmp_line += word
    end
    ret += tmp_line.strip() + "\n"
  end
  return ret
end

# used to write the downloaded picture
def write_pic(pic_buffer, data, dir)
  dir_create(dir)  
  name_buffer = file_name(@dir, data[0], data[1], data[2])
  if pic_buffer != nil
    File.open(name_buffer + ".jpg", 'wb') do |pic|
      pic << pic_buffer.read
    end
    if (File.exist?(name_buffer + ".txt") == true)
      File.delete(name_buffer + ".txt")
    end
  else
    File.open(name_buffer + ".txt", 'w') do |pic|
      pic << "could not be downloaded"
    end
    puts "Error : no picture to save"
    return false
  end
  return true
end

# used to get only the chapter and volumes values from db
def db_to_trace(db, name)
  trace = db.get_trace(name)
  trace = trace.each {|elem| elem.shift} # delete id of each chapter
  trace = trace.each {|elem| elem.shift} # delete if of manga
  return trace
end
