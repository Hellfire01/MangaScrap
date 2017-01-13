def copy_dir_pictures(location, path_pictures, dir)
  path = path_pictures + dir
  dir_create(Dir.home + path)
  logos = Dir[location + '/pictures/' + dir + '/*']
  logos.each do |logo|
    # WARNING => check if files exists
    copy_file(logo, Dir.home + path + '/' + logo.split('/').last)
  end
end

def copy_pictures(location)
  path_pictures = '/.MangaScrap' + '/pictures'
  dir_create(Dir.home + path_pictures)
  copy_dir_pictures(location, path_pictures, '/logos')
  copy_dir_pictures(location, path_pictures, '/other')
end

def copy_templates(location)
  templates = Dir[location + '/templates/*']
  templates.each do |template|
    # WARNING => check if files exists
    copy_file(template, Dir.home + '/.MangaScrap/templates/' + template.split('/').last)
  end
end

def initialize_mangascrap(location)
  begin
    dir_create(Dir.home + '/.MangaScrap')
    dir_create(Dir.home + '/.MangaScrap/db')
    dir_create(Dir.home + '/.MangaScrap/templates')
    copy_templates(location)
    copy_pictures(location)
  rescue StandardError => error
    puts 'error while initializing MangaScrap'
    puts "error message is : '" + error.message + "'"
    exit 5
  end
  db = DB.new
  init_utils
  if Params.instance.get_params[11] == 'false'
    String.disable_colorization = true
  end
  db
end
