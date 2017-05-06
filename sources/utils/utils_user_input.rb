module Utils_user_input
  # mangas = array of Manga_Data
  def self.require_confirmation (message, mangas = nil)
    puts message
    if mangas != nil
      MangaScrap_API::output(mangas)
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
end
