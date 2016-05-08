def list(db)
  if (ARGV.size == 1)
    list = db.get_manga_list()
    list.each do |elem|
      puts elem[1]
      # mettre nombre de chapitres téléchargés et infos supp
    end
  else
    #lits mangas in site
  end
end
