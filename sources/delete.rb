def del(path, extension)
  delete_folder = false
  Dir.glob(path + '/*').sort.each do |file|
    delete_folder = true
    puts 'deleting file : ' + file
    File.delete(file)
  end
  if delete_folder
    Dir.delete(path)
  end
  if File.exist?(path + extension)
    puts 'deleting file : ' + path + extension
    File.delete(path + extension)
  end
end

def erase_files(db, name)
  data = db.get_manga(name)
  params = Params.instance.get_params
  path_site = ''
  if data[3] == 'http://mangafox.me/'
    path_site = 'mangafox/'
  else
    puts 'unmanaged site for deletion : ' + data[3]
    puts 'please report this error'
    exit 4
  end
  del(params[1] + path_site + 'html/' + name, '.html')
  del(params[1] + path_site + 'mangas/' + name, '.jpg')
end

def confirm_delete (db, name, delete_files)
    puts "going to delete #{name} from database " + ((delete_files) ? 'and delete files' : 'only')
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ''
    if ret == 'YES'
      if delete_files
        puts 'deleting files'
        erase_files(db, name)
      end
      db.delete_manga(name)
      puts "deleted #{name} from database"
      return true
    end
    puts "did not delete #{name}"
    false
end

def delete(db, delete_files = false)
  html = HTML.new(db)
  if ARGV.size < 2
    puts "need a manga's name to delete"
  elsif ARGV.size == 2
    if confirm_delete(db, ARGV[1], delete_files)
      html.generate_index
    end
  else
    ret = get_mangas
    if ret != nil
      ret.each do |name|
        if confirm_delete(db, name, delete_files)
          html.generate_index
        end
      end
    else
      puts 'error while trying to get content of file ( -f option )'
      exit 5
    end
  end
end
