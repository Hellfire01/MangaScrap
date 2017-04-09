# this file contains all the methods that could not have their own file because there
# where too little of them
# html : html

# ensures that the HTML class is correctly used to generate all the needed html
# mangas = array of Manga_Data where status = true
# should mangas be nil or empty, only the index will be updated
def html_manager(mangas)
  html = HTML.new
  if mangas != nil && mangas.size != 0
    mangas.each do |manga|
      html.generate_chapter_index(manga, true)
    end
  end
  html.generate_index
  html.generate_updated
  puts 'done'
end
