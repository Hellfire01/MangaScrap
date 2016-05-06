require 'sqlite3'

class DB
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

  def find_manga(manganame)
    begin
      ret = @db.execute "SELECT name FROM manga_list WHERE name='#{manganame}'"
    rescue SQLite3::Exception => e
      puts "exception on database while excecuting : "
      puts "SELECT name FROM manga_list WHERE name='#{manganame}'"
      abort(e.message)
    end
    return ret.map{|el| manganame}.include?(manganame)
  end

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
