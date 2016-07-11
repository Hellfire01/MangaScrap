def confirm_delete (db, name)
    puts "going to delete #{name}"
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ""
    if (ret == "YES")
      db.delete_manga(name)
      puts "deleted #{name} from database"
    else
      puts "did not delete #{name}"
    end
end

def delete (db)
  if (ARGV.size < 2)
    puts "need a manga's name to delete"
  elsif (ARGV.size == 2)
    confirm_delete(db, ARGV[1])
  else
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
        confirm_delete(db, name[0])
      end
    else
      puts "error while trying to get content of file ( -f option )"
      exit 5
    end
  end
end
