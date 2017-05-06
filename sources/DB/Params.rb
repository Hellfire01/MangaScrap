$default_manga_path = Dir.home + '/Documents/mangas/'

class Params
  include Singleton
  private
  def write_output(message)
    if @display
      puts message
    end
  end

  def exec_reset
      Utils_database::db_exec('UPDATE params SET manga_path = ?, between_sleep = ?, failure_sleep = ?, nb_tries_on_fail = ?,error_sleep = ?, delete_diff = ?, catch_exception = ?, generate_html = ?, html_nsfw = ?, html_nsfw_data = ?, color_text = ? WHERE Id = 1',
              'could not set / reset parameters', @db, [Params::get_default_params])
  end

  def set_param_value(param, value)
      Utils_database::db_exec("UPDATE params SET #{param} = ? WHERE Id = 1", 'could not update ' + param, @db, value)
  end

# this function should never be called, when called there is an error in the code
  def param_critical_error(param, func)
    write_output 'Error : the ' + param + ' ended in the wrong function (' + func + ')'
    write_output 'This is a Mangascrap error, please report it'
    write_output '( unless you caused it by altering the code )'
    false
  end

# params set for numbers
  def param_check_nb(param, display, value, min_value)
    if value < min_value
      write_output "the '" + display[0] + "' value cannot be < " + min_value.to_s + 'for ' + param
      return false
    end
    set_param_value(display[1], value)
    write_output 'updated ' + display[0] + ' param to ' + value.to_s
    true
  end

# params set for booleans
  def param_check_bool(param, display, value)
    if value != 'true' && value != 'false'
      write_output "argument must be 'true' or 'false' for " + param
      return false
    end
    set_param_value(display[1], value)
    write_output 'updated ' + display[0] + ' to ' + value
    true
  end

# params set for strings
  def param_check_string(param, display, value)
    case param
      when 'mp'
        if value[0, 1] != '~' && value[0, 1] != '/'
          write_output 'cannot create local directory'
          return false
        end
        begin
          Utils_file::dir_create(value)
        rescue StandardError => error
          write_output 'could not create requested path'
          write_output "error message is : '" + error.message + "'"
          return false
        end
        set_param_value(display[1], value)
      when 'nd'
        set_param_value(display[1], value)
        write_output 'updated nsfw genres to : \n\n' + value.split(', ').join('\n') + '\n\n'
      else
        return param_critical_error(param, 'param_check_string')
    end
    write_output('updated ' + display[0] + ' to ' + value)
    true
  end

  public
  # returns the default values of the params
  def self.get_default_params
    ret = [] << $default_manga_path << 0.1 << 0.1 << 20 << 30 << 'true' << 'true' << 'true' << 'true' << 'Ecchi, Mature, Smut, Adult' << 'true'
    ret
  end

