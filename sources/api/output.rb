# This file contains only instructions that read from the database to write on the terminal
# manga related : output / details
# others : version / help

module MangaScrap_API
  # displays the name + site of the mangas ( used to create manga list files )
  # mangas = array of Manga_Data
  def self.output(mangas)
    mangas.sort{|a, b| a[:link] <=> b[:link]}.each do |manga|
      puts manga[:name] + ' ' + manga[:website][:link]
    end
  end

  # infos is used to get all the available information on the manga from the database
  # this includes traces and _todo
  # mangas = array of Manga_Data where status = true and in_db = true
  def self.details(mangas)
    database = Manga_database.instance
    mangas.sort{|a, b| a[:link] <=> b[:link]}.each do |manga|
      puts 'Details for : ' + manga[:name].yellow
      puts ''
      puts 'Web :'.yellow
      puts 'HTML name   : ' + manga[:data][11]
      puts 'Site        : ' + manga[:website][:link]
      puts 'Link        : ' + manga[:link]
      puts 'Database id : ' + manga[:id].to_s
      puts 'Author      : ' + manga[:data][5]
      puts 'Artist      : ' + manga[:data][6]
      puts 'Type        : ' + manga[:data][7]
      puts 'Status      : ' + manga[:data][8]
      puts 'Genres      : ' + manga[:data][9]
      puts 'Year        : ' + manga[:data][10].to_s
      puts 'Traces :'.yellow
      puts 'downloaded chapters : '
      traces = database.get_trace(manga)
      puts 'volumes  : ' + traces.map{|e| e[2]}.uniq.size.to_s
      puts 'chapters : ' + traces.size.to_s
      pages = traces.map{|e| e[5]}
      if pages.include? nil
        puts 'Error : '.red + 'at least one chapter has no page count value in the database, please use the ' + 'data-check'.green + ' instruction to correct this'
      else
        puts 'pages    : ' + pages.reduce(:+).to_s
      end
      puts 'Todo :'.yellow
      todo = database.get_todo(manga)
      if todo.size == 0
        puts 'there are no todo to download'
      else
        puts "There is a total of #{todo.size} todo elements to download witch includes :"
        buff = todo.map{|e| e[:page] == -1}
        puts "#{buff.size} entire chapter#{buff.size == 1 ? '' : 's'}" if buff.size != 0
        puts "#{todo.size - buff.size} independent page#{todo.size - buff.size == 1 ? '' : 's'}" if todo.size - buff.size != 0
      end
      puts "\n"
    end
  end

  # just displays the version of MangaScrap witch is contained in a file
  def self.version
    begin
      file = File.new(__dir__ + '/../templates/text/version.txt', 'r')
      line = file.gets
      file.close
    rescue => err
      puts 'Error : '.red + 'could not open version.txt file'
      puts err.message
      err
    end
    puts 'MangaScrap version : ' + line
  end

  # displays the help after reading it from a file and colorizing it ( if the option is enabled )
  def self.help
    begin
      file = File.open('sources/templates/text/help.txt', 'r')
      content = file.read
      content = content.gsub('_todo', 'todo')
      instructions = %w(link id file query all add update fast-update download redl re-download p c v param version help list output delete delete-db details html todo clear todo reset set data managed)
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
end
