# gets the value of the page / chapter / volume
def value_extract(elem)
  if elem[0] != 'v' && elem[0] != 'c' && elem[0] != 'p'
    return nil
  end
  chapter = (elem[0] == 'c') ? true : false
  elem[0] = ''
  if chapter == true
    elem = elem.to_f
    elem /= 10
  else
    elem = elem.to_i
  end
  return elem
end

# from a page name returns an array with the values or the file name ( if it is not a manga page )
def extract_page_data(file_name)
  ret = Array.new
  data = file_name[/[^.]+/].split("_").reject{|elem| elem == "v"}.reject{|elem| elem == ""} # cleaning array
  if data.first != "manga" || data.size != 4
    puts "error on file " + file_name + " it does not seem to be a manga page generated by Mangascrap"
    return file_name
  end
  data.shift
  case data.first
  when "####"
    tmp1 = -1
  when "TBD"
    tmp1 = -2
  when "NA"
    tmp1 = -3
  when "ANT"
    tmp1 = -4
  else
    tmp1 = value_extract(data.first)
  end
  if tmp1 == nil || (tmp2 = value_extract(data[1])) == nil || (tmp3 = value_extract(data[2])) == nil
    puts "error of " + file_name + " it does not seem to be a file generated by Mangascrap"
    p data
    return file_name
  end
  ret << tmp1 << tmp2 << tmp3
  return ret
end

# get all file names from a directory and extract the values
def scan_dir(dir, db, name)
  Dir.chdir dir
  ls = Dir["*"]
  if ls == nil
    puts "could not find any files in the " + File.expand_path(dir) + " directory"
    exit 5
  end
  ls.sort_by!{|elem| elem}
  data = Array.new
  ls.each do |page|
    if (page == "cover.jpg" || page == "description.txt")
      next
    end
    data << extract_page_data(page)
  end
  return data
end