#manga database
class Manga_database
  def add_manga(manga_name, description, site, link, author, artist, type, status, genres, release, html_name, alternative_names, rank, rating, rating_max)
    begin
      prep = @db.prepare 'INSERT INTO manga_list VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
      prep.bind_param 1, manga_name
      prep.bind_param 2, description
      prep.bind_param 3, site
      prep.bind_param 4, link
      prep.bind_param 5, author
      prep.bind_param 6, artist
      prep.bind_param 7, type
      prep.bind_param 8, status
      prep.bind_param 9, genres
      prep.bind_param 10, release
      prep.bind_param 11, html_name
      prep.bind_param 12, alternative_names
      prep.bind_param 13, rank
      prep.bind_param 14, rating
      prep.bind_param 15, rating_max
      prep.execute
    rescue SQLite3::Exception => e
      db_error_exit('Exception while adding manga to database', e)
    end
  end

  def update_manga(manga_name, description, author, artist, genres, html_name, alternative_names, rank, rating, rating_max)
    begin
      prep = @db.prepare 'UPDATE manga_list SET description=?, author=?, artist=?, html_name=?, genres=?, alternative_names=?, rank=?, rating=?, rating_max=? WHERE name=?'
      prep.bind_param 1, description
      prep.bind_param 2, author
      prep.bind_param 3, artist
      prep.bind_param 4, html_name
      prep.bind_param 5, genres
      prep.bind_param 6, alternative_names
      prep.bind_param 7, rank
      prep.bind_param 8, rating
      prep.bind_param 9, rating_max
      # manga_name variable must always be last ( note for future updates )
      prep.bind_param 10, manga_name
      prep.execute
    rescue SQLite3::Exception => e
      db_error_exit("Error while trying to update data of #{manga_name}", e)
    end
  end

  def delete_manga(manga_name)
    manga_id = get_manga(manga_name)[0]
    delete_todo(manga_id)
    begin
      @db.execute "DELETE FROM manga_trace WHERE mangaId=#{manga_id}"
    rescue SQLite3::Exception => e
      db_error_exit("Exception while deleting #{manga_name} from trace database", e)
    end
    begin
      @db.execute "DELETE FROM manga_list WHERE name = '#{manga_name}'"
    rescue SQLite3::Exception => e
      db_error_exit("Exception while deleting #{manga_name} from database", e)
    end
  end

  def get_manga(manga_name)
    if manga_name == nil
      puts 'error while trying to get manga in database => name is nil'
      exit 2
    end
    begin
      ret = @db.execute "SELECT * FROM manga_list WHERE name='#{manga_name}'"
    rescue SQLite3::Exception => e
      db_error_exit("Exception while getting #{manga_name} in database", e)
    end
    ret[0]
  end

  def manga_in_data?(manga_name)
    manga = get_manga(manga_name)
    if manga == nil
      return false
    end
    true
  end

  def get_manga_list(data = false)
    begin
      ret = @db.execute 'SELECT ' + ((!data) ? 'name' : '*') + ' FROM manga_list ORDER BY name COLLATE NOCASE'
    rescue SQLite3::Exception => e
      db_error_exit('Exception while getting manga list', e)
    end
    ret
  end

  #todo database
  def add_todo(manga_name, volume_value, chapter_value, page_nb)
    manga_id = get_manga(manga_name)[0]
    todo = get_todo(manga_name)
    insert = [manga_id, volume_value, chapter_value, page_nb]
    if manga_name == nil || volume_value == nil || chapter_value == nil || page_nb == nil
      puts 'Error while trying to insert element in todo database => nil'
      p insert
      puts '(manga_name, volume, chapter, page)'
      exit 2
    end
    todo.each do |elem|
      elem.shift
      if elem == insert
        return false
      end
    end
    begin
      prep = @db.prepare "INSERT INTO manga_todo VALUES (NULL, #{manga_id}, ?, ?, ?)"
      prep.bind_param 1, volume_value
      prep.bind_param 2, chapter_value
      prep.bind_param 3, page_nb
      prep.execute
    rescue SQLite3::Exception => e
      db_error_exit('could not insert page into todo database', e)
    end
    true
  end

  def get_todo(manga_name)
    manga_id = get_manga(manga_name)[0]
    begin
      ret = @db.execute "SELECT * FROM manga_todo WHERE mangaId=#{manga_id}"
    rescue SQLite3::Exception => e
      db_error_exit('exception on database while getting todo of ' + manga_name, e)
    end
    ret
  end

  def delete_todo(id)
    begin
      @db.execute "DELETE FROM manga_todo WHERE Id = #{id}"
    rescue SQLite3::Exception => e
      db_error_exit('exception on database while deleting todo element', e)
    end
  end

  def clear_todo(manga_name)
    manga_id = get_manga(manga_name)[0]
    begin
      @db.execute "DELETE FROM manga_todo WHERE mangaId=#{manga_id}"
    rescue SQLite3::Exception => e
      db_error_exit("exception on database while deleting todo of #{manga_name}", e)
    end
  end

  #trace database
  def add_trace(manga_name, volume_value, chapter_value)
    manga_id = get_manga(manga_name)[0]
    trace = get_trace(manga_name)
    insert = [manga_id, volume_value, chapter_value]
    if manga_name == nil || volume_value == nil || chapter_value == nil
      puts 'Error while trying to insert element in trace database => nil'
      p insert
      puts '(manga_name, volume, chapter, page)'
      exit 2
    end
    found = false
    trace.each do |elem|
      elem.shift
      if elem == insert
        found = true
        break
      end
    end
    unless found
      begin
        prep = @db.prepare "INSERT INTO manga_trace VALUES (NULL, #{manga_id}, ?, ?)"
        prep.bind_param 1, volume_value
        prep.bind_param 2, chapter_value
        prep.execute
      rescue SQLite3::Exception => e
        db_error_exit('could not insert chapter into trace database', e)
      end
    end
  end
  
  def get_trace(manga_name)
    manga_id = get_manga(manga_name)[0]
    begin
      ret = @db.execute "SELECT * FROM manga_trace WHERE mangaId=#{manga_id}"
    rescue SQLite3::Exception => e
      db_error_exit("could not get trace database of #{manga_name}", e)
    end
    ret
  end

  def delete_trace(manga_name, chapter)
    manga_id = get_manga(manga_name)[0]
    begin
      @db.execute "DELETE FROM manga_trace WHERE mangaId=#{manga_id} AND volume=#{chapter[0]} and chapter=#{chapter[1]}"
      rescue SQLite3::Exception => e
      db_error_exit('could not erase element from trace database', e)
    end
  end

  #init database
  def initialize
    begin
      @db = SQLite3::Database.new Dir.home + '/.MangaScrap/db/manga.db'
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_list (
      Id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT, site TEXT,
      link TEXT, author TEXT, artist TEXT, type TEXT, status BOOL, genres TEXT,
      release INT, html_name TEXT, alternative_names NTEXT, rank INT, rating INT,
      rating_max INT)'
    rescue SQLite3::Exception => e
      db_error_exit('Exception occurred when opening / creating manga table', e)
    end
    begin
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_todo (
      Id INTEGER PRIMARY KEY, mangaId INTERGER, volume INTERGER, chapter DOUBLE,
      page INTEGER)'
    rescue SQLite3::Exception => e
      db_error_exit('exception occured while trying to open / create todo table', e)
    end
    begin
      @db.execute 'CREATE TABLE IF NOT EXISTS manga_trace (
      Id INTEGER PRIMARY KEY, mangaId INTERGER, volume INTERGER, chapter DOUBLE)'
    rescue SQLite3::Exception => e
      db_error_exit('exception occured while trying to open / create trace table', e)
    end
  end
end
