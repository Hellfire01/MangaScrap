module Utils_file
  # determines if directory exists and creates it if not
  def self.dir_create(directory)
    if directory[0, 1] == '~'
      directory['~'] = Dir.home
    end
    unless Dir.exist?(directory)
      puts directory + ' does not exist, creating it'
      list = directory.split('/')
      if list[0].empty?
        build = '/'
      else
        build = ''
      end
      list = list.reject {|elem| elem.empty?}
      list.each do |elem|
        build += elem + '/'
        unless Dir.exist?(build)
          begin
            Dir.mkdir(build)
          rescue Errno::EACCES => e
            Utils_errors::critical_error('Permission denied when trying to create dir "' + build.yellow + '"', e)
          end
        end
      end
    end
  end

  # used to get the chapter value as a string with an alignment buffer
  def self.chap_buffer_string(chap_value)
    chap_str = chap_value.to_s
    val = chap_str.index('.')
    if val != nil
      chap_str[val] = ''
    else
      chap_str += '0'
    end
    ((chap_value >= 1000) ? '' : ((chap_value >= 100) ? '0' : ((chap_value >= 10) ? '00' : '000'))) + chap_str
  end

  # used to get the volume value as a string with an alignment buffer
  def self.vol_buffer_string(vol_value)
    vol_buffer = ''
    if vol_value != -42
      if vol_value < 0
        vol_buffer = volume_int_to_string(vol_value)
      else
        vol_buffer = ((vol_value >= 1000) ? '' : ((vol_value >= 100) ? '0' : ((vol_value >= 10) ? '00' : '000')))
        vol_buffer += vol_value.to_s
      end
    end
    vol_buffer
  end

  # function used to 'translate' the volume value (int) from the database as a string
  def self.volume_int_to_string(vol_value, html = false)
    volume_buffer = ''
    case vol_value
    when -1
      volume_buffer = (!html) ? '####' : ''
    when -2
      volume_buffer = (!html) ? '_TBD' : 'Volume TBD'
    when -3
      volume_buffer = (!html) ? '__NA' : 'Volume NA'
    when -4
      volume_buffer = (!html) ? '_ANT' : 'Volume ANT'
    else
      if html
        buffer = ((vol_value >= 1000) ? '' : ((vol_value >= 100) ? '&nbsp;' : ((vol_value >= 10) ? '&nbsp;&nbsp;' : '&nbsp;&nbsp;&nbsp;')))
        volume_buffer = 'Volume ' + vol_value.to_s + buffer
      else
        volume_buffer = vol_value.to_s
      end
    end
    volume_buffer
  end

  # generates a filename, the chapter value is used to determines if it returns a chapter ( for Dir.glob ) or a specific page
  def self.file_name(dir, vol_value, chap_value, page_value, chapter = false)
    vol_buffer = vol_buffer_string(vol_value)
    chap_buffer = chap_buffer_string(chap_value)
    if chapter
      name_buffer = dir + 'manga_v' + vol_buffer + '_c' + chap_buffer + '_p*'
    else
      page_buffer = ((page_value >= 1000) ? '' : ((page_value >= 100) ? '0' : ((page_value >= 10) ? '00' : '000')))
      name_buffer = dir + 'manga_v' + vol_buffer + '_c' + chap_buffer + '_p' + page_buffer + page_value.to_s
    end
    name_buffer
  end

  # used to write the downloaded picture
  def self.write_pic(pic_buffer, data, dir)
    Utils_file::dir_create(dir)
    name_buffer = file_name(dir, data[0], data[1], data[2])
    if pic_buffer != nil
      begin
        File.open(name_buffer + '.jpg', 'wb') do |pic|
          pic << pic_buffer
        end
        if File.exist?(name_buffer + '.txt')
          File.delete(name_buffer + '.txt')
        end
      rescue Errno::EROFS => e
        Utils_errors::critical_error('could not write image', e)
      end
    else
      File.open(name_buffer + '.txt', 'w') do |pic|
        pic << 'could not be downloaded'
      end
      puts 'Error : no picture to save'
      return false
    end
    true
  end

  def self.delete_files(path, extension)
    begin
      Dir.glob(path + '/*').sort.each do |file|
        puts 'deleting file : ' + file
        File.delete(file)
      end
      Dir.delete(path)
      if File.exist?(path + extension)
        puts 'deleting file : ' + path + extension
        File.delete(path + extension)
      end
    rescue Errno::ENOENT => e
      return
    rescue => e
      Utils_errors::critical_error('exception while trying to delete file', e)
    end
  end

  # used for the description.txt file of every manga
  def self.data_concatenation(manga_data, description, author, artist, type, status, genres, release, html_name, alternative_names)
    ret =  'name         = ' + manga_data.name + "\n"
    ret += 'html name    = ' + html_name + "\n"
    ret += 'other names  = ' + alternative_names + "\n"
    ret += 'author       = ' + author + "\n"
    ret += 'artist       = ' + artist + "\n"
    ret += 'release year = ' + release.to_s + "\n"
    ret += 'type         = ' + type + "\n"
    ret += 'status       = ' + status + "\n"
    ret += 'genres       = ' + genres + "\n"
    ret += "\n"
    ret += 'site = ' + manga_data.site + "\n"
    ret += 'link = ' + manga_data.link + "\n"
    ret += "\n"
    ret += "description :\n"
    ret += "\n"
    ret += description
    ret += "\n"
    ret
  end

  # transforms the raw text into a more readable format
  def self.description_manipulation(description, line_size = 120, min_nb_lines = 0)
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
          tmp_line += "\n"
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
      ret += tmp_line.strip + "\n"
    end
    while lines < min_nb_lines
      ret += "\n"
      lines += 1
    end
    ret
  end
end
