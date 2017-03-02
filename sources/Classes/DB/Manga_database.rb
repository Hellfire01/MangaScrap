#manga database
class Manga_database
  include Singleton
  private
  def now
    Time.new.strftime('%Y/%m/%d')
  end

  public
  # used to cast the lin of manga_list into a Manga_data
  def data_to_manga_data(data)
    Manga_data.new(data[0], data[1], data[3], data[4], data)
  end

  # tries and caches an sql request
  def db_exec(request, error, args = [])
    begin
      ret = @db.execute request, args
    rescue SQLite3::Exception => e
      critical_error(error, e)
    end
    ret
  end

  # def add_manga(*args)
  def add_manga(manga_data, description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max)
    arguments = [manga_data.name, description, manga_data.site, manga_data.link, author, artist, type, status, genres,release, html_name, alternative_names, rank, rating, rating_max, now, false.to_s, false.to_s]
    db_exec('INSERT INTO manga_list VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 'could not insert ' + manga_data.name.yellow + ' into the database', arguments)
  end

  def update_manga(manga_name, description, author, artist, genres, html_name, alternative_names, rank, rating, rating_max)
    args = [description, author, artist, html_name, genres, alternative_names, rank, rating, rating_max]
    # manga_name variable must always be last ( note for future updates )
    args << manga_name
    db_exec('UPDATE manga_list SET description=?, author=?, artist=?, html_name=?, genres=?, alternative_names=?, rank=?, rating=?, rating_max=? WHERE name=?', 'could not update ' + manga_name.yellow, args)
  end

  def delete_manga(manga_data)
    clear_todo(manga_data)
    db_exec('DELETE FROM manga_trace WHERE mangaId=?', "Exception while deleting #{manga_data.name} from trace database", [manga_data.id])
    db_exec('DELETE FROM manga_list WHERE Id=?', "Exception while deleting #{manga_data.name} from database", [manga_data.id])
  end

  def get_manga(manga_data)
    if manga_data == nil
      puts 'Error '.red + ': while trying to get manga in database => Data is nil'
      exit 2
    end
    # todo use db_exec correctly
    ret = db_exec("SELECT * FROM manga_list WHERE name='#{manga_data.name}' and site='#{manga_data.site}'", "Exception while getting #{manga_data.name} in database")
    ret[0]
  end

  def manga_in_data?(manga_data)
    if get_manga(manga_data) == nil
      return false
    end
    true
  end

  # todo il faut adapter le html
  def get_manga_list(site = nil)
    if site == nil
      buff = db_exec('SELECT * FROM manga_list ORDER BY name COLLATE NOCASE', 'Exception while getting manga list')
    else
      buff = db_exec('SELECT * FROM manga_list WHERE site=? ORDER BY name COLLATE NOCASE', 'Exception while getting manga list', [site])
    end
    ret = []
    buff.each do |manga|
      ret << data_to_manga_data(manga)
    end
    ret
  end

  # _todo database
  def add_todo(manga_data, volume_value, chapter_value, page_nb)
    if manga_data == nil || volume_value == nil || chapter_value == nil || page_nb == nil
      puts 'Error while trying to insert element in todo database => nil'
      p insert
      puts '(manga_name, volume, chapter, page)'
      exit 2
    end
    todo = get_todo(manga_data)
    insert = [manga_data.id, volume_value, chapter_value, page_nb, now]
    todo.each do |elem|
      elem.shift
      if elem == insert
        return false
      end
    end
    db_exec('INSERT INTO manga_todo VALUES (NULL, ?, ?, ?, ?, ?)', 'could not add todo for ' + manga_data.name, insert)
    true
  end

  def get_todo(manga_data)
    db_exec('SELECT * FROM manga_todo WHERE mangaId=?', 'exception on database while getting todo of ' + manga_data.name, [manga_data.id])
  end

  def delete_todo(id)
    db_exec('DELETE FROM manga_todo WHERE Id=?', 'exception on database while deleting todo element', [id])
  end

  def clear_todo(manga_data)
    db_exec('DELETE FROM manga_todo WHERE mangaId=?', "exception on database while deleting todo of #{manga_data.name}", [manga_data.id])
  end

  # trace database
  def add_trace(manga_data, volume_value, chapter_value, nb_pages)
    if manga_data == nil || volume_value == nil || chapter_value == nil
      puts 'Error while trying to insert element in trace database'
      puts ((manga_data == nil) ? 'manga_data is nil' : 'volume or chapter value is nil')
      exit 2
    end
    trace = get_trace(manga_data)
    insert = [manga_data.id, volume_value, chapter_value, now, nb_pages]
    found = false
    trace.each do |elem| # checking if the trace does not already exist in database to avoid duplicates
      elem.shift # the first element is shift as it contains the id of the trace
      if elem == insert
        found = true
        break
      end
    end
    unless found
      db_exec('INSERT INTO manga_trace VALUES (NULL, ?, ?, ?, ?, ?)', 'could not add trace for ' + manga_data.name.yellow, insert)
    end
  end
  
  def get_trace(manga_data)
    db_exec('SELECT * FROM manga_trace WHERE mangaId=?', "could not get trace database of #{manga_data.name}", [manga_data.id])
  end

  def delete_trace(manga_data, chapter)
    db_exec('DELETE FROM manga_trace WHERE mangaId=? AND volume=? and chapter=?', 'could not erase element from trace database', [manga_data.id, chapter[0], chapter[1]])
  end

  #init database
  def initialize
    begin
      @db = SQLite3::Database.new Dir.home + '/.MangaScrap/db/manga.db'
      # manga_db
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_list (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, site TEXT,
        link TEXT, author TEXT, artist TEXT, type TEXT, status BOOL, genres TEXT,
        release INTEGER, html_name TEXT, alternative_names NTEXT, rank INTEGER, rating INTEGER,
        rating_max INTEGER, date VARCHAR(32), no_auto_updates BOOL, ignore_todo BOOL)'
      # todo_db
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_todo (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, mangaId INTEGER, volume INTEGER, chapter DOUBLE, page INTEGER, date VARCHAR(32))'
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_todo_string (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, mangaId INTEGER, chap TEXT, page INTEGER, date VARCHAR(32))'
      # traces_db
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_trace (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, mangaId INTEGER, volume INTEGER, chapter DOUBLE, date VARCHAR(32), nb_pages INTEGER)'
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_trace_string (
        Id INTEGER PRIMARY KEY AUTOINCREMENT, mangaId INTEGER, chap TEXT, date VARCHAR(32), nb_pages INTEGER)'
    rescue SQLite3::Exception => e
      critical_error('exception occured while trying to open / create tables', e)
    end
  end
end
