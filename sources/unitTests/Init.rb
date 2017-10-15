# this class is used by the unit tests to ensure that all of the files load correctly
class UT_Init
  private
  # used to display an error if the gem could not be loaded
  def load_gem(gem)
    begin
      require gem
    rescue LoadError => e
      puts 'Error while loading the ' + gem + ' gem. Message is : ' + e.message
      return false
    end
    true
  end

  def load_init_file
    puts '======================> 1 - requiring init file' if @verbose
    begin
      puts 'requiring sources/init.rb'if @verbose && @high_verbose
      require_relative '../init'
    rescue LoadError => e
      puts 'Error while loading the init file (it should have been at : ' + Dir.pwd + '/sources/init.rb)'
      puts 'aborting'
      exit 1
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end

  def require_all_gems
    puts '======================> 2 requiring all gems' if @verbose
    failure = false
    Init::get_gem_list.each do |gem|
      puts 'requiring ' + gem if @verbose && @high_verbose
      failure = !(load_gem(gem) || failure)
    end
    if failure
      puts 'aborting'
      exit 2
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end

  def require_all_mangascrap_files
    puts '======================> 3 requiring all MangaScrap files' if @verbose
    failure = false
    Init::get_file_list.each do |file|
      puts 'requiring sources/' + file if @verbose && @high_verbose
      failure = !(Unit_tests_API::require_file('sources/' + file) || failure)
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end

  def get_structures
    puts '======================> 4 getting the structures' if @verbose
    begin
      Init::init_structures
    rescue Exception => e
      puts 'Error'
      pp e.class.to_s
      pp e.message
      exit 5
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end

# old tests that can only be used if there are elements in the database
=begin
  def get_content_of_database
    puts '======================> 5 getting the content of the database ( all of it )' if @verbose
    begin
      list = Manga_database.instance.get_manga_list
      traces_chapters_qt = 0
      traces_pages_qt = 0
      todo_chapters_qt = 0
      todo_pages_qt = 0
      need_correction = 0
      list.each do |manga|
        Manga_database.instance.get_trace(manga).each do |trace|
          trace[5] == nil ? need_correction += 1 : traces_pages_qt += trace[5]
          traces_chapters_qt += 1
        end
        Manga_database.instance.get_todo(manga).each do |todo|
          todo[4] == -1 ? todo_chapters_qt += 1 : todo_pages_qt += 1
        end
      end
      if @verbose
        puts "found a total of #{list.size} elements in the database"
        puts "there are #{traces_chapters_qt} chapters and #{traces_pages_qt} pages downloaded"
        puts "#{todo_chapters_qt} chapters and #{todo_pages_qt} still need to be downloaded"
        if need_correction != 0
          puts "Warning ! #{need_correction} chapters need a check ( the amount of downloaded pages is not available )"
        end
      end
    rescue Exception => e
      puts 'Error'
      pp e.class.to_s
      pp e.message
      exit 5
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end

  def get_params
    puts '======================> 6 getting the params' if @verbose
    begin
      # get param class
      # get sub params classes
      # check params of sub params classes values
    rescue Exception => e
      puts 'Error'
      pp e.class.to_s
      pp e.message
      exit 5
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end
=end

  def prepare_databases
    puts '======================> 5 preparing the databases' if @verbose
    Manga_database::set_unit_tests_env('unitTests/')
    Params_module::set_unit_tests_env('unitTests/')
    Manga_database.instance
    Params.instance
    puts 'ok' if @verbose
    puts '' if @verbose
  end

  public
  def run
    puts '####################### Basic tests'
    puts ''
    load_init_file
    require_all_gems
    require_all_mangascrap_files
    get_structures
    prepare_databases
    puts '####################### all good'
  end

  def initialize(verbose = true, high_verbose = true)
    @verbose = verbose
    @high_verbose = high_verbose
    puts '======================> 0 clearing unit tests environment' if @verbose
    Utils_file::dir_create(Dir.home + '/.MangaScrap/unitTests')
    File.glob(Dir.home + '/.MangaScrap/unitTests/*').each do |file|
      puts 'deleting file : ' + file if @verbose && @high_verbose
      File.delete(file)
    end
    puts 'ok' if @verbose
    puts '' if @verbose
  end
end
