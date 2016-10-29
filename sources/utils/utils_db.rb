# displays an error message and exits
def db_error_exit(message, error)
  puts message
  puts "message is : '" + error.message + "'"
  exit 2
end

# returns the mangafox class on success or displays an error message and returns nil
def get_mf_class(db, manga_name, data)
  begin
    ret = Download_Mangafox.new(db, manga_name, data)
    return ret
  rescue => e
    puts "error while trying to add #{manga_name}"
    puts "reason is : " + e.message
    return nil
  end
end
