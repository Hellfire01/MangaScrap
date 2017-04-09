# used for the description.txt file of every manga
def data_conc(manga_name, description, site, link, author, artist, type, status, genres, release, html_name, alternative_names)
  ret =  'name         = ' + manga_name + '\n'
  ret += 'html name    = ' + html_name + '\n'
  ret += 'other names  = ' + alternative_names + '\n'
  ret += 'author       = ' + author + '\n'
  ret += 'artist       = ' + artist + '\n'
  ret += 'release year = ' + release.to_s + '\n'
  ret += 'type         = ' + type + '\n'
  ret += 'status       = ' + status + '\n'
  ret += 'genres       = ' + genres + '\n'
  ret += '\n'
  ret += 'site = ' + site + '\n'
  ret += 'link = ' + link + '\n'
  ret += '\n'
  ret += 'description :\n'
  ret += '\n'
  ret += description
  ret += '\n'
  ret
end

# open -f option file and return array
def get_mangas
  ret = Array.new
  if ARGV[1] == '-f'
    line_num = 0
    begin
      text = File.open(ARGV[2]).read
    rescue => e
      puts e.message
      exit 5
    end
    text.gsub!(/\r\n?/, '\n')
    text.each_line do |line|
      if line == nil || line.size <= 1 || line[0] == '#' || line[0] == '\n'
        next
      end
      elems = line.split(' ')
      if elems.size > 2
        puts "there is more than one space on line #{line_num} this should not be possible, ./MangaScrap -h for help"
        exit 5
      end
      if elems.size == 1
        elems << 'http://mangafox.me/'
      end
      ret << elems
      line_num += 1
    end
  else
    return nil
  end
  ARGV.delete_at(2)
  ARGV.delete_at(1)
  ret
end

# takes the volume value to return it's string value
def MF_volume_string(value)
  volume_string = ''
  case value
  when (value == -2)
    volume_string = ' of volume TBD'
  when (value == -3)
    volume_string = ' of volume NA'
  when (value == -4)
    volume_string = ' of volume ANT'
  when (value >= 0)
    volume_string = " of volume #{value}"
    if value % 1 == 0
      volume_string += ' '
    end
  else
      # volume string remains empty for return
  end
  volume_string
end

# transforms the raw text into a more readable format
def description_manipulation(description, line_size = 120, min_nb_lines = 0)
  description.delete!('\C-M')
  description.tr('\t', '')
  description = description.squeeze(' ')
  lines = 0
  ret = ''
  description.each_line do |line|
    lock = true
    tmp_line = ''
    count = 0
    line.split(' ').each do |word|
      count += word.length
      if count > line_size
        tmp_line += '\n'
        count = 0
        lines += 1
      end
      if lock
        lock = false
      elsif count != 0
        tmp_line += ' '
        count += 1
      end
      tmp_line += word
    end
    ret += tmp_line.strip + '\n'
  end
  while lines < min_nb_lines
    ret += '\n'
    lines += 1
  end
  ret
end

# used to get the volume, chapter and page of a link as an array
def data_extractor_MF(link)
  if link[link.size - 1] == '/'
    page = 1
  end
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
