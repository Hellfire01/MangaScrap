$default_manga_path = Dir.home + "/Documents/mangas/"

class Params
  def get_params()
    begin
      ret = @db.execute "SELECT * FROM params"
    rescue SQLite3::Exception => e
      puts "could not get params"
      abort (e.message)
    end
    return ret[0]
  end

  def set_params_path(path)
    if (path == nil || path.size == 0)
      puts "you need to input a path"
      exit 5
    end
    if (path[path.size - 1] != '/')
      path += '/'
    end
    begin
      prep = @db.prepare "UPDATE params SET manga_path = ? WHERE Id = 1"
      prep.bind_param 1, path
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not update manga path"
      abort (e.message)
    end
  end

  def set_params_failure_sleep(sleep)
    begin
      @db.execute "UPDATE params SET failure_sleep = #{sleep} WHERE Id = 1"
    rescue SQLite3::Exception => e
      puts "could not update failure sleep"
      abort (e.message)
    end
  end

  def set_params_between_sleep(sleep)
    begin
      @db.execute "UPDATE params SET between_sleep = #{sleep} WHERE Id = 1"
    rescue SQLite3::Exception => e
      puts "could not update between sleep"
      abort (e.message)
    end
  end

  def set_params_nb_tries(nb)
    begin
      @db.execute "UPDATE params SET nb_tries_on_fail = #{nb} WHERE Id = 1"
    rescue SQLite3::Exception => e
      puts "could not update number of tries"
      abort (e.message)
    end
  end

  def set_params_error_sleep(sleep)
    begin
      @db.execute "UPDATE params SET error_sleep = #{sleep} WHERE Id = 1"
    rescue SQLite3::Exception => e
      puts "could not update error sleep"
      abort (e.message)
    end
  end

  def set_params_delete_diff(bool)
    begin
      prep = @db.prepare "UPDATE params SET delete_diff = ? WHERE Id = 1"
      prep.bind_param 1, bool
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not update error sleep"
      abort (e.message)
    end
  end

  def reset_parameters()
    begin
      prep = @db.prepare "UPDATE params SET
      manga_path = ?,
      between_sleep = 0.2,
      failure_sleep = 0.2,
      nb_tries_on_fail = 20,
      error_sleep = 30,
      delete_diff = ?
      WHERE Id = 1"
      prep.bind_param 1, $default_manga_path
      prep.bind_param 2, "true"
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not reset parameters"
      abort (e.message)
    end
  end

  def initialize()
    @db = SQLite3::Database.new "DB/params.db"
    begin 
      @db.execute "CREATE TABLE IF NOT EXISTS params (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      manga_path TEXT,
      between_sleep FLOAT,
      failure_sleep FLOAT,
      nb_tries_on_fail INT,
      error_sleep FLOAT,
      delete_diff TEXT)"
    rescue SQLite3::Exception => e
      puts "Exception occurred when opening / creating params table"
      abort ("message is : '" + e.message + "'")
    end
    begin
      ret = @db.execute "SELECT * FROM params"
      if (ret.size == 0)
        puts "initializing params './MangaScrap -pl' to list params"
        prep = @db.prepare "INSERT INTO params VALUES (NULL, ?, 0.2, 0.2, 20, 30, ?)"
        prep.bind_param 1, $default_manga_path
        prep.bind_param 2, "true"
        prep.execute
      end
    rescue SQLite3::Exception => e
      puts "exception while retrieving params"
      abort ("message is : '" + e.message + "'")  
    end
  end
end
