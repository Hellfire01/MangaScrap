class HTML
  def chapter_filename(chapter)
    filename = "v" + vol_buffer_string(chapter[2]) + "c" + chap_buffer_string(chapter[3]) + ".html"
    return @path_html + "/" + filename
  end

  def add_data_to_traces()
    @traces.each do |chap|
      chap << "<a href=\"" + chapter_filename(chap) + "\">#####elem#####</a>"
      chap << Dir.glob(file_name(@path_pictures, chap[2], chap[3], -1, true)).size
    end
  end

  def get_html_manga_name(name)
    ret = name.gsub("_", " ")
    ret = ret.slice(0,1).capitalize + ret.slice(1..-1)
    return ret
  end

  def chapter_list_to_a_list(template)
    ret = ""
    buff = ""
    biggest = @traces.map { |a| [a[2], 0].max }.max
    @traces = @traces.sort_by { |a| [(a[2] < 0) ? (biggest + a[2] * -1) * -1 : a[2] * -1, -a[3]] }
    @traces.each do |chapter|
      ret += "<li>\n"
      chapter_buff = (chapter[3] % 1 == 0) ? chapter[3].to_i.to_s : chapter[3].to_s
      volume_buff = volume_int_to_string(chapter[2], true)
      buff = '  <a href="' + chapter_filename(chapter) + '">' + volume_buff + " Chapter " + chapter_buff + "</a>\n"
      ret += buff
      ret += "</li>\n"
    end
    template = template.gsub("#####list#####", ret)
    template = template.gsub("#####first#####", buff)
    return template
  end

  def html_get_data()
    mangas = @db.get_manga_list()
    ret = []
    mangas.sort.each do |manga|
      ret << "  <div class=\"manga\">"
      ret << "    <a href=\"" + @dir + "html/" + manga[0] + ".html" + "\">"
      ret << "      <img src=\"" +  @dir + "mangas/" + manga[0] + ".jpg" + "\">"
      ret << "      <p>" + description_manipulation(manga[0].gsub("_", " "), 25, 3).gsub("\n", "<br />") + "</p>"
      ret << "    </a>"
      ret << "  </div>"
    end
    return ret.join("\n")
  end

  def get_pictures_of_chapter(chapter)
    ret = []
    Dir.glob(file_name(@path_pictures, chapter[2], chapter[3], -1, true)).sort.each do |file|
      ret << "<div class=\"frame\">\n"
      ret << "    <span class=\"hellper\"></span><img src=\"#{file}\">\n"
      ret << "\<div>\n"
    end
    return ret.join
  end

  def html_chapter(arr)
    template = File.open(Dir.home + "/.MangaScrap/chapter_template.html").read
    template = template.gsub("#####index#####", @path_html + ".html")
    template = template.gsub("#####name#####", @manganame)
    template = template.gsub("#####prev#####", (arr[0] != nil) ? arr[0][4].gsub("#####elem#####", "prev") : "")
    template = template.gsub("#####next#####", (arr[2] != nil) ? arr[2][4].gsub("#####elem#####", "next") : "")
    template = template.gsub("#####pictures#####", get_pictures_of_chapter(arr[1])).gsub("#", "%23")
    File.open(chapter_filename(arr[1]), "w") {|f| f.write(template) }
  end

  def html_generate_chapters(manganame)
    puts "updating html chapters of " + manganame
    traces = @traces.reject{|chapter| chapter[5] == 0}
    if traces.size > 0
      if traces.size == 1
        arr = [nil, traces[0], nil]
        html_chapter(arr)
      else
        arr = [nil, traces[0], traces[1]]
        html_chapter(arr)
        traces.each_cons(3) do |prev, current, nxt|
          arr = [prev, current, nxt]
          html_chapter(arr)
        end
        arr = [traces[traces.size - 2], traces[traces.size - 1], nil]
        html_chapter(arr)
      end
    else
      puts "warning : no chapters in trace database, could not generate chapters"
    end
  end

  def generate_chapter_index(manganame, index = true)
    puts "updating chapter index of " + manganame
    @mangaInit = true
    manga_data = @db.get_manga(manganame)
    @dir = @params[1] + manga_data[4].split("/")[2].split(".")[0];
    @path_to_cover = @dir + "/mangas/" + manga_data[1] + ".jpg"
    @path_pictures = @dir + "/mangas/" + manga_data[1] + "/"
    @path_html = @dir + "/html/" + manga_data[1]
    @manganame = get_html_manga_name(manga_data[1])
    @traces = @db.get_trace(manga_data[1])
    add_data_to_traces()
    dir_create(@path_html)
    template = File.open(Dir.home + "/.MangaScrap/chapter_index_template.html")
    template = template.read
    template = template.gsub("#####name#####", manganame)
    template = template.gsub("#####description#####", description_manipulation(manga_data[2], 100).gsub("\n", "<br />"))
    template = template.gsub("#####site#####", manga_data[4])
    template = template.gsub("#####author#####", html_a_buffer(manga_data[5]))
    template = template.gsub("#####artist#####", html_a_buffer(manga_data[6]))
    template = template.gsub("#####status#####", html_a_buffer(manga_data[8]))
    template = template.gsub("#####genres#####", html_a_buffer(manga_data[9]))
    template = template.gsub("#####date#####", manga_data[10].to_s)
    template = template.gsub("#####cover#####", @path_to_cover)
    template = chapter_list_to_a_list(template).gsub("#", "%23")
    File.open(@path_html + ".html", "w") {|f| f.write(template)}
    html_generate_chapters(manganame) if index == true
  end

  def generate_index()
    puts "updating html of manga index"
    @dir = @params[1] + "mangafox/"
    template = File.open(Dir.home + "/.MangaScrap/manga_index_template.html").read
    template = template.gsub("#####list#####", html_get_data())
    File.open(@dir + "index.html", "w") {|f| f.write(template)}
  end
  
  def initialize(db)
    @params = Params.new().get_params()
    dir_create(@params[1] + "mangafox/html/css")
    template_css = File.open(Dir.home + "/.MangaScrap/chapter_index_template.css").read
    File.open(@params[1] + "mangafox/html/css/chapter_index.css", "w") {|f| f.write(template_css) }
    template_css = File.open(Dir.home + "/.MangaScrap/chapter_template.css").read
    File.open(@params[1] + "mangafox/html/css/chapter.css", "w") {|f| f.write(template_css) }
    template_css = File.open(Dir.home + "/.MangaScrap/manga_index_template.css").read
    File.open(@params[1] + "mangafox/html/css/manga_index.css", "w") {|f| f.write(template_css) }
    @mangaInit = false
    @db = db
  end
end
