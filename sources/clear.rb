def confirm_clear (db, name)
    puts "going to delete #{name}'s todo database elements"
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ""
    if (ret == "YES")
      db.clear_todo(name)
      puts "deleted #{name}'s todo from database"
    else
      puts "did not delete #{name}"
    end
end

def clear (db)
  if (ARGV.size < 2)
    puts "need a manga's name to delete"
  elsif (ARGV.size == 2)
    confirm_clear(db, ARGV[1])
  else
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        confirm_clear(db, name[0])
      end
    else
      puts "error while trying to get content of file ( -f option )"
      exit 5
    end
  end
end
