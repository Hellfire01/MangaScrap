def confirm_delete (db, name)
    puts "going to delete #{name}"
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ""
    if (ret == "YES")
      db.delete_manga(name)
      puts "deleted #{name} from database"
      return true
    else
      puts "did not delete #{name}"
      return false
    end
end

def delete (db)
  html = HTML.new(db)
  if (ARGV.size < 2)
    puts "need a manga's name to delete"
  elsif (ARGV.size == 2)
    if confirm_delete(db, ARGV[1]) == true
      #todo => supprimer les fichiers html devenus inutiles
      html.generate_index()
    end
  else
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        if confirm_delete(db, ARGV[1]) == true
          #todo => supprimer les fichiers html devenus inutiles
          html.generate_index()
        end
      end
    else
      puts "error while trying to get content of file ( -f option )"
      exit 5
    end
  end
end
