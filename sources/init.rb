#anything that needs to be done before the rest of MangaScrap is executed is placed here
def initialize_mangascrap
  Struct.new('Arg', :name, :sub_args, :nb_args, :does_not_need_args?)
  Struct.new('Sub_arg', :name, :nb_args)
  Struct.new('Updated', :name, :downloaded)
  Struct.new('Query_arg', :name, :arg_type, :sql_column, :sub_string)
  Struct.new('HTML_data', :volume, :chapter, :date, :href, :nb_pages, :file_name)
  begin
    dir_create(Dir.home + '/.MangaScrap/db')
  rescue StandardError => error
    puts 'error while initializing MangaScrap'
    puts "error message is : '" + error.message + "'"
    exit 5
  end
  init_utils
  if Params.instance.get_params[11] == 'false'
    String.disable_colorization = true
  end
end
