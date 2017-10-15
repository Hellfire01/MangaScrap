class Params
  include Singleton
  attr_reader :download, :html, :misc, :threads

  private
  def initialize
    @display = true
    unless Dir.exists?(Dir.home + '/.MangaScrap/db/')
      Utils_file::dir_create(Dir.home + '/.MangaScrap/db/')
    end
    unless File.exist?(Dir.home + '/.MangaScrap/db/params.db')
      introduction
    end
    @threads = Params_threads.new
    @download = Params_download.new
    @html = Params_HTML.new
    @misc = Params_misc.new
    @param_classes = [] << @download << @html << @misc << @threads
    @params = []
    @param_classes.each do |param|
      @params += param.params_list
    end
  end

  public
  # used to check if the user really wants to reset
  def param_reset (require_confirmation = true)
    margin = 25
    check_user_input = false
    if require_confirmation
      prep = "You are about to reset the following params :\n"
      @param_classes.each do |param_class|
        prep += "\n#{param_class.db_name.blue}\n"
        param_class.params_list.each do |param|
          prep += param[:string] + ((param[:string].size > margin) ? ' ' : ' ' * (margin - param[:string].size))
          prep += param[:id].red + ((param[:id].size == 3) ? '' : ' ')+ ' => ' + param[:value].to_s.green + "\n"
        end
      end
      prep += "\n\n"
      check_user_input = Utils_user_input::require_confirmation(prep)
    end
    if check_user_input || !require_confirmation
      @param_classes.each do |param_class|
        param_class.params_reset
      end
      puts 'params where set to the displayed values'
    else
      puts 'did not reset params'
    end
  end

  def display_params
    @param_classes.each do |param_class|
      puts param_class.params_display
      puts ''
    end
  end

  def param_set (id, value, display = true)
    ret = @params.select{|e| e[:id] == id}[0]
    if ret == nil
      if display
        puts 'Error'.red + ' : unknown parameter id : ' + id
        puts './MangaScrap help'.yellow + ' for help'
      end
    else
      ret[:class].param_set(id, value, display)
    end
  end

  def init_all_databases
    param_reset(false)
  end

  def introduction
    puts ''
    puts ''
    puts 'Hi, thank you for using MangaScrap, please do enjoy using it'
    puts 'The database will be created and initialized with default values'
    puts 'Please make sure those values suit you'
    puts ''
    puts 'To check the parameter values, execute :'
    puts './MangaScrap.rb params list'.yellow
    puts 'For any help, execute :'
    puts './MangaScrap.rb help'.yellow
    puts ''
    puts 'Please note that by default, the directory in witch MangaScrap will place all the downloaded mangas is :'
    puts $default_manga_path.yellow
    puts ''
    puts ''
    puts 'if you enjoy using MangaScrap, please do star me on githhub :'
    puts 'https://github.com/Hellfire01/MangaScrap'
    puts ''
    puts ''
    puts ''
  end
end
