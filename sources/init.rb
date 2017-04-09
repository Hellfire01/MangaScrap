#anything that needs to be done before the rest of MangaScrap is executed is placed here

def load_gem(gem)
  begin
    require gem
  rescue Exception => e
    puts ''
    puts "exception while trying to load #{gem}, please follow the installation instructions in the install directory"
    puts 'message is : ' + e.message
    puts 'please note that a ruby update may require a re-download of the gems'
    puts ''
    exit 6
  end
end

def load_all_gems
  require 'singleton'
  require 'open-uri'
  require 'pp'
  load_gem 'colorize'
  load_gem 'nokogiri'
  load_gem 'sqlite3'
end

def load_relative_files
  require_relative 'scan/scan'
  require_relative 'scan/scan_utils'
  require_relative 'api/mangas'
  require_relative 'api/other'
  require_relative 'api/output'
  require_relative 'api/params'
  require_relative 'instructions/delete_diff'
  require_relative 'instructions/params'
  require_relative 'instructions/redl'
  require_relative 'utils/utils_file'
  require_relative 'utils/utils_args'
  require_relative 'utils/utils_co'
  require_relative 'utils/utils_manga'
  require_relative 'utils/utils_html'
  require_relative 'utils/utils_debug'
  require_relative 'html/html'
  require_relative 'html/html_buffer'
  require_relative 'Download/mangafox'
  require_relative 'DownloadDisplay'
  require_relative 'instructions/Parsers/Instruction_parser'
  require_relative 'instructions/Parsers/Data_parser'
  require_relative 'instructions/Parsers/Query_Parser'
  require_relative 'instructions/Parsers/File_parser'
  require_relative 'instructions/query'
  require_relative 'instructions/Instructions_exec'
  require_relative 'instructions/Manga_data_filter'
  require_relative 'DB/Manga_data'
  require_relative 'DB/Manga_database'
  require_relative 'DB/Params'
end

def initialize_mangascrap
  load_all_gems
  load_relative_files
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
