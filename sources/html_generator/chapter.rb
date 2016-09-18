def get_pictures_of_chapter(path_pictures, chapter)
  ret = []
  Dir.glob(file_name(path_pictures, chapter[2], chapter[3], -1, true)).sort.each do |file|
    ret << "<div class=\"frame\">\n"
    ret << "    <span class=\"hellper\"></span><img src=\"#{file}\">\n"
    ret << "\<div>\n"
  end
  return ret.join
end

def html_chapter(arr, manganame, path_pictures, path_html)  
  template = File.open(Dir.home + "/.MangaScrap/chapter_template.html").read
  template = template.gsub("#####index#####", path_html + ".html")
  template = template.gsub("#####name#####", manganame)
  template = template.gsub("#####prev#####", (arr[0] != nil) ? arr[0][4].gsub("#####elem#####", "prev") : "")
  template = template.gsub("#####next#####", (arr[2] != nil) ? arr[2][4].gsub("#####elem#####", "next") : "")
  template = template.gsub("#####pictures#####", get_pictures_of_chapter(path_pictures, arr[1])).gsub("#", "%23")
  File.open(chapter_filename(arr[1], path_html), "w") {|f| f.write(template) }
end

def html_generate_chapters_size1(traces, manganame, path_pictures, path_html)
  arr = [nil, traces[0], nil]
  html_chapter(arr, manganame, path_pictures, path_html)
end

def html_generate_chapters(traces, manganame, path_pictures, path_html)
  traces = traces.reject{|chapter| chapter[5] == 0}
  if traces.size > 0
    if traces.size == 1
      html_generate_chapters_size1(traces, manganame, path_pictures, path_html)
    else
      arr = [nil, traces[0], traces[1]]
      html_chapter(arr, manganame, path_pictures, path_html)
      traces.each_cons(3) do |prev, current, nxt|
        arr = [prev, current, nxt]
        html_chapter(arr, manganame, path_pictures, path_html)
      end
      arr = [traces[traces.size - 2], traces[traces.size - 1], nil]
      html_chapter(arr, manganame, path_pictures, path_html)
    end
  else
    puts "could not generate html => no chapters in trace database"
  end
end
