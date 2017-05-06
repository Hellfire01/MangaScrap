module Utils_database
  # tries and caches an sql request
  def self.db_exec(request, error, db, args = [])
    begin
      ret = db.execute request, args
    rescue SQLite3::Exception => e
     Utils_errors::critical_error(error, e)
    end
    ret
  end
end
