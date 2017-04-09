# This file contains all the instructions that alter the manga database
# add / update / download / delete / clear / todo

# whenever a user confirmation is required, this function is called
# message = message that is displayed
# mangas = array of Manga_Data
def require_confirmation (message, mangas = nil)
  puts message
  if mangas != nil
    output(mangas)
    puts ''
  end
  puts "Write 'YES' to continue"
  ret = STDIN.gets.chomp
  puts ''
  if ret == 'YES' || ret == 'Yes' || ret == 'yes' || ret == 'Y' || ret == 'y'
    true
  else
    false
  end
end

# adds all the mangas to the database
# mangas = array of Manga_Data where status = true && in_db = false
# generate_html = bool indicating if Y/N must generate the html of the mangas
def add(mangas, generate_html = false)
  puts 'adding ' + mangas.size.to_s + ' element(s) to database'
  html = HTML.new
  mangas.each do |manga|
    dw = manga.get_download_class
    if dw == nil
      next
    end
    if generate_html
      html.generate_chapter_index(manga, false)
    end
  end
  html.generate_index if generate_html
  puts 'done'
end

# updates all mangas
# mangas = array of Manga_Data where status = true && in_db = true
# todo_only = bool, if true, only the _todo pages / chapters are downloaded
# fast_update = bool, if true, the update function will ignore all mangas with the 'Completed' status
def update(mangas, todo_only = false, fast_update = false)
  html = HTML.new
  params = Params.instance.get_params
  if fast_update
    mangas = mangas.reject{|manga| manga.data[8] == 'Completed'}
  end
  puts 'updating ' + mangas.size.to_s + ' element(s)'
  mangas.each do |manga|
    dw = manga.get_download_class
    if dw == nil
      next
    end
    if todo_only
      generate_html = dw.todo
    else
      generate_html = dw.update
    end
    if params[6] == 'true'
      generate_html = (delete_diff(dw.get_links, manga) || generate_html)
    end
    html.generate_chapter_index(manga) if generate_html
  end
  html.generate_index
  html.generate_updated
  puts 'done'
end

# adds and then updates all mangas
# mangas = array of Manga_Data where status = true && in_db = false
def download(mangas)
  add(mangas)
  puts ''
  filter = Manga_data_filter.new(mangas)
  mangas_prepared = filter.run(false, true)
  update(mangas_prepared)
end

# downloads the cover and description of every element and re-generates the html
# mangas = array of Manga_Data where status = true && in_db = true
def data(mangas)
  puts 'downloading data of ' + mangas.size.to_s + ' element(s)'
  html = HTML.new
  mangas.each do |manga|
    dw = manga.get_download_class
    if dw == nil
      next
    end
    dw.data
    html.generate_chapter_index(manga, false)
  end
  html.generate_index
  puts 'done'
end

# delete all _todo elements from the manga list
# mangas = array of Manga_Data where status = true && in_db = true
def clear(mangas)
  if require_confirmation('you are about to ' + 'delete'.red + ' all todo elements of the following element(s) :', manga_list)
    db = Manga_database.instance
    mangas.each do |manga|
      db.clear_todo(manga)
    end
    puts 'deleted all todo elements'
  else
    puts 'did not delete anything'
  end
end

# deletes all the mangas of the list from the database
# mangas = array of Manga_Data where status = true && in_db = true
# delete_files = bool, if true, the files of the manga will also be deleted
def delete(manga_list, delete_files = true)
  if require_confirmation('you are about to ' + 'delete'.red + ' the following element(s) from the database' + ((delete_files) ?
    ' and '.yellow + 'all of the downloaded pages' :
    ' but ' + 'not'.yellow + ' the downloaded files' ), manga_list)
    db = Manga_database.instance
    path = Params.instance.get_params[1]
    manga_list.each do |manga|
      db.delete_manga(manga)
      if delete_files
        site_dir = get_dir_from_site(manga.site)
        delete_files(path + site_dir + 'html/' + manga.name, '.html')
        delete_files(path + site_dir + 'mangas/' + manga.name, '.jpg')
      end
    end
    puts 'deleted all elements'
    HTML.new.generate_index
  else
    puts 'did not delete anything'
  end
end
