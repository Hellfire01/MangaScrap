class HTML
  private
  # generates the links for each manga ( cover + name ), used for the manga index
  def html_get_data(site, updated_recently = false)
    ret = []
    i = 0
    # mangas = mangas.reject.... if updated_recently
    @mangas.each do |manga|
      ret << "  <div class='manga'>"
      if updated_recently
        ret << "    <a href=\"" + './html/' + manga[:name] + '.html' + '">'
      else
        ret << "    <a onmouseover=\"displayData(#{i})\" onmouseout=\"clearData()\" href=\"" + './html/' + manga[:name] + '.html' + '">'
      end
      source_buffer = '      <img src="./mangas/' + manga[:name] + '.jpg' + '">'
      if @html_params[:nsfw_enabled]
        ret << source_buffer
      else
        manga_genres = manga[:data][9].split(', ')
        if (@html_params[:nsfw_categories].split(', ') & manga_genres).empty?
          ret << source_buffer
        else
          # todo manage sites
          # warning : sites must be managed
          ret << '      <img src="' + Dir.home + '/.MangaScrap/pictures/logos/mangafox.png">'
        end
      end
      ret << '      <p>' + Utils_file::description_manipulation(manga[:name].gsub('_', ' '), 25, 3).gsub('\n', '<br />') + '</p>'
      ret << '    </a>'
      ret << '  </div>'
      i += 1
    end
    ret.join("\n")
  end

  # manages the js of the index
  def index_js_data(site)
    ret = "var data = [\n"
    @mangas.each do |manga|
      ret += "  ['" + manga[:data][11].gsub('; ', '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga[:data][12].gsub('; ', '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga[:data][2].gsub("\r", '<br />').gsub("\n", '<br />').gsub("'", '###guillemet###') + "', '"
      ret += manga[:data][5] + "', '"
      ret += manga[:data][6] + "', '"
      ret += manga[:data][8] + "', '"
      ret += manga[:data][9] + "', "
      ret += manga[:data][10].to_s + ", '"
      ret += manga[:data][7] + "', "
      ret += manga[:data][13].to_s + ', '
      ret += (manga[:data][14] * 100 / manga[:data][15]).round(2).to_s + "],\n" # rating and rating max
    end
    ret += '];'
    ret
  end

  public
# generates the manga index ( the page containing the links to all mangas )
  def generate_index
    if @html_params[:auto_generate_html]
      puts 'updating html of manga index'
      sites = Web_data.instance.sites
      sites.each do |site|
        @mangas = @db.get_manga_list(site).sort{|a, b| a[:link] <=> b[:link]}
        dir = @manga_path + site[:dir]
        HTML_utils::copy_html_related_files(site, dir)
        template = File.open('sources/templates/web/site_index/site_index_template.html').read
        template = template.gsub('#####list#####', html_get_data(site))
        template = template.gsub('#####site_name#####', site[:dir].chomp('/'))
        File.open(dir + 'index.html', 'w') {|f| f.write(template)}
        js = File.open('sources/templates/web//site_index/site_index_template.js').read
        js = js.gsub('#####tab#####', index_js_data(site))
        File.open(dir + 'html/js/manga_index.js', 'w') {|f| f.write(js)}
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
=begin commented until it is enabled
    if @html_params[:auto_generate_html]
      puts 'generating updated index'
      sites = Web_data.instance.sites
      sites.each do |site|
        dir = @manga_path + site[:dir]
        HTML_utils::copy_html_related_files(site, dir)
        template = File.open('sources/templates/web/manga_updated_index_template.html').read
        template = template.gsub('#####list#####', html_get_data(site, true))
        template = template.gsub('#####site_name#####', site[:dir].chomp('/'))
        File.open(dir + 'index_updated.html', 'w') {|f| f.write(template)}
      end
    end
=end
  end

  # the constructor copies all the css and places them in the html dir
  def initialize(force_html = false)
    @force_html = force_html
    @manga_path = Params.instance.download[:manga_path]
    @html_params = Params.instance.html
    @db = Manga_database.instance
    @mangas = []
  end
end
