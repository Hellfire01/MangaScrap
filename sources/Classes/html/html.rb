$copied_js_css = []

class HTML
  private
  # adds variables to @traces in order to sort / check
  def get_traces(manga_data)
    ret = []
    tmp = @db.get_trace(manga_data)
    tmp.each do |chap|
      filename = html_chapter_filename(chap[3], chap[2])
      href = "<a href=\"#####html_path#####" + filename + "\">#####elem#####</a>"
      nb_pages = Dir.glob(file_name(@dir + @path_pictures, chap[2], chap[3], -1, true)).size
      ret << Struct::HTML_data.new(chap[2], chap[3], chap[4], href, nb_pages, '.' + filename)
    end
    ret
  end

  # gets all the pictures for each chapter
  def get_pictures_of_chapter(chapter)
  ret = []
    i = 1
    Dir.glob(file_name(@dir + @path_pictures, chapter[:volume], chapter[:chapter], -1, true)).each do |file|
      file_relative_pos = file_name('../../mangas/' + @manga_data[1] + '/', chapter[:volume], chapter[:chapter], i) + '.jpg'
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
    template = @chapter_template
    template = template.gsub('#####index#####', '../' + @manga_data[1] + '.html')
    template = template.gsub('#####name#####', @manga_name)
    if arr[0] != nil
      template = template.gsub('#####next#####', arr[0][:href]).gsub('#####html_path#####', '.').gsub('#####elem#####', 'next')
      template = template.gsub('#####next_url#####', arr[0][:file_name])
    else
      template = template.gsub('#####next#####', '')
      template = template.gsub('#####next_url#####', '')
    end
    if arr[2] != nil
      template = template.gsub('#####prev#####', arr[2][:href]).gsub('#####html_path#####', '.').gsub('#####elem#####', 'prev')
      template = template.gsub('#####prev_url#####', arr[2][:file_name])
    else
      template = template.gsub('#####prev#####', '')
      template = template.gsub('#####prev_url#####', '')
    end
    chap_data = 'Chapter ' + ((arr[1][:chapter] % 1 == 0) ? arr[1][:chapter].to_i : arr[1][:chapter]).to_s + ' ' + volume_int_to_string(arr[1][:volume], true)
    max_chap_data = 'Chapter ' + ((@traces[0][:chapter] % 1 == 0) ? @traces[0][:chapter].to_i : @traces[0][:chapter]).to_s + ' ' + volume_int_to_string(@traces[0][:volume], true)
    template = template.gsub('#####chapter_data#####', chap_data + ' / ' + max_chap_data)
    template = template.gsub('#####pictures#####', get_pictures_of_chapter(arr[1]))
    template = template.gsub('#####manga_index#####', @dir + 'index.html')
    template = template.gsub('#', '%23')
    File.open(@path_html + html_chapter_filename(arr[1][:chapter], arr[1][:volume]), 'w') {|f| f.write(template) }
  end

  # generates html for all the chapters and links them ( prev and next buttons )
  def html_generate_chapters(manga_data)
    puts 'updating html chapters of ' + manga_data.name
    traces = @traces.reject{|chapter| chapter[:nb_pages] == 0}
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
    biggest = @traces.map { |a| [a[:volume], 0].max }.max
    @traces = @traces.sort_by { |a| [(a[:volume] < 0) ? (biggest + a[:volume] * -1) * -1 : a[:volume] * -1, -a[:chapter]] }
    @traces.each do |chapter|
      pp chapter
      exit 42
      ret += "<li>\n"
      chapter_buff = (chapter[:chapter] % 1 == 0) ? chapter[:chapter].to_i.to_s : chapter[:chapter].to_s
      volume_buff = volume_int_to_string(chapter[:volume], true)
        buff = chapter[:href].gsub('#####html_path#####', @manga_data[1]).gsub('#####elem#####', volume_buff + ' Chapter ' + chapter_buff).gsub('#', '%23')
      ret += buff
      ret += "</li>\n"
    end
    template = template.gsub('#####list#####', ret)
    template.gsub('#####first#####', buff)
  end

  # manages the js of the index
  def index_js_data(site)
    ret = "var data = [\n"
    mangas = @db.get_manga_list(site)
    mangas.sort{|a, b| a.link <=> b.link}.each do |manga|
      ret += "  ['" + manga.data[11].gsub('; ', '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga.data[12].gsub('; ', '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga.data[2].gsub("\r", '<br />').gsub("\n", '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga.data[5] + "', '"
      ret += manga.data[6] + "', '"
      ret += manga.data[8] + "', '"
      ret += manga.data[9] + "', "
      ret += manga.data[10].to_s + ", '"
      ret += manga.data[7] + "', "
      ret += manga.data[13].to_s + ', '
      ret += (manga.data[14] * 100 / manga.data[15]).round(2).to_s + "],\n" # rating and rating max
    end
    ret += '];'
    ret
  end

  # generates the links for each manga ( cover + name ), used for the manga index
  def html_get_data(site, updated_recently = false)
    mangas = @db.get_manga_list(site)
    ret = []
    i = 0
    # mangas = mangas.reject.... if updated_recently
    mangas.sort{|a, b| a.link <=> b.link}.each do |manga|
      ret << "  <div class='manga'>"
      if updated_recently
        ret << "    <a href=\"" + './html/' + manga.name + '.html' + '">'
      else
        ret << "    <a onmouseover=\"displayData(#{i})\" onmouseout=\"clearData()\" href=\"" + './html/' + manga.name + '.html' + '">'
      end
      source_buffer = '      <img src="./mangas/' + manga.name + '.jpg' + '">'
      if @params[9] == 'false'
        manga_genres = manga.data[9].split(', ')
        if (@params[10].split(', ') & manga_genres).empty?
          ret << source_buffer
        else
          # warning : sites must be managed
          ret << '      <img src="' + Dir.home + '/.MangaScrap/pictures/logos/mangafox.png">'
        end
      else
        ret << source_buffer
      end
      ret << '      <p>' + description_manipulation(manga.name.gsub('_', ' '), 25, 3).gsub('\n', '<br />') + '</p>'
      ret << '    </a>'
      ret << '  </div>'
      i += 1
    end
  ret.join("\n")
  end

  def file_copy(file_name, dest)
    file = File.open(file_name).read
    File.open(dest, 'w') {|f| f.write(file)}
  end

  # copies the static files ( the css and css witch is not edited )
  # keeps track of what was copied to avoid unnecessary copies
  def copy_html_related_files(site)
    unless $copied_js_css.include?(site)
      dir_create(@dir + 'html/css/')
      dir_create(@dir + 'html/js/')
      # css
      file_copy(__dir__ + '/../../../templates/chapter_index_template.css', @dir + '/html/css/chapter_index.css')
      file_copy(__dir__ + '/../../../templates/chapter_template.css', @dir + '/html/css/chapter.css')
      file_copy(__dir__ + '/../../../templates/manga_index_template.css', @dir + '/html/css/manga_index.css')
      file_copy(__dir__ + '/../../../templates/manga_updated_index_template.css', @dir + '/html/css/manga_updated_index.css')
      # js
      file_copy(__dir__ + '/../../../templates/chapter_index_template.js', @dir + '/html/js/chapter_index.js')
      file_copy(__dir__ + '/../../../templates/chapter_template.js', @dir + '/html/js/chapter.js')
      $copied_js_css << site
    end
  end

  public
  # generates the chapter index, includes description, cover, names of artist and author, ...
  def generate_chapter_index(manga_data, index = true)
    if @params[8] == 'true' || @force_html == true
      @dir = @params[1] + get_dir_from_site(manga_data.site)
      puts 'updating chapter index of ' + manga_data.name
      @manga_init = true
      @manga_data = []
      if manga_data.in_db
        @manga_data = manga_data.data
      else
        @manga_data = @db.get_manga(manga_data)
      end
      @params[1] + manga_data.site_dir
      @path_to_cover = '/mangas/' + @manga_data[1] + '.jpg'
      @path_pictures = '/mangas/' + @manga_data[1] + '/'
      @manga_name = @manga_data[11]
      @path_html = @dir + 'html/' + @manga_data[1]
      @index_path = @dir + 'index.html' #todo : manage sites
      @traces = get_traces(manga_data)
      dir_create(@path_html)
      template = File.open('templates/chapter_index_template.html').read
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
      File.open(@path_html + '.html', 'w') {|f| f.write(template)}
      if index
        @chapter_template = File.open('templates/chapter_template.html').read
        html_generate_chapters(manga_data)
      end
    end
  end

  # generates the manga index ( the page containing the links to all mangas )
  def generate_index
    if @params[8] == 'true' || @force_html == true
      puts 'updating html of manga index'
      sites = Manga_data.get_compatible_sites
      sites.each do |site|
        @dir = @params[1] + get_dir_from_site(site)
        copy_html_related_files(site)
        template = File.open('templates/manga_index_template.html').read
        template = template.gsub('#####list#####', html_get_data(site))
        File.open(@dir + 'index.html', 'w') {|f| f.write(template)}
        js = File.open('templates/manga_index_template.js').read
        js = js.gsub('#####tab#####', index_js_data(site))
        File.open(@dir + 'html/js/manga_index.js', 'w') {|f| f.write(js)}
      end
    end
  end

  # very similar to the index but only shows the recently updated elements

  # WARNING ======================================================================================================================================================
  #
  # pour savoir qui a fait une mise à jour en dernier :
  # requete SQL de type (SELECT manga_id(unique) from traces where updated *less than 2 days*)
  #
  # WARNING ======================================================================================================================================================

  def generate_updated
    if @params[8] == 'true' || @force_html == true
      puts 'generating updated index'
      sites = Manga_data.get_compatible_sites
      sites.each do |site|
        @dir = @params[1] + get_dir_from_site(site)
        copy_html_related_files(site)
        template = File.open('templates/manga_updated_index_template.html').read
        template = template.gsub('#####list#####', html_get_data(site, true))
        File.open(@dir + 'index_updated.html', 'w') {|f| f.write(template)}
      end
    end
  end

  # the constructor copies all the css and places them in the html dir
  def initialize(force_html = false)
    @force_html = force_html
    @params = Params.instance.get_params
    @nsfw_genres = @params[10].split(', ')
    @manga_init = false
    @db = Manga_database.instance
    @dir = ''
    @manga_data = []
    @traces = []
  end
end