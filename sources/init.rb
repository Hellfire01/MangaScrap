def copy_templates(location)
  templates = Dir[location + "/templates/*"]
  templates.each do |template|
    # WARNING => check if file exists
    copy_file(template, Dir.home + "/.MangaScrap/" + template.split("/").last)
  end
end

def initialize_mangascrap(location)
  begin
    dir_create(Dir.home + "/.MangaScrap")
  rescue StandardError => error
    puts "could not create db folder ( " + Dir.home + "/.MangaScrap )"
    puts "error message is : '" + error.message + "'"
    exit 5
  end
  # this function should only be called when writing the templates
  copy_templates(location)
  db = DB.new()
  init_utils()
  return db
end
