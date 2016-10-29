$default_manga_path = Dir.home + "/Documents/mangas/"

# warning, Params is a Singleton type class
class Params  
  def initialize()
    @db = SQLite3::Database.new(Dir.home + "/.MangaScrap/db/params.db")
    begin
      @db.execute "CREATE TABLE IF NOT EXISTS params (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      manga_path TEXT,
      between_sleep FLOAT,
      failure_sleep FLOAT,
      nb_tries_on_fail INT,
      error_sleep FLOAT,
      delete_diff TEXT,
      catch_exception TEXT,
      generate_html TEXT,
      html_nsfw TEXT,
      html_nsfw_data TEXT)"
      ret = @db.execute "SELECT * FROM params"
      if (ret.size == 0)
        puts "initializing params './MangaScrap -pl' to list params\n\n"
        reset_parameters(true)
      end
    rescue SQLite3::Exception => e
      db_error_exit("exception while retrieving params / initializing params", e)
    end
  end

  @@instance = Params.new

  def self.instance
    return @@instance
  end

  def get_params()
    begin
      ret = @db.execute "SELECT * FROM params"
      if ret.size == 0
        raise "db is nil"
      end
    rescue StandardError => e
      db_error_exit("could not get params", e)
    rescue SQLite3::Exception => e
      db_error_exit("could not get params", e)
    end
    return ret[0]
  end

  def set_param(param, value)
    begin
      prep = @db.prepare "UPDATE params SET #{param} = ? WHERE Id = 1"
      prep.bind_param 1, value
      prep.execute
    rescue SQLite3::Exception => e
      db_error_exit("could not update " + param, e)
    end
  end

  def reset_parameters(init = false)
    begin
      if init == false
        prep = @db.prepare "UPDATE params SET manga_path = ?, between_sleep = 0.1, failure_sleep = 0.1,
        nb_tries_on_fail = 20, error_sleep = 30, delete_diff = ?, catch_exception = ?,
        generate_html = ?, html_nsfw = ?, html_nsfw_data = ? WHERE Id = 1"
      else
        prep = @db.prepare "INSERT INTO params VALUES (NULL, ?, 0.1, 0.1, 20, 30, ?, ?, ?, ?, ?)"
      end
      prep.bind_param 1, $default_manga_path
      prep.bind_param 2, "true"
      prep.bind_param 3, "true"
      prep.bind_param 4, "true"
      prep.bind_param 5, "true"
      prep.bind_param 6, "Ecchi, Mature, Smut, Adult"
      prep.execute
    rescue SQLite3::Exception => e
      db_error_exit("could not set / reset parameters", e)
    end
  end

  private_class_method :new
end
