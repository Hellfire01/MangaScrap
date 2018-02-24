$db_path = 'db/'

#manga database
class Manga_database
  include Singleton
  private
  def now
    Time.new.strftime('%Y/%m/%d')
  end

  #init database
  def initialize
    begin
      @db = SQLite3::Database.new(Dir.home + '/.MangaScrap/' + $db_path + 'manga.db')
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
      Utils_errors::critical_error('exception occured while trying to open / create tables', e)
    end
  end

  public
  # allows execution of queries from external parts of the program ( mainly used for debugging and updates )
  def exec_query(query, error, args)
    Utils_database::db_exec(query, error, @db, args)
  end

  # used to set unit tests environment
  def self.set_unit_tests_env(db_path)
    $db_path = db_path
  end

  # used to cast the lin of manga_list into a Manga_data
  def data_to_manga_data(data)
    Manga_data.new(data[0], data[1], data[3], data[4], data)
  end

  # def add_manga(*args)
  def add_manga(manga_data, description, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max)
    arguments = [manga_data[:name], description, manga_data[:website][:link], manga_data[:link], author, artist, type, status, genres,release, html_name, alternative_names, rank, rating, rating_max, now, false.to_s, false.to_s]
    Utils_database::db_exec('INSERT INTO manga_list VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 'could not insert ' + manga_data[:name].yellow + ' into the database', @db, arguments)
  end

  def update_manga(manga_name, description, author, artist, genres, html_name, alternative_names, rank, rating, rating_max)
    args = [description, author, artist, html_name, genres, alternative_names, rank, rating, rating_max]
    args << manga_name # manga_name variable must always be last for the WHERE in the sqlite query ( note for future updates )
    Utils_database::db_exec('UPDATE manga_list SET description=?, author=?, artist=?, html_name=?, genres=?, alternative_names=?, rank=?, rating=?, rating_max=? WHERE name=?', 'could not update ' + manga_name.yellow, @db, args)
  end

  def delete_manga(manga_data)
    clear_todo(manga_data)
    Utils_database::db_exec('DELETE FROM manga_trace WHERE mangaId=?', "Exception while deleting #{manga_data[:name]} from trace database", @db, [manga_data[:id]])
    Utils_database::db_exec('DELETE FROM manga_list WHERE Id=?', "Exception while deleting #{manga_data[:name]} from database", @db, [manga_data[:id]])
  end

  def get_manga(manga_data)
    if manga_data == nil
      puts 'Error '.red + ': while trying to get manga in database => Data is nil'
      exit 2
    end
    buff = nil
    if manga_data[:id] != nil
      Utils_database::db_exec('SELECT * FROM manga_list WHERE id=?', "Exception while getting #{manga_data[:name]} in database", @db, [manga_data[:id]])[0]
    else
      Utils_database::db_exec('SELECT * FROM manga_list WHERE link=?', "Exception while getting #{manga_data[:name]} in database", @db, [manga_data[:link]])[0]
    end
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
      buff = Utils_database::db_exec('SELECT * FROM manga_list ORDER BY name COLLATE NOCASE', 'Exception while getting manga list', @db)
    else
      buff = Utils_database::db_exec('SELECT * FROM manga_list WHERE site=? ORDER BY name COLLATE NOCASE', 'Exception while getting manga list', @db, [site[:link]])
    end
    ret = []
    buff.each do |manga|
      ret << data_to_manga_data(manga)
    end
    ret
  end

  # _todo database
  def add_todo(manga_data, volume_value, chapter_value, page_nb)
    insert = [manga_data[:id], volume_value, chapter_value, page_nb, now]
    if manga_data == nil || volume_value == nil || chapter_value == nil || page_nb == nil
      puts 'Error while trying to insert element in todo database => nil'
      p insert
      puts '(manga_name, volume, chapter, page, date)'
      exit 2
    end
    todo = get_todo(manga_data)
    todo.each do |elem|
      if elem[:manga_id] == manga_data[:id] && elem[:volume] == volume_value && elem[:chapter] == chapter_value && elem[:page] == page_nb
        return false
      end
    end
    Utils_database::db_exec('INSERT INTO manga_todo VALUES (NULL, ?, ?, ?, ?, ?)', 'could not add todo for ' + manga_data[:name], @db, insert)
    true
  end

  def get_todo(manga_data)
    raw_todo = Utils_database::db_exec('SELECT * FROM manga_todo WHERE mangaId=?', 'exception on database while getting todo of ' + manga_data[:name], @db, [manga_data[:id]])
    if raw_todo.size == 0
      return raw_todo
    end
    Utils_misc::arrays_to_structures(Struct::Todo_value, raw_todo)
  end

  def delete_todo(id)
    Utils_database::db_exec('DELETE FROM manga_todo WHERE Id=?', 'exception on database while deleting todo element', @db, [id])
  end

  def clear_todo(manga_data)
    Utils_database::db_exec('DELETE FROM manga_todo WHERE mangaId=?', "exception on database while deleting todo of #{manga_data[:name]}", @db, [manga_data[:id]])
  end

  # trace database
  def add_trace(manga_data, volume_value, chapter_value, nb_pages)
    if manga_data == nil || volume_value == nil || chapter_value == nil
      puts 'Error while trying to insert element in trace database'
      puts ((manga_data == nil) ? 'manga_data is nil' : 'volume or chapter value is nil')
      exit 2
    end
    trace = get_trace(manga_data)
    insert = [manga_data[:id], volume_value, chapter_value, now, nb_pages]
    found = false
    # todo : pour les comparaisons de traces, il ne faut surtout pas comparer les dates
    trace.each do |elem| # checking if the trace does not already exist in database to avoid duplicates
      elem.shift # the first element is shift as it contains the id of the trace
      if elem == insert
        found = true
        break
      end
    end
    unless found
      Utils_database::db_exec('INSERT INTO manga_trace VALUES (NULL, ?, ?, ?, ?, ?)', 'could not add trace for ' + manga_data[:name].yellow, @db, insert)
    end
  end

  def get_trace(manga_data)
    Utils_database::db_exec('SELECT * FROM manga_trace WHERE mangaId=?', "could not get trace database of #{manga_data[:name]}", @db, [manga_data[:id]])
  end

  def delete_trace(manga_data, chapter)
    Utils_database::db_exec('DELETE FROM manga_trace WHERE mangaId=? AND volume=? and chapter=?', 'could not erase element from trace database', @db, [manga_data[:id], chapter[0], chapter[1]])
  end
end
