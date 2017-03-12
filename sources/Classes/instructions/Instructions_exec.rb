# class used for the argument management
# it returns the required commands on success and nil on failure
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

  def get_data_parser(instruction)
    parser = Data_parser.new(instruction)
    # id needs 2 arguments : name ( args[0] and site args[1] )
    parser.on('id', 2) do |args|
      data = Manga_data.new(nil, args[0], args[1], nil, nil)
      @data_to_prepare << data
    end
    # link needs one argument : link ( args[0] )
    parser.on('link', 1) do |args|
      link = args[0]
      if link.size != 0 && link[link.size - 1] == '/'
        # this ensures that all links do not finish by a '/'
        link = link.chomp('/')
      end
      data = Manga_data.new(nil, nil, nil, link, nil)
      @data_to_prepare << data
    end
    # File parser uses args[0] as file name and directly outputs it's
    #     content in @data_to_prepare
    parser.on('file', 1) do |args|
      e = File_parser.new(args[0], @data_to_prepare)
      unless e.good
        puts 'ignoring file instruction'.yellow
      end
    end
    # query
    parser.on('query', 1) do |args| # <======================================================
      puts 'query is currently a placeholder'
#      query = Query_Manager.new
#      data = query.run(args[0])
    end
    # all does not use any arguments
    # even tho the elements from the database are valid, they are sent to
    #     @data_to_prepare to avoid duplicates
    parser.on('all', 0) do ||
      @data_to_prepare += Manga_database.instance.get_manga_list
    end
    parser
  end

  def get_valid_data(function, connection, args, error_if_no_elements = true)
    tmp = args
    tmp = tmp.join(' ')
    parser = get_data_parser(function)
    parser.parse args
    filter = Manga_data_filter.new(@data_to_prepare)
    ret = filter.run(connection, true)
    @data_to_prepare.clear
    if ret.size == 0 && error_if_no_elements
      puts 'Warning : '.yellow + 'ignoring instruction ' + '['.yellow + function + ' ' +
             tmp + ']'.yellow + '. Reason is : ' + 'no elements to use'.yellow
    end
    ret
  end

  def init_parser
    @parser = Instruction_parser.new
    # manga download
    @parser.on 'add' do |args|
      buff = get_valid_data('add', true, args)
      add(buff, true) unless buff.empty?
    end
    @parser.on 'update' do |args|
      buff = get_valid_data('update', false, args)
      update(buff) unless buff.empty?
    end
    @parser.on 'fast-update' do |args|
      buff = get_valid_data('update', false, args)
      update(buff, false, true) unless buff.empty?
    end
    @parser.on 'download', 'dl' do |args|
      buff = get_valid_data('download', true, args, false)
      download(buff) unless buff.empty?
    end
    @parser.on 'data-check' do |args|
      puts 'data-check is currently a placeholder'
      buff = get_valid_data('data-check', true, args) # <==========================================================
      # todo correct
      # fonction pour ajouter les nouveaux champs de données aux traces
      # permet aussi de supprimer les chapitres avec un mauvais nombre de pages
      # cette fonction vient étendre delete-diff
    end
    @parser.on 'redl', 're-download' do |args|
      re_download(args, self)
    end
    # html
    @parser.on 'html' do |args|
      buff = get_valid_data('html', false, args, false)
      html_manager(buff)
    end
    # manga database related
    @parser.on 'clear' do |args|
      buff = get_valid_data('clear', false, args)
      clear(buff) unless buff.empty?
    end
    @parser.on 'data' do |args|
      buff = get_valid_data('data', false, args)
      data(buff) unless buff.empty?
    end
    @parser.on 'todo' do |args|
      buff = get_valid_data('update', false, args)
      update(buff, true) unless buff.empty?
    end
    @parser.on 'delete' do |args|
      buff = get_valid_data('delete', false, args)
      delete(buff) unless buff.empty?
    end
    @parser.on 'delete-db' do |args|
      buff = get_valid_data('delete-db', false, args)
      delete(buff, false) unless buff.empty?
    end
    @parser.on 'output' do |args|
      buff = get_valid_data('output', false, args, false)
      output(buff) unless buff.empty?
    end
    @parser.on 'to-file' do |args|
      buff = get_valid_data('to-file', false, args, false) # <=====================================================
      # todo to-file
      puts 'placeholder for to-file'
      pp buff
    end
    @parser.on 'details' do |args|
      buff = get_valid_data('list', false, args, false)
      details(buff) unless buff.empty?
    end
    # params related
    @parser.on 'macros' do |args| # <==============================================================================
      # todo macros
      puts 'placeholder for macros'
      tmp = get_data_parser('macros')
      tmp.parse args
    end
    @parser.on 'param', 'params' do |args|
      params_management(args) if required_arguments('param', args)
    end
    # other
    # help and version completely ignore the arguments that are given to them
    @parser.on 'help', '--help', '-h' do ||
      help
    end
    @parser.on 'version', '--version' do ||
      version
    end
    @parser.jump_when('id', 2)
    @parser.jump_when('link', 1)
    @parser.jump_when('file', 1)
    @parser.jump_when('query', 1)
    @parser.jump_when('set', 2)
    @parser.jump_when('p', 1)
    @parser.jump_when('c', 1)
    @parser.jump_when('v', 1)
  end

  public
  def clear_data
    @data_to_prepare.clear
  end

  # executes the program
  def run
    if ARGV.size == 0
      puts 'no arguments, executing default'
      puts ''
      puts '' 'executing : ' + 'update'.green + ' ' + 'all'.yellow
      puts ''
      buff = get_valid_data('update', false, ['all'])
      update(buff) unless buff.empty?
      # todo => default execution from params ?
    else
      @parser.parse ARGV
    end
    puts ''
  end

  def initialize
    init_parser
    @data_to_prepare = []
  end
end
