class DB
  #manga database
  def add_manga(manganame, description, site, link, nb_chapters)
    begin
      prep = @db.prepare "INSERT INTO manga_list VALUES (NULL, ?, ?, ?, ?, #{nb_chapters}, 0)"
      prep.bind_param 1, manganame
      prep.bind_param 2, description
      prep.bind_param 3, site
      prep.bind_param 4, link
      prep.execute
    rescue SQLite3::Exception => e
      puts "Exception while inserting element into database"
      puts "executing : INSERT INTO manga_list VALUES (NULL, '#{manganame}', '#{description}', '#{site}', '#{link}', #{nb_chapters}, 0)"
      abort ("message is : '" + e.message + "'")
    end
    begin
      @db.execute "CREATE TABLE IF NOT EXISTS manga_todo_#{manganame} (Id INTEGER PRIMARY KEY, chapter DOUBLE, page INTEGER)"
    rescue SQLite3::Exception => e
      puts "exception occured while trying to create todo table"
      puts "executing : CREATE TABLE IF NOT EXISTS manga_todo_#{manganame} (Id INTEGER PRIMARY KEY, chapter DOUBLE, page INTEGER)"
      abort ("message is : '" + e.message + "'")  
    end
    begin
      @db.execute "CREATE TABLE IF NOT EXISTS manga_trace_#{manganame} (Id INTEGER PRIMARY KEY, chapter DOUBLE)"
    rescue SQLite3::Exception => e
      puts "exception occured while trying to create trace table"
      puts "executing : CREATE TABLE IF NOT EXISTS manga_trace_#{manganame} (Id INTEGER PRIMARY KEY, chapter DOUBLE)"
      abort ("message is : '" + e.message + "'")  
    end
  end

  def delete_manga(manganame)
    begin
      @db.execute "DELETE FROM manga_list WHERE name = #{manganame}"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "DELETE FROM manga_list WHERE name = #{manganame}"
      abort(e.message)
    end
    begin
      @db.execute "DROP TABLE manga_todo_#{manganame}"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "DROP TABLE manga_todo_#{manganame}"
      abort(e.message)
    end
    begin
      @db.execute "DROP TABLE manga_trace_#{manganame}"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "DROP TABLE manga_trace_#{manganame}"
      abort(e.message)
    end
  end

  def get_manga(manganame)
    begin
      ret = @db.execute "SELECT * FROM manga_list WHERE name='#{manganame}'"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "SELECT name FROM manga_list WHERE name='#{manganame}'"
      abort(e.message)
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
      abort(e.message)
    end
    return ret
  end

  #todo database
  def add_todo(manganame, chapter_value, page_nb)
    begin
      prep = @db.prepare "INSERT INTO manga_todo_#{manganame} VALUES (NULL, ?, ?)"
      prep.bind_param 1, chapter_value
      prep.bind_param 2, page_nb
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not insert page into todo database"
      abort (e.message)
    end
  end

  def get_todo(manganame)
    begin
      ret = @db.execute "SELECT * FROM manga_todo_#{manganame}"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "SELECT * FROM manga_todo_#{manganame}"
      abort(e.message)
    end
    return ret
  end

  def delete_todo(manganame, id)
    begin
      @db.execute "DELETE FROM manga_todo_#{manganame} WHERE Id = #{id}"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "SELECT * FROM manga_todo_#{manganame}"
      abort(e.message)
    end
  end

  #trace database
  def add_trace(manga_name, chapter_value)
    begin
      prep = @db.prepare "INSERT INTO manga_trace_#{manga_name} VALUES (NULL, ?)"
      prep.bind_param 1, chapter_value
      prep.execute
    rescue SQLite3::Exception => e
      puts "could not insert chapter into trace database"
      abort (e.message)
    end
  end
  
  def get_trace(manga_name)
    begin
      ret = @db.execute "SELECT * FROM manga_trace_#{manga_name}"
    rescue SQLite3::Exception => e
      puts "could not get trace database"
      abort (e.message)
    end
    return ret
  end

  #init database
  def initialize()
    begin
      @db = SQLite3::Database.new "manga"
      @db.execute "CREATE TABLE IF NOT EXISTS manga_list(
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      site TEXT,
      link TEXT,
      chapters INT,
      downloaded_chapters INT)"
    rescue SQLite3::Exception => e
      puts "Exception occurred when opening DataBase"
      abort(e.message)
    end
  end
end
