class HTML
  # adds collums to @traces in order to sort / check
  def add_data_to_traces()
    @traces.each do |chap|
      chap << "<a href=\"" + @path_html + html_chapter_filename(chap) + "\">#####elem#####</a>"
      chap << Dir.glob(file_name(@dir + @path_pictures, chap[2], chap[3], -1, true)).size
    end
  end

  def get_html_manga_name(name)
    ret = name.gsub("_", " ")
    ret = ret.slice(0,1).capitalize + ret.slice(1..-1)
    return ret
  end

  # converts the array of traces to an array of html code - the chapter index -
  def chapter_list_to_a_list(template)
    ret = ""
    buff = ""
    biggest = @traces.map { |a| [a[2], 0].max }.max
    @traces = @traces.sort_by { |a| [(a[2] < 0) ? (biggest + a[2] * -1) * -1 : a[2] * -1, -a[3]] }
    @traces.each do |chapter|
      ret += "<li>\n"
      chapter_buff = (chapter[3] % 1 == 0) ? chapter[3].to_i.to_s : chapter[3].to_s
      volume_buff = volume_int_to_string(chapter[2], true)
      buff = '  <a href="' + html_chapter_filename(chapter, true) + '">' + volume_buff + " Chapter " + chapter_buff + "</a>\n"
      ret += buff
      ret += "</li>\n"
    end
    template = template.gsub("#####list#####", ret)
    template = template.gsub("#####first#####", buff)
    return template
  end

  # generates the links for each manga ( cover + name )
  def html_get_data()
    mangas = @db.get_manga_list()
    ret = []
    mangas.sort.each do |manga|
      ret << "  <div class=\"manga\">"
      ret << "    <a href=\"" + "./html/" + manga[0] + ".html" + "\">"
      source_buffer = "      <img src=\"./mangas/" + manga[0] + ".jpg" + "\">"
      if @params[9] == "false"
        manga_genres = @db.get_manga(manga[0])[9].split(", ")
        if ((@params[10].split(", ") & manga_genres).empty?)
          ret << source_buffer
        else
          # warning : sites must be managed
          ret << "      <img src=\"" + Dir.home + "/.MangaScrap/pictures/logos/mangafox.png" + "\">"
        end
      else
        ret << source_buffer
      end
      ret << "      <p>" + description_manipulation(manga[0].gsub("_", " "), 25, 3).gsub("\n", "<br />") + "</p>"
      ret << "    </a>"
      ret << "  </div>"
    end
    return ret.join("\n")
  end

  # gets all the pictures for each chapter
  def get_pictures_of_chapter(chapter)
    ret = []
    i = 1
    Dir.glob(file_name(@dir + @path_pictures, chapter[2], chapter[3], -1, true)).each do |file|
      file_relative_pos = file_name("../../mangas/" + @manga_data[1] + "/", chapter[2], chapter[3], i) + ".jpg"
      ret << "<div class=\"frame\">\n"
      ret << "    <span class=\"hellper\"></span><img src=\"#{file_relative_pos}\">\n"
      ret << "\<div>\n"
      i += 1
    end
    return ret.join
  end

  # generates the html for 1 chapter
  def html_chapter(arr)
    template = File.open(Dir.home + "/.MangaScrap/templates/chapter_template.html").read
    template = template.gsub("#####index#####", "../" + @manga_data[1] + ".html")
    template = template.gsub("#####name#####", @manganame)
    template = template.gsub("#####prev#####", (arr[2] != nil) ? arr[2][4].gsub("#####elem#####", "prev") : "")
    template = template.gsub("#####next#####", (arr[0] != nil) ? arr[0][4].gsub("#####elem#####", "next") : "")
    template = template.gsub("#####pictures#####", get_pictures_of_chapter(arr[1])).gsub("#", "%23")
    File.open(@dir + @path_html + html_chapter_filename(arr[1]), "w") {|f| f.write(template) }
  end

  # generates html for all the chapters and links them ( prev and next buttons )
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
        traces.each_cons(3) do |nxt, current, prev|
          arr = [nxt, current, prev]
          html_chapter(arr)
        end
        arr = [traces[traces.size - 2], traces[traces.size - 1], nil]
        html_chapter(arr)
      end
    else
      puts "warning : no chapters in trace database, could not generate chapters"
    end
  end

  # generates the chapter index, includs description, cover, names of artist and author, ...
  def generate_chapter_index(manganame, index = true)
    if @params[8] == "true" || @force_html == true
      puts "updating chapter index of " + manganame
      @mangaInit = true
      @manga_data = @db.get_manga(manganame)
      @dir = @params[1] + @manga_data[4].split("/")[2].split(".")[0];
      @path_to_cover = "/mangas/" + @manga_data[1] + ".jpg"
      @path_pictures = "/mangas/" + @manga_data[1] + "/"
      @path_html = "/html/" + @manga_data[1]
      @manganame = get_html_manga_name(@manga_data[1])
      @traces = @db.get_trace(@manga_data[1])
      add_data_to_traces()
      dir_create(@dir + @path_html)
      template = File.open(Dir.home + "/.MangaScrap/templates/chapter_index_template.html")
      template = template.read
      template = template.gsub("#####name#####", manganame)
      template = template.gsub("#####description#####", @manga_data[2].gsub("\n", "<br />"))
      template = template.gsub("#####site#####", @manga_data[4])
      template = template.gsub("#####author#####", html_a_buffer(@manga_data[5]))
      template = template.gsub("#####artist#####", html_a_buffer(@manga_data[6]))
      template = template.gsub("#####status#####", html_a_buffer(@manga_data[8]))
      template = template.gsub("#####genres#####", html_a_buffer(@manga_data[9]))
      template = template.gsub("#####date#####", @manga_data[10].to_s)
      template = template.gsub("#####cover#####", ".." + @path_to_cover)
      template = template.gsub("#####index_path#####", "../index.html")
      template = chapter_list_to_a_list(template).gsub("#", "%23")
      File.open(@dir + @path_html + ".html", "w") {|f| f.write(template)}
      html_generate_chapters(manganame) if index == true
    end
  end

  def generate_index()
    if @params[8] == "true" || @force_html == true
      puts "updating html of manga index"
      #manage sites
      @dir = @params[1] + "mangafox/"
      template = File.open(Dir.home + "/.MangaScrap/templates/manga_index_template.html").read
      template = template.gsub("#####list#####", html_get_data())
      File.open(@dir + "index.html", "w") {|f| f.write(template)}
    end
  end
  
  def initialize(db, force_html = false)
    @force_html = force_html
    @params = Params.instance().get_params()
    @nsfw_genres = @params[10].split(", ")
    dir_create(@params[1] + "mangafox/html/css")
    template_css = File.open(Dir.home + "/.MangaScrap/templates/chapter_index_template.css").read
    File.open(@params[1] + "mangafox/html/css/chapter_index.css", "w") {|f| f.write(template_css) }
    template_css = File.open(Dir.home + "/.MangaScrap/templates/chapter_template.css").read
    File.open(@params[1] + "mangafox/html/css/chapter.css", "w") {|f| f.write(template_css) }
    template_css = File.open(Dir.home + "/.MangaScrap/templates/manga_index_template.css").read
    File.open(@params[1] + "mangafox/html/css/manga_index.css", "w") {|f| f.write(template_css) }
    @mangaInit = false
    @db = db
  end
end