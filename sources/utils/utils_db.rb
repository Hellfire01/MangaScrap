def db_error_exit(message, error)
  puts message
  puts "message is : '" + error.message + "'"
  exit 2
end

def get_mf_class(db, manga_name, data)
  begin
    ret = Download_mf.new(db, manga_name, data)
    return ret
  rescue => e
    puts "error while trying to add #{manga_name}"
    puts "reason is : " + e.message
    return nil
  end
end

# used to get only the chapter and volumes values from db
def db_to_trace(db, name)
  trace = db.get_trace(name)
  trace = trace.each {|elem| elem.shift} # delete id of each chapter
  trace = trace.each {|elem| elem.shift} # delete if of manga
  return trace
end
