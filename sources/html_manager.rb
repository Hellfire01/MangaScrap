def html_manager(db)
  html = HTML.new(db)
  html.generate_index()
  case ARGV.size
  when 2
    if (db.manga_in_data?(ARGV[1]) == true)
      html.generate_chapter_index(ARGV[1], true)
    else
      puts 'could not find ' + ARGV[1] + ' in database'
      exit 5
    end
  when 3
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        html.generate_chapter_index(name[0], true)
      end
    else
      puts "error while trying to get content of file ( -f option )"
      exit 5
    end
  else
    puts "bad number of arguments for html, --help for help"
    exit 5
  end
end
