# used to separate the different genres, authors and artists into separate <a>
def html_a_buffer(data)
  tmp = data.split(", ")
  ret = tmp.map do |elem|
    buff = '<a href="#">' + elem + '</a>' #href needs to be changed when the genres will have the html generated
    elem = buff
  end
  return ret.join(", ")
end
