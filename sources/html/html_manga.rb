class HTML_manga
  private
  # used to separate the different genres, authors and artists into separate <a>
  def html_a_buffer(data)
    tmp = data.split(', ')
    ret = tmp.map do |elem|
      #todo : href needs to be changed when the genres will have the html generated
      '<a href="#">' + elem + '</a>'
    end
    ret.join(', ')
  end

  # adds variables to @traces in order to sort / check
  def get_traces(manga_data)
    ret = []
    tmp = @db.get_trace(manga_data)
    tmp.each do |chap|
      filename = HTML_utils::html_chapter_filename(chap[3], chap[2])
      href = "<a href=\"#####html_path#####" + filename + "\">#####elem#####</a>"
      nb_pages = Dir.glob(Utils_file::file_name(@dir + @path_pictures, chap[2], chap[3], -1, true)).size
      ret << Struct::HTML_data.new(chap[2], chap[3], chap[4], href, nb_pages, '.' + filename)
    end
    ret
  end

  # gets all the pictures for each chapter
  def get_pictures_of_chapter(chapter)
    ret = []
    i = 1
    Dir.glob(Utils_file::file_name(@dir + @path_pictures, chapter[:volume], chapter[:chapter], -1, true)).each do |file|
      file_relative_pos = Utils_file::file_name('../../mangas/' + @manga_data[1] + '/', chapter[:volume], chapter[:chapter], i) + '.jpg'
      ret << "<p class=\"small-text\">#{i}</p>"
      ret << "<div class=\"frame\">\n"
      ret << "    <span class=\"helper\"></span><img src=\"#{file_relative_pos}\">\n"
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
    chap_data = 'Chapter ' + ((arr[1][:chapter] % 1 == 0) ? arr[1][:chapter].to_i : arr[1][:chapter]).to_s + ' ' + Utils_file::volume_int_to_string(arr[1][:volume], true)
    max_chap_data = 'Chapter ' + ((@traces[0][:chapter] % 1 == 0) ? @traces[0][:chapter].to_i : @traces[0][:chapter]).to_s + ' ' + Utils_file::volume_int_to_string(@traces[0][:volume], true)
    template = template.gsub('#####chapter_data#####', chap_data + ' / ' + max_chap_data)
    template = template.gsub('#####pictures#####', get_pictures_of_chapter(arr[1]))
    template = template.gsub('#####manga_index#####', @dir + 'index.html')
    template = template.gsub('#', '%23')
    File.open(@path_html + HTML_utils::html_chapter_filename(arr[1][:chapter], arr[1][:volume]), 'w') {|f| f.write(template) }
  end

  # generates html for all the chapters and links them ( prev and next buttons )
  def html_generate_chapters(manga_data)
    puts 'updating html chapters of ' + manga_data[1] if @traces.size != 0
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
      puts 'warning : no chapters in database, could not generate chapters'.yellow if @traces.size != 0
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
  #      pp chapter
  #      exit 42
      ret += "<li>\n"
      chapter_buff = (chapter[:chapter] % 1 == 0) ? chapter[:chapter].to_i.to_s : chapter[:chapter].to_s
      volume_buff = Utils_file::volume_int_to_string(chapter[:volume], true)
      buff = chapter[:href].gsub('#####html_path#####', @manga_data[1]).gsub('#####elem#####', volume_buff + ' Chapter ' + chapter_buff).gsub('#', '%23')
      ret += buff
      ret += "</li>\n"
    end
    template = template.gsub('#####list#####', ret)
    template.gsub('#####first#####', buff)
  end

  public
  # generates the chapter index, includes description, cover, names of artist and author, ...
  def generate_chapter_index
    if @html_params[:auto_generate_html]
      puts 'updating chapter index of ' + @manga_data[1]
      Utils_file::dir_create(@path_html)
      template = File.open('sources/templates/web/manga_presentation/presentation_template.html').read
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
      template = template.gsub('#####cover#####', '../mangas/' + @manga_data[1] + '.jpg')
      template = template.gsub('#####index_path#####', '../index.html')
      template = template.gsub('#####rank#####', @manga_data[13].to_s)
      template = template.gsub('#####rating#####', @manga_data[14].to_s + ' / ' + @manga_data[15].to_s)
      template = chapter_list_to_a_list(template).gsub('#', '%23')
      File.open(@path_html + '.html', 'w') {|f| f.write(template)}
      @chapter_template = File.open('sources/templates/web/chapter/chapter_template.html').read
      html_generate_chapters(@manga_data)
    end
  end

  def initialize(manga_data, force_html = false)
    @html_params = Params.instance.html
    @db = Manga_database.instance
    @force_html = force_html
    @manga_data = []
    if manga_data.in_db
      @manga_data = manga_data.data
    else
      @manga_data = @db.get_manga(manga_data)
    end
    @manga_name = @manga_data[11]
    @path_pictures = '/mangas/' + @manga_data[1] + '/'
    @dir = Params.instance.download[:manga_path] + Manga_data::get_dir_from_site(manga_data.site)
    @path_html = @dir + 'html/' + @manga_data[1]
    HTML_utils::copy_html_related_files(manga_data.site, @dir)
    @traces = get_traces(manga_data)
  end
end
