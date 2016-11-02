# todo
def delete_bad_files(traces, data, dir)
  # manage external files ( -42 ) here
  p data[0]
  abort
  data.each
end

#todo => attention à ce que le fichier repéré soit bel et bien celui supprimé
#todo => cette fonction nécessite
def delete_diff(db, chap_list, name)
  params = Params.instance.get_params()
  # todo : manage site
  dir = params[1] + "mangafox/mangas/" + name + "/"
  chap_list = chap_list.map{|elem| data_extractor_MF(elem).shift(2)}.reverse
  trace = db.get_trace(name)
  trace = trace.each {|elem| elem.shift} # delete id of each chapter
  trace = trace.each {|elem| elem.shift} # delete id of manga
  pb = trace.select{|elem| chap_list.include?(elem) == false}
  deleted = false
  pb.each do |chap|
    puts "deleting volume " + volume_int_to_string(chap[0]) + " chapter " + chap[1].to_s + " from trace database"
    Dir.glob(file_name(dir, chap[0], chap[1], nil, true)).sort.each do |file|
      puts "deleting file : " + file
      File.delete(file)
    end
    # todo : manage site
    Dir.glob(params[1] + "mangafox/html/" + name + html_chapter_filename(chap[1], chap[0])).each do |file|
      puts "deleting file : " + file
      File.delete(file)
    end
    db.delete_trace(name, chap)
    deleted = true
  end
  if deleted == true
    HTML.new(db).generate_chapter_index(name)
  end
end
