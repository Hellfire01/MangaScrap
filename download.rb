# get file name
def file_name(dir, vol_value, chap_value, page_nb)
  chap_str = chap_value.to_s
  val = chap_str.index('.')
  if (val != nil)
    chap_str[val] = ''
  else
    chap_str += '0'
  end
  vol_buffer = ((vol_value > 1000) ? "0" : ((vol_value > 100) ? "00" : ((vol_value > 10) ? "000" : "0000")))
  chap_buffer = ((chap_value > 1000) ? "0" : ((chap_value > 100) ? "00" : ((chap_value > 10) ? "000" : "0000")))
  page_buffer = ((page_nb > 1000) ? "0" : ((page_nb > 100) ? "00" : ((page_nb > 10) ? "000" : "0000")))
  name_buffer = dir + "manga_v" + vol_buffer + vol_value.to_s + "_c" + chap_buffer + chap_str + "_p" + page_buffer + page_nb.to_s
  return name_buffer
end

def chap_link_corrector(links)
  links.each do |chapter|
    chap_cut = chapter.split("/")
    if chap_cut[chap_cut.size - 1] != "1.html"
      chapter += "1.html"
    end
  end
end

def download(db)
  if (ARGV.size == 1)
    puts "missing argument : --help for more information"
  else
    site = "http://mangafox.me/manga/"
    file = false
    if (ARGV.size > 2)
      ret = get_mangas()
      if (ret != nil)
	file = true
      else
	site = ARGV[2].to_s
      end
    end
    if (file == false)
      name = ARGV[1].to_s
      if (db.manga_in_data?(name) == true)
	puts "manga was found in database, updating it"
	update(db)
      else
	dl = Download.new(db, name, site)
	dl.manga()
      end
    else
      ret.each do |manga|
	if (name.size == 1)
	  site = "http://mangafox.me/manga/"
	else
	  site == manga[1]
	end
	if (db.manga_in_data?(manga) == true)
	  puts "manga was found in database, updating it"
	  update(db)
	else
	  dl = Download.new(db, manga, site)
	  dl.manga()
	end
      end
    end
  end
end
