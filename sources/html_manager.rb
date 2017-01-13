def html_manager(db)
  html = HTML.new(db)
  case ARGV.size
  when 1
    # index generation at end
  when 2
    if db.manga_in_data?(ARGV[1])
      html.generate_chapter_index(ARGV[1], true)
    else
      puts 'could not find ' + ARGV[1] + ' in database'
      exit 5
    end
  when 3
    ret = get_mangas
    if ret != nil
      ret.each do |name|
        html.generate_chapter_index(name[0], true)
      end
    end
  else
    puts 'bad amount of arguments, expecting a manga name or a manga file'
    exit 5
  end
  html.generate_index
end
