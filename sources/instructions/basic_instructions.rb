# whenever a user confirmation is required, this function is called
def require_confirmation (message, manga_list = nil)
  puts message
  if manga_list != nil
    output(manga_list)
    puts ''
  end
  puts "Write 'YES' to continue"
  ret = STDIN.gets.chomp
  puts ''
  if ret == 'YES' || ret == 'Yes' || ret == 'yes'
    true
  else
    false
  end
end

# adds all mangas to the database
def add(mangas, generate_chapters = false)
  puts 'adding ' + mangas.size.to_s + ' element(s) to database'
  html = HTML.new
  mangas.each do |manga|
    dw = manga.get_download_class
    if dw == nil
      next
    end
    if generate_chapters
      html.generate_chapter_index(manga, false)
    end
  end
  html.generate_index
  puts 'done'
end

# updates all mangas by calling the right classes
# should todo_only = true, the function missing_chapters will be called instead of
#     update ( witch also calls missing_chapters )
def update(mangas, todo_only = false)
  puts 'updating ' + mangas.size.to_s + ' element(s)'
  html = HTML.new
  params = Params.instance.get_params
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
  puts 'done'
end

# basically just adds all mangas before updating them all
# also re-filters the mangas to ensure that there are no errors
def download(mangas)
  add(mangas)
  puts ''
  filter = Manga_data_filter.new(mangas)
  mangas_prepared = filter.run(false, true)
  update(mangas_prepared)
end

# ensures that the HTML class is correctly used to generate all the needed html
def html_manager(mangas)
  html = HTML.new
  mangas.each do |manga|
    html.generate_chapter_index(manga, true)
  end
  html.generate_index
  puts 'done'
end

# just displays the version of MangaScrap witch is contained in a file
def version
  begin
    file = File.new(__dir__ + '/../../utils/version.txt', 'r')
    line = file.gets
    file.close
  rescue => err
    puts 'Error : '.red + 'could not open version file'
    puts err.message
    err
  end
  puts 'MangaScrap version : ' + line
end

# displays the name + site of the mangas ( used to create manga list files )
def output(manga_list)
  manga_list.sort{|a, b| a.link <=> b.link}.each do |manga|
    puts manga.name + ' ' + manga.site
  end
end

# infos is used to get all the available information on the ùanga from the database
# this includes traces and _todo
def infos(manga_list)
  # todo infos
  puts 'currently a placeholder'
  pp manga_list
#  manga_list.sort{|a, b| a.link <=> b.link}.each do |manga|
#  end
end

# delete all _todo elements from the manga list
def clear(manga_list)
  if require_confirmation('you are about to ' + 'delete'.red + ' all todo elements of the following element(s) :', manga_list)
    db = Manga_database.instance
    manga_list.each do |manga|
      db.clear_todo(manga)
    end
    puts 'deleted all todo elements'
  else
    puts 'did not delete anything'
  end
end

# deletes all the mangas of the list from the database
# should delete_files be set at true, the files will also be deleted
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

# displays the help after colorizing it
def help
  begin
    file = File.open('utils/help.txt', 'r')
    content = file.read
    content = content.gsub('_todo', 'todo')
    instructions = %w(link id file query all add update download redl param version help list output delete delete-db html todo clear infos todo reset set)
    instructions.each do |instruction|
      content = content.gsub('[' + instruction + ']g', instruction.green).gsub('[' + instruction + ']y', instruction.yellow)
    end
    content = content.gsub('INSTRUCTIONS', 'INSTRUCTIONS'.red)
    content = content.gsub('EXAMPLES', 'EXAMPLES'.red)
    content = content.gsub('DESCRIPTION', 'DESCRIPTION'.red)
    content = content.gsub('Warning !', 'Warning !'.red)
    content = content.gsub('NOT', 'NOT'.red)
    content = content.gsub('note :', 'note :'.magenta)
    content = content.gsub('definition :', 'definition :'.magenta)
    content = content.gsub('definitions :', 'definitions :'.magenta)
    content = content.gsub('[data arguments compatible]', '[data arguments compatible]'.blue)
    content = content.gsub('[own arguments]', '[own arguments]'.blue)
    content = content.gsub('[in database]', '[in database]'.blue)
    content = content.gsub('[not in database]', '[not in database]'.blue)
    content = content.gsub('[elements required]', '[elements required]'.blue)
    content = content.gsub('[data argument]', '[data argument]'.blue)
    content = content.gsub('[data arguments]', '[data arguments]'.blue)
    puts content
  rescue Errno::ENOENT => e
    puts 'could not open help file'
    puts e.message
  end
end