# returns all of the parameters in an array of [name, id, value]
# used for gui ( among others )
  def get_params_list
    ret = []
    ret << ['manga path', 'mp', @params[1]]
    ret << ['between sleep', 'bs', @params[2]]
    ret << ['failure sleep', 'fs', @params[3]]
    ret << ['nb tries', 'nb', @params[4]]
    ret << ['error sleep', 'es', @params[5]]
    ret << ['delete diff', 'dd', @params[6]]
    ret << ['catch exception', 'ce', @params[7]]
    ret << ['generate html', 'gh', @params[8]]
    ret << ['html', 'hn', @params[9]]
    ret << ['nsfw data', 'nd', @params[10]]
    ret << ['color text', 'ct', @params[11]]
    ret
  end

  # reading the file, adding DB values and setting the colors ( when needed )
  # used to display the parameters and their setting nicely on the terminal
  def param_list_file
    params = Params.instance.get_params
    template = File.open('sources/templates/text/params.txt').read
    template = template.gsub('#{params[1]}', params[1].green)
    template = template.gsub('#{params[2]}', params[2].to_s.green)
    template = template.gsub('#{params[3]}', params[3].to_s.green)
    template = template.gsub('#{params[4]}', params[4].to_s.green)
    template = template.gsub('#{params[5]}', params[5].to_s.green)
    template = template.gsub('#{params[6]}', params[6].green)
    template = template.gsub('#{params[7]}', params[7].green)
    template = template.gsub('#{params[8]}', params[8].green)
    template = template.gsub('#{params[9]}', params[9].green)
    template = template.gsub('#{params[10]}', params[10].green)
    template = template.gsub('#{params[11]}', params[11].green)
    template = template.gsub('[data]', '====> data :'.blue)
    template = template.gsub('[internet]', '====> internet :'.blue)
    template = template.gsub('[html]', '====> html :'.blue)
    template = template.gsub('[internal]', "====> MangaScrap's internal functioning :".blue)
    template = template.gsub('[term output]', '====> MangaScrap terminal output :'.blue)
    template = template.gsub('(mp)', '(mp)'.red)
    template = template.gsub('(dd)', '(dd)'.red)
    template = template.gsub('(bs)', '(bs)'.red)
    template = template.gsub('(fs)', '(fs)'.red)
    template = template.gsub('(nb)', '(nb)'.red)
    template = template.gsub('(es)', '(es)'.red)
    template = template.gsub('(ce)', '(ce)'.red)
    template = template.gsub('(gh)', '(gh)'.red)
    template = template.gsub('(hn)', '(hn)'.red)
    template = template.gsub('(nd)', '(nd)'.red)
    template.gsub('(ct)', '(ct)'.red)
  end

  # returns the params as they are in the database ( a big array of values )
  def get_params
    ret = Utils_database::db_exec('SELECT * FROM params', 'could not get params', @db)
    if ret.size == 0
     Utils_errors::critical_error('could not get the params as the table is empty')
    end
    ret[0]
  end

  # allows you to set the parameters
  # id = the 2 letter string that identifies a parameter
  # value = value on witch you wish to set the parameter. WARNING : booleans are sent as strings 'true' / 'false'
  # display = writes or not on the terminal in case of failure
  def param_set (id, value, display = true)
    @display = display
    case id
      when 'dd'
        param_check_bool(id, ['delete diff', 'delete_diff'], value)
      when 'ce'
        param_check_bool(id, ['catch exception', 'catch_execption'], value)
      when 'mp'
        param_check_string(id, ['manga path', 'manga_path'], value)
      when 'bs'
        param_check_nb(id, ['between sleep', 'between_sleep'], value.to_f, 0.1)
      when 'fs'
        param_check_nb(id, ['failure sleep', 'failure_sleep'], value.to_f, 0.1)
      when 'es'
        param_check_nb(id, ['error sleep', 'error_sleep'], value.to_f, 0.5)
      when 'nb'
        param_check_nb(id, ['number of tries', 'nb_tries_on_fail'], value.to_i, 1)
      when 'gh'
        param_check_bool(id, ['generate html', 'generate_html'], value)
      when 'hn'
        param_check_bool(id, ['html nsfw', 'html_nsfw'], value)
      when 'nd'
        param_check_string(id, ['nsfw data', 'html_nsfw_data'], value)
      when 'ct'
        param_check_bool(id, ['color text', 'color_text'], value)
      else
        if @display
          puts 'error, unknown parameter id : ' + id
          puts '--help for help'
        end
        return false
    end
    true
  end

  # used to check if the user really wants to reset
  def param_reset (require_confirmation  = true)
    if require_confirmation
      default = Params::get_default_params
      puts ''
      puts 'WARNING ! You are about to reset your parameters !'
      puts 'the parameters will be set to :'
      puts 'manga path      = ' + default[0].yellow
      puts 'between sleep   = ' + default[1].to_s.yellow
      puts 'failure sleep   = ' + default[2].to_s.yellow
      puts 'number of tries = ' + default[3].to_s.yellow
      puts 'error sleep     = ' + default[4].to_s.yellow
      puts 'delete diff     = ' + default[5].yellow
      puts 'catch exception = ' + default[6].yellow
      puts 'generate html   = ' + default[7].yellow
      puts 'html nsfw       = ' + default[8].yellow
      puts 'html nsfw data  = ' + default[9].yellow
      puts 'color text      = ' + default[10].yellow
      puts ''
      if require_confirmation
        exec_reset
      end
    else
      exec_reset
    end
  end

  def introduction
    puts ''
    puts ''
    puts 'Hi, thank you for using MangaScrap, please do enjoy using it'
    puts 'The database will be created and initialized with default values'
    puts 'Please make sure those values suit you'
    puts ''
    puts 'To check the parameter values, execute :'
    puts './MangaScrap.rb params list'
    puts 'For any help, execute :'
    puts './MangaScrap.rb help'
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

  def initialize
    @display = true
    unless Dir.exists?(Dir.home + '/.MangaScrap/db/')
      Utils_file::dir_create(Dir.home + '/.MangaScrap/db/')
    end
    begin
      @db = SQLite3::Database.new(Dir.home + '/.MangaScrap/db/params.db'  )
      @db.execute 'CREATE TABLE IF NOT EXISTS params (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      manga_path TEXT,
      between_sleep FLOAT,
      failure_sleep FLOAT,
      nb_tries_on_fail INT,
      error_sleep FLOAT,
      delete_diff VARCHAR(5),
      catch_exception VARCHAR(5),
      generate_html VARCHAR(5),
      html_nsfw VARCHAR(5),
      html_nsfw_data VARCHAR(5),
      color_text VARCHAR(5))'
      ret = @db.execute 'SELECT * FROM params'
      if ret.size == 0
        introduction
        default = Params::get_default_params
        @db.execute "INSERT INTO params values (NULL, '#{default[0]}', #{default[1]}, #{default[2]}, #{default[3]},
#{default[4]}, '#{default[5]}', '#{default[6]}', '#{default[7]}', '#{default[8]}', '#{default[9]}', '#{default[10]}')"
      end
    rescue SQLite3::Exception => e
     Utils_errors::critical_error('exception while retrieving params / initializing params', e)
    end
    @params = get_params
  end
end
