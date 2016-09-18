def chapter_list_generator(db, template, traces, path_html)
  ret = ""
  buff = ""
  biggest = traces.map { |a| [a[2], 0].max }.max
  traces = traces.sort_by { |a| [(a[2] < 0) ? (biggest + a[2] * -1) * -1 : a[2] * -1, -a[3]] }
  traces.each do |chapter|
    if traces[5] != 0
      ret += "<li>\n"
      chapter_buff = (chapter[3] % 1 == 0) ? chapter[3].to_i.to_s : chapter[3].to_s
      volume_buff = volume_int_to_string(chapter[2], true)
      buff = '  <a href="' + chapter_filename(chapter, path_html) + '">' + volume_buff + " Chapter " + chapter_buff + "</a>\n"
      ret += buff
      ret += "</li>\n"
    else
      puts "ignoring volume #{chapter[2]} chapter #{chapter[3]} as it contains no pages ( redl ? )"
    end
  end
  template = template.gsub("#####list#####", ret)
  template = template.gsub("#####first#####", buff)
  return template
end

def html_a_buffer(data)
  tmp = data.split(", ")
  ret = tmp.map do |elem|
    buff = '<a href="#">' + elem + '</a>'
    elem = buff
  end
  return ret.join(", ")
end

def get_html_manga_name(name)
  ret = name.gsub("_", " ")
  ret = ret.slice(0,1).capitalize + ret.slice(1..-1)
  return ret
end

def chapter_filename(chapter, path_html, html = false)
  filename = "v" + vol_buffer_string(chapter[2]) + "c" + chap_buffer_string(chapter[3]) + ".html"
  return path_html + "/" + filename
end

def html_chapter_index(db, manga_data, params)
  puts "updating html of " + manga_data[1]
  dir = params[1] + manga_data[4].split("/")[2].split(".")[0];
  path_to_cover = dir + "/mangas/" + manga_data[1] + ".jpg"
  path_pictures = dir + "/mangas/" + manga_data[1] + "/"
  path_html = dir + "/html/" + manga_data[1]
  manganame = get_html_manga_name(manga_data[1])
  traces = db.get_trace(manga_data[1])  
  traces.each do |chap|
    chap << "<a href=\"" + chapter_filename(chap, path_html) + "\">#####elem#####</a>"
    chap << Dir.glob(file_name(path_pictures, chap[2], chap[3], -1, true)).size
  end
  dir_create(path_html)
  template = File.open(Dir.home + "/.MangaScrap/chapter_index_template.html")
  template = template.read
  template = template.gsub("#####name#####", manganame)
  template = template.gsub("#####description#####", description_manipulation(manga_data[2], 100).gsub("\n", "<br />"))
  template = template.gsub("#####site#####", manga_data[4])
  template = template.gsub("#####author#####", html_a_buffer(manga_data[5]))
  template = template.gsub("#####artist#####", html_a_buffer(manga_data[6]))
  template = template.gsub("#####status#####", html_a_buffer(manga_data[8]))
  template = template.gsub("#####genres#####", html_a_buffer(manga_data[9]))
  template = template.gsub("#####date#####", manga_data[10].to_s)
  template = template.gsub("#####cover#####", path_to_cover)
  template = chapter_list_generator(db, template, traces, path_html).gsub("#", "%23")
  File.open(path_html + ".html", "w") {|f| f.write(template)}
  html_generate_chapters(traces, manganame, path_pictures, path_html)
end
