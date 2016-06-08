class DB
  #manga database
  def add_manga(manganame, description, site, link, author, artist, type, status, genres, release)
    begin
      prep = @db.prepare "INSERT INTO manga_list VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
      prep.bind_param 1, manganame
      prep.bind_param 2, description
      prep.bind_param 3, site
      prep.bind_param 4, link
      prep.bind_param 5, author
      prep.bind_param 6, artist
      prep.bind_param 7, type
      prep.bind_param 8, status
      prep.bind_param 9, genres.join(", ")
      prep.bind_param 10, release
      prep.execute
    rescue SQLite3::Exception => e
      puts "Exception while adding manga to database"
      abort ("message is : '" + e.message + "'")
    end
  end

  def update_manga(manganame, description)
    begin
      prep = @db.prepare "UPDATE manga_list SET description=? WHERE name=?"
      prep.bind_param 1, description
      prep.bind_param 2, manganame
      prep.execute
    rescue SQLite3::Exception => e
      puts "Error while trying to update data of #{manganame}"
      abort("message is : '" + e.message + "'")
    end
  end

  def delete_manga(manganame)
    mangaid = get_manga(manganame)[0]
    begin
      @db.execute "DELETE FROM manga_list WHERE name = '#{manganame}'"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "DELETE FROM manga_list WHERE name = #{manganame}"
      abort("message is : '" + e.message + "'")
    end
    begin
      @db.execute "DELETE FROM manga_todo WHERE mangaId=#{mangaid}"
    rescue SQLite3::Exception => e
      puts "exception on database while deleting todo of " + manganame
      abort("message is : '" + e.message + "'")
    end
    begin
      @db.execute "DELETE FROM manga_trace WHERE mangaId=#{mangaid}"
    rescue SQLite3::Exception => e
      puts "exception on database while deleting trace of " + manganame
      abort("message is : '" + e.message + "'")
    end
  end

  def get_manga(manganame)
    if manganame == nil
      abort("error while trying to get manga => name is nil")
    end
    begin
      ret = @db.execute "SELECT * FROM manga_list WHERE name='#{manganame}'"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "SELECT name FROM manga_list WHERE name='#{manganame}'"
      abort("message is : '" + e.message + "'")
    end
    return ret[0]
  end

  def manga_in_data?(manganame)
    manga = get_manga(manganame)
    if (manga == nil)
      return false
    end
    return true
  end

  def get_manga_list()
    begin
      ret = @db.execute "SELECT name FROM manga_list ORDER BY name COLLATE NOCASE"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "SELECT name FROM manga_list ORDER BY name COLLATE NOCASE"
      abort("message is : '" + e.message + "'")
    end
    return ret
  end

  #todo database
  def add_todo(manganame, volume_value, chapter_value, page_nb)
    mangaId = get_manga(manganame)[0]
    todo = get_todo(manganame)
    insert = [mangaId, volume_value, chapter_value, page_nb]
    if manganame == nil || volume_value == nil || chapter_value == nil || page_nb == nil
      puts "Error while trying to insert element in todo database => nil"
      p insert
      puts "(manganame, volume, chapter, page)"
      abort("")
    end
    todo.each() do |elem|
      elem.shift
      if elem == insert
        puts "manga #{manganame}, volume #{volume_value}, chapter #{chapter_value}, page #{page_nb} is already in todo database"
        return false
      end
    end
    begin
      prep = @db.prepare "INSERT INTO manga_todo VALUES (NULL, #{mangaId}, ?, ?, ?)"
      prep.bind_param 1, volume_value
      prep.bind_param 2, chapter_value
      prep.bind_param 3, page_nb
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not insert page into todo database"
      abort("message is : '" + e.message + "'")
    end
    return true
  end

  def get_todo(manganame)
    mangaId = get_manga(manganame)[0]
    begin
      ret = @db.execute "SELECT * FROM manga_todo WHERE mangaId=#{mangaId}"
    rescue SQLite3::Exception => e
      puts "exception on database while getting todo of " + manganame
      abort("message is : '" + e.message + "'")
    end
    return ret
  end

  def delete_todo(id)
    begin
      @db.execute "DELETE FROM manga_todo WHERE Id = #{id}"
    rescue SQLite3::Exception => e
      puts "exception on database while deleting todo element"
      abort("message is : '" + e.message + "'")
    end
  end

  def clear_todo(manganame)
    mangaId = get_manga(manganame)[0]
    begin
      @db.execute "DELETE FROM manga_todo WHERE mangaId=#{mangaId}"
    rescue SQLite3::Exception => e
      puts "exception on database while deleting todo of #{manganame}"
      abort("message is : '" + e.message + "'")
    end
  end

  #trace database
  def add_trace(manganame, volume_value, chapter_value)
    mangaId = get_manga(manganame)[0]
    begin
      prep = @db.prepare "INSERT INTO manga_trace VALUES (NULL, #{mangaId}, ?, ?)"
      prep.bind_param 1, volume_value
      prep.bind_param 2, chapter_value
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not insert chapter into trace database"
      abort("message is : '" + e.message + "'")
    end
  end
  
  def get_trace(manganame)
    mangaId = get_manga(manganame)[0]
    begin
      ret = @db.execute "SELECT * FROM manga_trace WHERE mangaId=#{mangaId}"
    rescue SQLite3::Exception => e
      puts "could not get trace database of #{manganame}"
      abort("message is : '" + e.message + "'")
    end
    return ret
  end

  #init database
  def initialize()
    begin
      @db = SQLite3::Database.new "DB/manga.db"
      @db.execute "CREATE TABLE IF NOT EXISTS manga_list (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      site TEXT,
      link TEXT,
      author TEXT,
      artist TEXT,
      type TEXT,
      status BOOL,
      genres TEXT,
      release INT)"
    rescue SQLite3::Exception => e
      puts "Exception occurred when opening / creating manga table"
      abort ("message is : '" + e.message + "'")  
    end
    begin
      @db.execute "CREATE TABLE IF NOT EXISTS manga_todo (
      Id INTEGER PRIMARY KEY,
      mangaId INTERGER,
      volume INTERGER,
      chapter DOUBLE,
      page INTEGER)"
    rescue SQLite3::Exception => e
      puts "exception occured while trying to open / create todo table"
      abort ("message is : '" + e.message + "'")  
    end
    begin
      @db.execute "CREATE TABLE IF NOT EXISTS manga_trace (
      Id INTEGER PRIMARY KEY,
      mangaId INTERGER,
      volume INTERGER,
      chapter DOUBLE)"
    rescue SQLite3::Exception => e
      puts "exception occured while trying to open / create trace table"
      abort ("message is : '" + e.message + "'")  
    end
  end
end