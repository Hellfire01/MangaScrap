def delete_bad_files(traces, data, dir)
  # manage external files ( -42 ) here
  p data[0]
  abort
  data.each
end

def delete_diff(db, chap_list, dir, name)
  chap_list = chap_list.map{|elem| data_extractor_MF(elem).shift(2)}.reverse
  trace = db_to_trace(db, name)
  pb = trace.select{|elem| chap_list.include?(elem) == false}
  pb.each do |chap|
    puts "deleting volume " + volume_int_to_string(chap[0]) + " chapter " + chap[1].to_s + " from trace database"
    db.delete_trace(name, chap)
    Dir.glob(file_name(dir, chap[0], chap[1], nil, true)).sort.each do |file|
      puts "deleting file : " + file
      File.delete(file)
    end
  end
end
