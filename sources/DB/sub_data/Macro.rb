# only directly used by the Params class, must NOT be directly called elsewhere
# stores all of the macros the scrapper can execute
class Macro
  def initialise
    unless Dir.exists?(Dir.home + '/.MangaScrap/db/')
      Utils_file::dir_create(Dir.home + '/.MangaScrap/db/')
    end
    @db = SQLite3::Database.new(Dir.home + '/.MangaScrap/db/data.db')
    @db.execute 'CREATE TABLE IF NOT EXISTS Macros (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      date VARCHAR(32),
      macro TEXT)'
  end
end
