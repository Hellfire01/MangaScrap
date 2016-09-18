# determines if directory exists and creates it if not
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
  else
    return false
  end
end
