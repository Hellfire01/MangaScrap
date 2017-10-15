module Delete_diff
  def self.delete_diff(manga)
    params = Params.instance.download
    db = Manga_database.instance
    dir = params[1] + manga[:website][:dir] + 'mangas/' + manga[:name] + '/'
    unless File.directory?(dir)
      return false
    end
    chap_list = manga[:download_class].links.map{|link| manga.extract_values_from_link(link).shift(2)}.reverse
    tmp_trace = db.get_trace(manga)
    trace = []
    tmp_trace.each do |e|
      # creating an array that contains only volume and chapter values
      trace << [e[2], e[3]]
    end
    pb = trace.select{|elem| !chap_list.include?(elem)}
    deleted = false
    pb.each do |chap|
      puts ('deleting volume ' + Utils_file::volume_int_to_string(chap[0], false) + ' chapter ' + chap[1].to_s).yellow
      Dir.glob(Utils_file::file_name(dir, chap[0], chap[1], nil, true)).sort.each do |file|
        puts 'deleting file : '.yellow + file
        File.delete(file)
      end
      Dir.glob(params[:manga_path] + manga[:website][:dir] + 'html/' + manga[:name] +
                 HTML_utils::html_chapter_filename(chap[1], chap[0])).each do |file|
        puts 'deleting file : '.yellow + file
        File.delete(file)
      end
      db.delete_trace(manga, chap)
      deleted = true
    end
    deleted
  end
end
