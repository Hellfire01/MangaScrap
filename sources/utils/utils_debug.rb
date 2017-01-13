# this is used to dump the content of a manga_data ( DB.get_manga(manganame) ) in the term
def dump_manga_data(manga_data)
  i = 0
  manga_data.each do |elem|
    puts i.to_s + ((i < 10) ? '  ' : ' ') + elem.to_s
    i += 1
  end
end
