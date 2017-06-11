# only directly used by the Params class, must NOT be directly called elsewhere
# stores all of the instructions given to the scrapper
class Params_History
  def initialise
    unless Dir.exists?(Dir.home + '/.MangaScrap/db/')
      Utils_file::dir_create(Dir.home + '/.MangaScrap/db/')
    end
    @db = SQLite3::Database.new(Dir.home + '/.MangaScrap/db/data.db')
    @db.execute 'CREATE TABLE IF NOT EXISTS History_conf (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      enable VARCHAR(1),
      history_size INT)'
    @db.execute 'CREATE TABLE IF NOT EXISTS History (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      date VARCHAR(32),
      instruction TEXT)'
  end
end
