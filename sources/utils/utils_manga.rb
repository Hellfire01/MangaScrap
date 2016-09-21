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
def volume_int_to_string(vol_value, html = false)
  vol_buffer = ""
  if vol_value == -1
    vol_buffer = (html == false) ? "####" : ""
  elsif vol_value == -2
    vol_buffer = (html == false) ? "_TBD" : "Volume TBD"
  elsif vol_value == -3
    vol_buffer = (html == false) ? "__NA" : "Volume NA"
  elsif vol_value == -4
    vol_buffer = (html == false) ? "_ANT" : "Volume ANT"
  else
    if html == false
      vol_buffer = vol_value.to_s
    else
      buffer = ((vol_value >= 1000) ? "" : ((vol_value >= 100) ? "&nbsp;" : ((vol_value >= 10) ? "&nbsp;&nbsp;" : "&nbsp;&nbsp;&nbsp;")))
      vol_buffer = "Volume " + vol_value.to_s + buffer
    end
  end
  return vol_buffer
end

# utilisé pour obtenir la valeur du volume en string
def vol_buffer_string(vol_value)
  if vol_value != -42
    if vol_value < 0
      vol_buffer = volume_int_to_string(vol_value)
    else
      vol_buffer = ((vol_value >= 1000) ? "" : ((vol_value >= 100) ? "0" : ((vol_value >= 10) ? "00" : "000")))
      vol_buffer += vol_value.to_s
    end
  end
  return vol_buffer
end

# utilisé pour obtenir la valeur du chapitre en string
def chap_buffer_string(chap_value)
  chap_str = chap_value.to_s
  val = chap_str.index('.')
  if (val != nil)
    chap_str[val] = ''
  else
    chap_str += '0'
  end
  chap_str = ((chap_value >= 1000) ? "" : ((chap_value >= 100) ? "0" : ((chap_value >= 10) ? "00" : "000"))) + chap_str
  return chap_str
end

# get file name
def file_name(dir, vol_value, chap_value, page_value, chapter = false)
  vol_buffer = vol_buffer_string(vol_value)
  chap_buffer = chap_buffer_string(chap_value)
  if chapter == false
    page_buffer = ((page_value >= 1000) ? "" : ((page_value >= 100) ? "0" : ((page_value >= 10) ? "00" : "000")))
    name_buffer = dir + "manga_v" + vol_buffer + "_c" + chap_buffer + "_p" + page_buffer + page_value.to_s
  else
    name_buffer = dir + "manga_v" + vol_buffer + "_c" + chap_buffer + "_p*"
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

# transforms the raw text into a more readable format
def description_manipulation(description, line_size = 120, min_nb_lines = 0)
  description.delete!("\C-M")
  description.tr("\t", '')
  description = description.squeeze(" ")
  lines = 0
  ret = ""
  description.each_line do |line|
    lock = true
    tmp_line = ""
    count = 0
    line.split(" ").each do |word|
      count += word.length
      if count > line_size
        tmp_line += "\n"
        count = 0
        lines += 1
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
  while lines < min_nb_lines
    ret += "\n"
    lines += 1
  end
  return ret
end
