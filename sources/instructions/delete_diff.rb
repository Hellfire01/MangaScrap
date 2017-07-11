module Delete_diff
  # todo
  def self.delete_bad_files(traces, data, dir)
    # manage external files ( -42 ) here
    p data[0]
    abort
    data.each
  end

  #todo => attention à ce que le fichier repéré soit bel et bien celui supprimé
  def self.delete_diff(chap_list, manga_data)
    params = Params.instance.download
    db = Manga_database.instance
    dir = params[1] + manga_data.site_dir + 'mangas/' + manga_data.name + '/'
    unless File.directory?(dir)
      puts 'Error : '.red
      puts 'path ' + dir.yellow + ' does not exist, cannot delete-diff'
      return false
    end
    chap_list = chap_list.map{|link| manga_data.extract_values_from_link(link).shift(2)}.reverse
    tmp_trace = db.get_trace(manga_data)
    trace = []
    tmp_trace.each do |e|
      # creating an array that contains only volume and chapter values
      trace << [e[2], e[3]]
    end
    pb = trace.select{|elem| !chap_list.include?(elem)}
    deleted = false
    pb.each do |chap|
      puts ('deleting ' + Utils_file::volume_int_to_string(chap[0], false) + ' chapter ' + chap[1].to_s).yellow
      Dir.glob(Utils_file::file_name(dir, chap[0], chap[1], nil, true)).sort.each do |file|
        puts 'deleting file : '.yellow + file
        File.delete(file)
      end
      Dir.glob(params[:manga_path] + manga_data.site_dir + 'html/' + manga_data.name + HTML_utils::html_chapter_filename(chap[1], chap[0])).each do |file|
        puts 'deleting file : '.yellow + file
        File.delete(file)
      end
      db.delete_trace(manga_data, chap)
      deleted = true
    end
    deleted
  end
end
