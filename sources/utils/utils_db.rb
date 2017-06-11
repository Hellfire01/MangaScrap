module Utils_database
  # tries and caches an sql request
  # request = the string that is executed
  # error = the error message
  # db = the database
  # args = the (optional) array of arguments
  def self.db_exec(request, error, db, args = [])
    begin
      ret = db.execute request, args
    rescue SQLite3::Exception => e
     Utils_errors::critical_error(error, e)
    end
    ret
  end
end
