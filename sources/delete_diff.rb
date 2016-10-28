# todo
def delete_bad_files(traces, data, dir)
  # manage external files ( -42 ) here
  p data[0]
  abort
  data.each
end

#todo => attention à ce que le fichier repéré soit bel et bien celui supprimé
def delete_diff(db, chap_list, dir, name)
  return 
  chap_list = chap_list.map{|elem| data_extractor_MF(elem).shift(2)}.reverse
  trace = db_to_trace(db, name)
  pb = trace.select{|elem| chap_list.include?(elem) == false}
  deleted = false
  pb.each do |chap|
    puts "deleting volume " + volume_int_to_string(chap[0]) + " chapter " + chap[1].to_s + " from trace database"
    db.delete_trace(name, chap)
    Dir.glob(file_name(dir, chap[0], chap[1], nil, true)).sort.each do |file|
      puts "deleting file : " + file
      File.delete(file)
    end
    # this is used because the html class ( witch also uses the html_chapter_filename ) uses a different array
    tmp = []
    tmp << 0 << 0 << chap[0] << chap[1]
    Dir.glob(Params.new.get_params()[1] + "mangafox/html/" + name + html_chapter_filename(tmp)).each do |file|
      puts "deleting file : " + file
      File.delete(file)
    end
    deleted = true
  end
  if deleted == true
    HTML.new(db).generate_chapter_index(name)
  end
end
