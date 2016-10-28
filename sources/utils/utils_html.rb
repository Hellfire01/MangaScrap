# used to separate the different genres, authors and artists into separate <a>
def html_a_buffer(data)
  tmp = data.split(", ")
  ret = tmp.map do |elem|
    buff = '<a href="#">' + elem + '</a>' #href needs to be changed when the genres will have the html generated
    elem = buff
  end
  return ret.join(", ")
end

# gets the html filename of the chapter ( works nearly the same way as the jpg names )
def html_chapter_filename(chapter, local = false)
  filename = "v" + vol_buffer_string(chapter[2]) + "c" + chap_buffer_string(chapter[3]) + ".html"
  if local == false
    return "/" + filename
  else
    return "./" + @manga_data[1] + "/" + filename
  end
end

