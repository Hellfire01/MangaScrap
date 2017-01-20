$copied_js_css = false

class HTML
  # adds variables to @traces in order to sort / check
  def add_data_to_traces
    @traces.each do |chap|
      filename = html_chapter_filename(chap[3], chap[2])
      chap << "<a href=\"#####html_path#####" + filename + "\">#####elem#####</a>"
      chap << Dir.glob(file_name(@dir + @path_pictures, chap[2], chap[3], -1, true)).size
      chap << '.' + filename
    end
  end

  # gets all the pictures for each chapter
  def get_pictures_of_chapter(chapter)
    ret = []
    i = 1
    Dir.glob(file_name(@dir + @path_pictures, chapter[2], chapter[3], -1, true)).each do |file|
      file_relative_pos = file_name('../../mangas/' + @manga_data[1] + '/', chapter[2], chapter[3], i) + '.jpg'
      ret << "<p class=\"small-text\">#{i}</p>"
      ret << "<div class=\"frame\">\n"
      ret << "    <span class=\"hellper\"></span><img src=\"#{file_relative_pos}\">\n"
      ret << "</div>\n"
      i += 1
    end
    ret.join
  end

  # generates the html for 1 chapter
  def html_chapter(arr)
    template = File.open(Dir.home + '/.MangaScrap/templates/chapter_template.html').read
    template = template.gsub('#####index#####', '../' + @manga_data[1] + '.html')
    template = template.gsub('#####name#####', @manga_name)
    if arr[0] != nil
      template = template.gsub('#####next#####', arr[0][4]).gsub('#####html_path#####', '.').gsub('#####elem#####', 'next')
      template = template.gsub('#####next_url#####', arr[0][6])
    else
      template = template.gsub('#####next#####', '')
      template = template.gsub('#####next_url#####', '')
    end
    if arr[2] != nil
      template = template.gsub('#####prev#####', arr[2][4]).gsub('#####html_path#####', '.').gsub('#####elem#####', 'prev')
      template = template.gsub('#####prev_url#####', arr[2][6])
    else
      template = template.gsub('#####prev#####', '')
      template = template.gsub('#####prev_url#####', '')
    end
    chap_data = 'Chapter ' + ((arr[1][3] % 1 == 0) ? arr[1][3].to_i : arr[1][3]).to_s + ' ' + volume_int_to_string(arr[1][2], true)
    template = template.gsub('#####chapter_data#####', chap_data)
    template = template.gsub('#####pictures#####', get_pictures_of_chapter(arr[1])).gsub('#', '%23')
    template = template.gsub('#', '%23')
    File.open(@dir + @path_html + html_chapter_filename(arr[1][3], arr[1][2]), 'w') {|f| f.write(template) }
  end

  # generates html for all the chapters and links them ( prev and next buttons )
  def html_generate_chapters(manga_name)
    puts 'updating html chapters of ' + manga_name
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
      puts 'warning : no chapters in database, could not generate chapters'.yellow
    end
  end

  # converts the array of traces to an array of html code - the chapter index -
  # used by the chapter index of each manga
  def chapter_list_to_a_list(template)
    ret = ''
    buff = ''
    biggest = @traces.map { |a| [a[2], 0].max }.max
    @traces = @traces.sort_by { |a| [(a[2] < 0) ? (biggest + a[2] * -1) * -1 : a[2] * -1, -a[3]] }
    @traces.each do |chapter|
      ret += "<li>\n"
      chapter_buff = (chapter[3] % 1 == 0) ? chapter[3].to_i.to_s : chapter[3].to_s
      volume_buff = volume_int_to_string(chapter[2], true)
      buff = chapter[4].gsub('#####html_path#####', @manga_data[1]).gsub('#####elem#####', volume_buff + ' Chapter ' + chapter_buff).gsub('#', '%23')
      ret += buff
      ret += "</li>\n"
    end
    template = template.gsub('#####list#####', ret)
    template.gsub('#####first#####', buff)
  end

  # generates the chapter index, includes description, cover, names of artist and author, ...
  def generate_chapter_index(manga_name, index = true)
    if @params[8] == 'true' || @force_html == true
      puts 'updating chapter index of ' + manga_name
      @manga_init = true
      @manga_data = @db.get_manga(manga_name)
      @dir = @params[1] + @manga_data[4].split('/')[2].split('.')[0]
      @path_to_cover = '/mangas/' + @manga_data[1] + '.jpg'
      @path_pictures = '/mangas/' + @manga_data[1] + '/'
      @path_html = '/html/' + @manga_data[1]
      @manga_name = @manga_data[11]
      @traces = @db.get_trace(@manga_data[1])
      add_data_to_traces
      dir_create(@dir + @path_html)
      template = File.open(Dir.home + '/.MangaScrap/templates/chapter_index_template.html')
      template = template.read
      template = template.gsub('#####name#####', @manga_name)
      template = template.gsub('#####description#####', @manga_data[2].gsub("\n", '<br />'))
      template = template.gsub('#####site#####', html_a_buffer(@manga_data[4]))
      template = template.gsub('#####author#####', html_a_buffer(@manga_data[5]))
      template = template.gsub('#####artist#####', html_a_buffer(@manga_data[6]))
      template = template.gsub('#####type#####', html_a_buffer(@manga_data[7]))
      template = template.gsub('#####status#####', html_a_buffer(@manga_data[8]))
      template = template.gsub('#####genres#####', html_a_buffer(@manga_data[9]))
      template = template.gsub('#####date#####', html_a_buffer(@manga_data[10].to_s))
      template = template.gsub('#####alternative_names#####', @manga_data[12].split('; ').join('<br />'))
      template = template.gsub('#####cover#####', '..' + @path_to_cover)
      template = template.gsub('#####index_path#####', '../index.html')
      template = template.gsub('#####rank#####', @manga_data[13].to_s)
      template = template.gsub('#####rating#####', @manga_data[14].to_s + ' / ' + @manga_data[15].to_s)
      template = chapter_list_to_a_list(template).gsub('#', '%23')
      File.open(@dir + @path_html + '.html', 'w') {|f| f.write(template)}
      html_generate_chapters(manga_name) if index
    end
  end

  # manages the js of the index
  def index_js_data
    ret = "var data = [\n"
    mangas = @db.get_manga_list(true)
    mangas.each do |manga|
      ret += "  ['" + manga[11].gsub('; ', '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga[12].gsub('; ', '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga[2].gsub("\r", '<br />').gsub("\n", '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga[5] + "', '"
      ret += manga[6] + "', '"
      ret += manga[8] + "', '"
      ret += manga[9] + "', "
      ret += manga[10].to_s + ", '"
      ret += manga[7] + "', "
      ret += manga[13].to_s + ', '
      ret += (manga[14] * 100 / manga[15]).round(2).to_s + "],\n"
    end
    ret += '];'
    ret
  end

  # generates the links for each manga ( cover + name ), used for the manga index
  def html_get_data
    mangas = @db.get_manga_list
    ret = []
    i = 0
    mangas.sort.each do |manga|
      ret << "  <div class='manga'>"
      ret << "    <a onmouseover=\"displayData(#{i})\" onmouseout=\"clearData()\" href=\"" + './html/' + manga[0] + '.html' + '">'
      source_buffer = '      <img src="./mangas/' + manga[0] + '.jpg' + '">'
      if @params[9] == 'false'
        manga_genres = @db.get_manga(manga[0])[9].split(', ')
        if (@params[10].split(', ') & manga_genres).empty?
          ret << source_buffer
        else
          # warning : sites must be managed
          ret << '      <img src="' + Dir.home + '/.MangaScrap/pictures/logos/mangafox.png">'
        end
      else
        ret << source_buffer
      end
      ret << '      <p>' + description_manipulation(manga[0].gsub('_', ' '), 25, 3).gsub('\n', '<br />') + '</p>'
      ret << '    </a>'
      ret << '  </div>'
      i += 1
    end
  return ret.join("\n")
  end

  # generates the manga index ( the page containing the links to all mangas )
  def generate_index
    if @params[8] == 'true' || @force_html == true
      puts 'updating html of manga index'
      # todo : manage sites
      template = File.open(Dir.home + '/.MangaScrap/templates/manga_index_template.html').read
      template = template.gsub('#####list#####', html_get_data)
      File.open(@dir + '/index.html', 'w') {|f| f.write(template)}
      js = File.open(Dir.home + '/.MangaScrap/templates/manga_index_template.js').read
      js = js.gsub('#####tab#####', index_js_data)
      File.open(@dir + '/html/js/manga_index.js', 'w') {|f| f.write(js)}
    end
  end

  # the copy of the css and JS is only done one per execution of MangaScrap
  def css_and_js_init
    unless $copied_js_css
      dir_create(@params[1] + 'mangafox/html/css')
      dir_create(@params[1] + 'mangafox/html/js')
      # manga index
      template = File.open(Dir.home + '/.MangaScrap/templates/manga_index_template.css').read
      File.open(@params[1] + 'mangafox/html/css/manga_index.css', 'w') {|f| f.write(template) }
      # chapter index
      template = File.open(Dir.home + '/.MangaScrap/templates/chapter_index_template.css').read
      File.open(@params[1] + 'mangafox/html/css/chapter_index.css', 'w') {|f| f.write(template) }
      # chapter
      template = File.open(Dir.home + '/.MangaScrap/templates/chapter_template.css').read
      File.open(@params[1] + 'mangafox/html/css/chapter.css', 'w') {|f| f.write(template) }
      # todo : this file may need to be moved5780x1080
      template = File.open(Dir.home + '/.MangaScrap/templates/chapter_template.js').read
      File.open(@params[1] + 'mangafox/html/js/chapter.js', 'w') {|f| f.write(template) }
      $copied_js_css = true
    end
  end

  # the constructor copies all the css and places them in the html dir
  def initialize(db, force_html = false)
    @force_html = force_html
    @params = Params.instance.get_params
    @dir = @params[1] + 'mangafox/'
    @nsfw_genres = @params[10].split(', ')
    @manga_init = false
    @db = db
    css_and_js_init
  end
end