$default_manga_path = Dir.home + '/Documents/mangas/'

class Params
  include Singleton

  def get_params
    begin
      ret = @db.execute 'SELECT * FROM params'
      if ret.size == 0
        raise 'db is nil'
      end
    rescue StandardError => e
      critical_error('could not get params', e)
    rescue SQLite3::Exception => e
      critical_error('could not get params', e)
    end
    ret[0]
  end

  def set_param(param, value)
    begin
      prep = @db.prepare "UPDATE params SET #{param} = ? WHERE Id = 1"
      prep.bind_param 1, value
      prep.execute
    rescue SQLite3::Exception => e
      critical_error('could not update ' + param, e)
    end
  end

  def reset_parameters(init = false)
    begin
      if !init
        prep = @db.prepare 'UPDATE params SET manga_path = ?, between_sleep = 0.1, failure_sleep = 0.1,
        nb_tries_on_fail = 20, error_sleep = 30, delete_diff = ?, catch_exception = ?,
        generate_html = ?, html_nsfw = ?, html_nsfw_data = ?, color_text = ? WHERE Id = 1'
      else
        prep = @db.prepare 'INSERT INTO params VALUES (NULL, ?, 0.1, 0.1, 20, 30, ?, ?, ?, ?, ?, ?)'
      end
      prep.bind_param 1, $default_manga_path
      prep.bind_param 2, 'true'
      prep.bind_param 3, 'true'
      prep.bind_param 4, 'true'
      prep.bind_param 5, 'true'
      prep.bind_param 6, 'Ecchi, Mature, Smut, Adult'
      prep.bind_param 7, 'true'
      prep.execute
    rescue SQLite3::Exception => e
      critical_error('could not set / reset parameters', e)
    end
  end

  def introduction
    puts ''
    puts ''
    puts 'Hi, thank you for using MangaScrap, please do enjoy using it'
    puts 'The database will be created and initialized with default values'
    puts 'Please make sure those values suit you'
    puts ''
    puts 'To check the parameter values, execute :'
    puts './MangaScrap.rb params list'
    puts 'For any help, execute :'
    puts './MangaScrap.rb help'
    puts ''
    puts 'Please note that by default, the directory in witch MangaScrap will place all the downloaded mangas is :'
    puts $default_manga_path.yellow
    puts ''
    puts ''
    puts 'if you enjoy using MangaScrap, please o star me on githhub :'
    puts 'https://github.com/Hellfire01/MangaScrap'
    puts ''
    puts ''
    puts ''
  end

  def initialize
    unless Dir.exists?(Dir.home + '/.MangaScrap/db/')
      dir_create(Dir.home + '/.MangaScrap/db/')
    end
    begin
      @db = SQLite3::Database.new(Dir.home + '/.MangaScrap/db/params.db')
      @db.execute 'CREATE TABLE IF NOT EXISTS params (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      manga_path TEXT,
      between_sleep FLOAT,
      failure_sleep FLOAT,
      nb_tries_on_fail INT,
      error_sleep FLOAT,
      delete_diff VARCHAR(5),
      catch_exception VARCHAR(5),
      generate_html VARCHAR(5),
      html_nsfw VARCHAR(5),
      html_nsfw_data VARCHAR(5),
      color_text VARCHAR(5))'
      ret = @db.execute 'SELECT * FROM params'
      if ret.size == 0
        introduction
        reset_parameters(true)
      end
    rescue SQLite3::Exception => e
      critical_error('exception while retrieving params / initializing params', e)
    end
  end
end
