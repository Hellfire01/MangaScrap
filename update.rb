def update_manga_page(db, name, chap, page)

end

def update_manga_chap(db, name, chap)

end

def update_manga(db, name)

end

def update_all(db)
  
end

def update(db)
  case ARGV.size
  when 0, 1
    update_all(db)
  when 2
    update_manga(db, ARGV[2])
  when 3
    update_manga_chap(db, ARGV[2], ARGV[3])
  when 4
    update_manga_page(db, ARGV[2], ARGV[3], ARGV[4])
  else
    abort('too many arguments for update, --help for help')
  end
end
