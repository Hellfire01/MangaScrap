#anything that needs to be done before the rest of MangaScrap is executed is placed here

class Init
  def self.get_gem_list
    %w(singleton
  open-uri
  pp
  colorize
  nokogiri
  sqlite3
  typhoeus)
  end

  def self.get_file_list
    %w(scan/scan
  scan/scan_utils
  api/mangas
  api/other
  api/output
  api/params
  instructions/delete_diff
  instructions/redl
  utils/utils_file
  utils/utils_errors
  utils/utils_co
  utils/utils_db
  utils/utils_html
  utils/utils_debug
  utils/utils_user_input
  utils/website_specific/mangafox_utils
  utils/website_specific/mangareader_mangapanda_utils
  html/html
  html/html_manga
  Download/base_downloader
  Download/mangafox
  Download/mangareader_mangapanda
  DownloadDisplay
  instructions/Parsers/Instruction_parser
  instructions/Parsers/Data_parser
  instructions/Parsers/Query_Parser
  instructions/Parsers/File_parser
  instructions/query
  instructions/Instructions_exec
  instructions/Manga_data_filter
  DB/sub_data/data_module
  DB/sub_data/History
  DB/sub_data/Macro
  DB/sub_params/params_module
  DB/sub_params/HTML
  DB/sub_params/Download
  DB/sub_params/Misc
  DB/sub_params/Threads
  DB/Params
  DB/Manga_data
  DB/Manga_database)
  end

  def self.load_gem(gem)
    begin
      require gem
    rescue Exception => e
      puts ''
      puts "exception while trying to load #{gem}, please follow the installation instructions in the install directory"
      puts 'message is : ' + e.message
      puts ''
      puts 'please note that a ruby update may require a re-download of the gems'.yellow
      puts ''
      exit 1
    end
  end

  def self.load_all_gems
    get_gem_list.each do |gem|
      load_gem gem
    end
  end

  def self.load_relative_files
    get_file_list.each do |file|
      require_relative file
    end
  end

  def self.initialize_mangascrap
    load_all_gems
    load_relative_files
    Struct.new('Arg', :name, :sub_args, :nb_args, :does_not_need_args?)
    Struct.new('Sub_arg', :name, :nb_args)
    Struct.new('Updated', :name, :downloaded)
    Struct.new('Query_arg', :name, :arg_type, :sql_column, :sub_string)
    Struct.new('HTML_data', :volume, :chapter, :date, :href, :nb_pages, :file_name)
    Struct.new('Param_value', :string, :id, :type, :value, :class, :min_value, :max_value)
    begin
      Utils_file::dir_create(Dir.home + '/.MangaScrap/db')
    rescue StandardError => error
      puts 'error while initializing MangaScrap'
      puts "error message is : '" + error.message + "'"
      exit 5
    end
    Utils_connection::init_utils
    unless Params.instance.misc[:color_text]
      String.disable_colorization = true
    end
  end
end
