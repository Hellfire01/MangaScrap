def del(path, extention)
  delete_folder = false
  Dir.glob(path + "/*").sort.each do |file|
    delete_folder = true
    puts "deleting file : " + file
    File.delete(file)
  end
  if delete_folder == true
    Dir.delete(path)
  end
  if File.exist?(path + extention)
    puts "deleting file : " + path + extention
    File.delete(path + extention)
  end
end

def erase_files(db, name)
  data = db.get_manga(name)
  params = Params.new().get_params()
  if data[3] == "http://mangafox.me/"
    path_site = "mangafox/"
  else
    puts "unmanaged site for deletion : " + data[3]
    puts "please report this error"
    exit 4
  end
  del(params[1] + path_site + "html/" + name, ".html")
  del(params[1] + path_site + "mangas/" + name, ".jpg")
end

def confirm_delete (db, name, dfiles)
    puts "going to delete #{name} from database " + ((dfiles == true) ? "and delete files" : "only")
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ""
    if (ret == "YES")
      if (dfiles == true)
        puts "deleting files"
        erase_files(db, name)
      end
      db.delete_manga(name)
      puts "deleted #{name} from database"
      return true
    else
      puts "did not delete #{name}"
      return false
    end
end

def delete(db, dfiles = false)
  html = HTML.new(db)
  if (ARGV.size < 2)
    puts "need a manga's name to delete"
  elsif (ARGV.size == 2)
    if confirm_delete(db, ARGV[1], dfiles) == true
      html.generate_index()
    end
  else
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        if confirm_delete(db, name, dfiles) == true
          html.generate_index()
        end
      end
    else
      puts "error while trying to get content of file ( -f option )"
      exit 5
    end
  end
end
