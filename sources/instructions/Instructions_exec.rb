=begin

This class parses the ARGV to extract all of the instructions MangaScrap will use
To add your own instruction, you need to add your own block respecting this format in the init_parser method :

@parser.on name_of_your_instruction do |args|
  buff = get_valid_data(name_of_your_instruction_for_error_display, require_internet?, args, error_if_invalid?)
  html_manager(buff)
end

note : you can use multiple names
note : error_if_invalid? is used to say if your function NEEDS at least 1 valid Manga_Data ( no invalid ones will be given )

important : should your method use it's own special arguments, add this line in the init :
@parser.jump_when(name_of_your_instruction, number_of_arguments)
this will allow MangaScrap to know that these arguments should not be parsed as instructions

=end

class Instructions_exec
  attr_reader :data_to_prepare
  private
  def required_arguments(instruction, args)
    if args.size == 0
      puts 'Error : '.red + ' the ' + instruction.yellow + ' option needs at least an argument'
      false
    else
      true
    end
  end

  # this method first calls the data arguments parser then filters all the Manga_Data classes that returned false on
  #     resolve and finally returns the validated Manga_Data classes
  def get_valid_data(function, connection, args, error_if_no_elements = true)
    tmp = args
    tmp = tmp.join(' ')
    parser = get_data_parser(function)
    parser.parse args
    filter = Manga_data_filter.new(@data_to_prepare)
    ret = filter.run(connection, true)
    @data_to_prepare.clear
    if ret.size == 0 && error_if_no_elements
      puts 'Warning : '.yellow + 'ignoring instruction ' + '['.yellow + function + ((tmp == '') ? '' : ' ') + tmp + ']'.yellow
      puts 'Reason is : ' + 'no elements to use'.yellow
    end
    ret
  end

  # used to prepare the parser, all of the instructions that are understood by MangaScrap are in these methods
  # add your own instructions here

  def init_parser
    @parser = Instruction_parser.new
    init_parser_mangas_related
    init_parser_utilities
    # params related
    @parser.jump_when('id', 2)
    @parser.jump_when('link', 1)
    @parser.jump_when('file', 1)
    @parser.jump_when('query', 1)
    @parser.jump_when('set', 2)
    @parser.jump_when('p', 1)
    @parser.jump_when('c', 1)
    @parser.jump_when('v', 1)
  end

  def init_parser_utilities
    @parser.on 'to-file' do |args|
      buff = get_valid_data('to-file', false, args, false) # <================================= currently a placeholder
      # todo to-file
      puts 'placeholder for to-file'
      pp buff
    end
    @parser.on 'macros' do |args| # <========================================================== currently a placeholder
      # todo macros
      puts 'placeholder for macros'
      tmp = get_data_parser('macros')
      tmp.parse args
    end
    @parser.on 'param', 'params' do |args|
      MangaScrap_API::params_management(args) if required_arguments('param', args)
    end
    @parser.on 'help', '--help', '-h' do ||
      MangaScrap_API::help
    end
    @parser.on 'version', '--version' do ||
      MangaScrap_API::version
    end
    @parser.on 'html' do |args|
      buff = get_valid_data('html', false, args, false)
      MangaScrap_API::html_manager(buff)
    end
    @parser.on 'output' do |args|
      buff = get_valid_data('output', false, args, false)
      MangaScrap_API::output(buff) unless buff.empty?
    end
    @parser.on 'details' do |args|
      buff = get_valid_data('list', false, args, false)
      MangaScrap_API::details(buff) unless buff.empty?
    end
  end

  def init_parser_mangas_related
    # adding
    @parser.on 'add' do |args|
      buff = get_valid_data('add', true, args)
      MangaScrap_API::add(buff, true) unless buff.empty?
    end
    @parser.on 'download', 'dl' do |args|
      buff = get_valid_data('download', true, args, false)
      MangaScrap_API::download(buff) unless buff.empty?
    end
    # updating
    @parser.on 'update' do |args|
      buff = get_valid_data('update', false, args)
      MangaScrap_API::update(buff) unless buff.empty?
    end
    @parser.on 'fast-update' do |args|
      buff = get_valid_data('update', false, args)
      MangaScrap_API::update(buff, false, true) unless buff.empty?
    end
    # data related
    @parser.on 'data-check' do |args|
      puts 'data-check is currently a placeholder'
      buff = get_valid_data('data-check', true, args) # <===================================== currently a place holder

      # note to self : 'bad' pictures have a size of 49B => auto check pages of 1K or less

      # todo correct
      # fonction pour ajouter les nouveaux champs de données aux traces
      # permet aussi de supprimer les chapitres avec un mauvais nombre de pages
      # cette fonction vient étendre delete-diff
    end
    # correcting
    @parser.on 'redl', 're-download' do |args|
      MangaScrap_API::re_download(args, self)
    end
    @parser.on 'data' do |args|
      buff = get_valid_data('data', false, args)
      MangaScrap_API::data(buff) unless buff.empty?
    end
    # _todo
    @parser.on 'clear' do |args|
      buff = get_valid_data('clear', false, args)
      MangaScrap_API::clear(buff) unless buff.empty?
    end
    @parser.on 'todo' do |args|
      buff = get_valid_data('update', false, args)
      MangaScrap_API::update(buff, true) unless buff.empty?
    end
    # delete
    @parser.on 'delete' do |args|
      buff = get_valid_data('delete', false, args)
      MangaScrap_API::delete(buff) unless buff.empty?
    end
    @parser.on 'delete-db' do |args|
      buff = get_valid_data('delete-db', false, args)
      MangaScrap_API::delete(buff, false) unless buff.empty?
    end
  end

  public
  # returns a pre-configured parser for the data arguments
  # takes an arguments : instruction = the instruction that calls these data_arguments
  # the data argument's arguments :
  #   id needs 2 arguments : name ( args[0] and site args[1] )
  #   link needs one argument : link ( args[0] )
  #   File parser uses one argument : file_name ( args[0] ) and directly outputs it's content in @data_to_prepare
  #   query takes one argument : query witch is the parsed to extract the required mangas
  #   all does not use any arguments and gets everything from the database
  def get_data_parser(instruction)
    parser = Data_parser.new(instruction)
    parser.on('id', 2) do |args|
      data = Manga_data.new(nil, args[0], args[1], nil, nil)
      @data_to_prepare << data
    end
    parser.on('link', 1) do |args|
      link = args[0]
      if link.size != 0 && link[link.size - 1] == '/' # this ensures that all links do not finish by a '/'
        link = link.chomp('/')
      end
      data = Manga_data.new(nil, nil, nil, link, nil)
      @data_to_prepare << data
    end
    parser.on('file', 1) do |args|
      e = File_parser.new(args[0], @data_to_prepare)
      unless e.good
        puts 'ignoring file instruction'.yellow
      end
    end
    parser.on('query', 1) do |args| # <======================================================== currently a placeholder
      puts 'query is currently a placeholder'
#      query = Query_Manager.new
#      data = query.run(args[0])
    end
    parser.on('all', 0) do ||
      @data_to_prepare += Manga_database.instance.get_manga_list
    end
    parser
  end

  # clears the validated Manga_Data array to allow re-usage of the class
  def clear_data
    @data_to_prepare.clear
  end

  # executes the instructions
  def run argv
    if argv.size == 0
      puts 'no arguments, executing default'
      puts ''
      puts '' 'executing : ' + 'update'.green + ' ' + 'all'.yellow
      puts ''
      buff = get_valid_data('update', false, ['all'])
      MangaScrap_API::update(buff) unless buff.empty?
      # todo => default execution from params ?
    else
      @parser.parse argv
    end
    puts ''
  end

  def initialize
    init_parser
    @data_to_prepare = []
  end
end
