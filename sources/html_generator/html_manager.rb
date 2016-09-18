# will have to be modified to be called once for each site
def write_css_files(params)
  dir_create(params[1] + "mangafox/html/css")
  template_css = File.open(Dir.home + "/.MangaScrap/chapter_index_template.css").read
  File.open(params[1] + "mangafox/html/css/chapter_index.css", "w") {|f| f.write(template_css) }
  template_css = File.open(Dir.home + "/.MangaScrap/chapter_template.css").read
  File.open(params[1] + "mangafox/html/css/chapter.css", "w") {|f| f.write(template_css) }
  template_css = File.open(Dir.home + "/.MangaScrap/manga_index_template.css").read
  File.open(params[1] + "mangafox/html/css/manga_index.css", "w") {|f| f.write(template_css) }
end

def html_manager(db)
  params = Params.new().get_params()
  write_css_files(params)
  html_manga_index(db, params, false)
  case ARGV.size
  when 2
    if (db.manga_in_data?(ARGV[1]) == true)
      html_chapter_index(db, db.get_manga(ARGV[1]), params)
    else
      puts 'could not find ' + ARGV[1] + ' in database'
      exit 5
    end
  when 3
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        html_chapter_index(db, db.get_manga(name[0]), params)
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
