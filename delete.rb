def delete (db)
  if (ARGV.size < 2)
    puts "need a manga's name to delete"
  elsif (ARGV.size == 2)
    db.delete_manga(ARGV[1])
    puts "deleted #{ARGV[1]} from database"
  else
    ret = get_mangas()
    if (ret != nil)
      ret.each do |name|
	db.delete_manga(name[0])
	puts "deleted #{name[0]} from database"
      end
    else
      abort("error while trying to get content of file ( -t option )")
    end
  end
end
