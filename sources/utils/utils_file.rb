# determines if directory exists and creates it if not
def dir_create(directory)
  if directory[0, 1] == '~'
    directory['~'] = Dir.home
  end
  unless Dir.exist?(directory)
    puts directory + ' does not exist, creating it'
    list = directory.split('/')
    if list[0].empty?
      build = '/'
    else
      build = ""
    end
    list = list.reject {|elem| elem.empty?}
    list.each do |elem|
      build += elem + '/'
      unless Dir.exist?(build)
        Dir.mkdir(build)
      end
    end
  end
end

# used to get the chapter value as a string
def chap_buffer_string(chap_value)
  chap_str = chap_value.to_s
  val = chap_str.index('.')
  if val != nil
    chap_str[val] = ''
  else
    chap_str += '0'
  end
  ((chap_value >= 1000) ? '' : ((chap_value >= 100) ? '0' : ((chap_value >= 10) ? '00' : '000'))) + chap_str
end

# function used to get the string equivalent of the volume value
def volume_int_to_string(vol_value, html = false)
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

# for mangafox only => transforms the string value of the volumes to an int
def mangafox_volume_string_to_int(string)
  case string
    when (string == 'TBD')
      volume = -2
    when (string == 'NA')
      volume = -3
    when (string == 'ANT')
      volume = -4
    else
      volume = string.to_i
  end
  volume
end

# used to get the volume value as a string
def vol_buffer_string(vol_value)
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

# generates a filename, the chapter value is used to determines if it returns a chapter ( for Dir.glob ) or a specific page
def file_name(dir, vol_value, chap_value, page_value, chapter = false)
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
def write_pic(pic_buffer, data, dir)
  dir_create(dir)
  name_buffer = file_name(dir, data[0], data[1], data[2])
  if pic_buffer != nil
    File.open(name_buffer + '.jpg', 'wb') do |pic|
      pic << pic_buffer.read
    end
    if File.exist?(name_buffer + '.txt')
      File.delete(name_buffer + '.txt')
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

#used to copy files ( binaries and text )
def copy_file(file, dest)
  file = File.open(file)
  if file != nil
    copy = File.new(dest, 'wb')
    until file.eof?
      copy.write(file.read(1024))
    end
    file.close
    copy.close
    return true
  end
  false
end

def delete_files(path, extension)
  Dir.glob(path + '/*').sort.each do |file|
    puts 'deleting file : ' + file
    File.delete(file)
  end
  Dir.delete(path)
  if File.exist?(path + extension)
    puts 'deleting file : ' + path + extension
    File.delete(path + extension)
  end
end
