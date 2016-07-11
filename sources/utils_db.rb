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
    puts "error while trying to add #{name[0]}"
    puts "reason is : " + e.message
    return nil
  end
end
