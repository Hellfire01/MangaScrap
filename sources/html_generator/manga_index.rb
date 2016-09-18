def name_manipulation(name, line_size = 28)
  ret = ""
  name = name.gsub("_", " ")
  lock = true
  tmp_line = ""
  count = 0
  name.split(" ").each do |word|
    count += word.length
    if count > line_size
      tmp_line += "<br />"
      count = 0
    end
    if lock == true
      lock = false
    elsif count != 0
      tmp_line += " "
      count += 1
    end
    tmp_line += word
  end
  ret += tmp_line.strip()
  return ret
end

def html_get_data(db, params, dir)
  mangas = db.get_manga_list()
  ret = []
  mangas.sort.each do |manga|
    ret << "  <div class=\"manga\">"
    ret << "    <a href=\"" + dir + "html/" + manga[0] + ".html" + "\">"
    ret << "      <img src=\"" +  dir + "mangas/" + manga[0] + ".jpg" + "\">"
    ret << "      <p>" + name_manipulation(manga[0]) + "</p>"
    ret << "    </a>"
    ret << "  </div>"
  end
  return ret.join("\n")
end

# must be modified to allow multiple sites
def html_manga_index(db, params, write_css = false)
  puts "updating html of manga index"
  write_css_files(params)
  dir = params[1] + "mangafox/"
  template = File.open(Dir.home + "/.MangaScrap/manga_index_template.html").read
  template = template.gsub("#####list#####", html_get_data(db, params, dir))
  File.open(dir + "index.html", "w") {|f| f.write(template)}
end
