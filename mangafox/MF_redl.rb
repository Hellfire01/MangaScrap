def MF_redl_volume(manganame, volume)
  dw = Download_MF(manganame)
  dw
end

def MF_redl_chapter(manganame, chapter, volume)
  dw = Download_MF(manganame)
  dw
end


def MF_redl_page(manganame, page, chapter, volume)
  puts ""
  disp =  "re-downloading " + manganame + " "
  if (volume == -2)
    disp += "volume VTB "
  elsif (volume >= 0)
    disp += "volume " + volume.to_i.to_s + " "
  end
  if (chapter % 1 == 0)
    disp += "chapter " + chapter.to_i.to_s + " "
  else
    disp += "chapter " + chapter.to_s + " "
  end
  disp += "page " + page.to_s
  puts disp
  dw = Download_MF(manganame)
  if (dw.page(volume, chapter, page) == false)
    puts "failed to download page"
    puts "this is due to either a connection problem or that the requested page does not exist"
    abort()
  else
    puts "done"
  end
end

def MF_redl(manganame)
  volume = nil
  chapter = nil
  page = nil

p ARGV
end
