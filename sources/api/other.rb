# this file contains all the methods that could not have their own file because there
# where too little of them
# html : html

module MangaScrap_API
  # ensures that the HTML class is correctly used to generate all the needed html
  # mangas = array of Manga_Data where status = true
  # should mangas be nil or empty, only the index will be updated
  def self.html_manager(mangas)
    html = HTML.new
    html.generate_index
    html.generate_updated
    if mangas != nil && mangas.size != 0
      mangas.each do |manga|
        html_manga = HTML_manga.new(manga, true)
        html_manga.generate_chapter_index
      end
    end
    puts 'done'
  end
end
