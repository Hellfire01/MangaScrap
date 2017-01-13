# used to separate the different genres, authors and artists into separate <a>
def html_a_buffer(data)
  tmp = data.split(', ')
  ret = tmp.map do |elem|
    #todo : href needs to be changed when the genres will have the html generated
    '<a href="#">' + elem + '</a>'
  end
  ret.join(', ')
end

# gets the html filename of the chapter ( works nearly the same way as the jpg names )
def html_chapter_filename(chapter, volume)
  '/v' + vol_buffer_string(volume) + 'c' + chap_buffer_string(chapter) + '.html'
end
