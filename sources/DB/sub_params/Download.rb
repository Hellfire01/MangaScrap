# only directly used by the Params class, must NOT be directly called elsewhere

$default_manga_path = Dir.home + '/Documents/mangas/'

class Params_download
  include Params_module

  public
  def param_set(id, value, display = true)
    @display = display
    param = @params_list.select{|e| e[:id] == id}[0]
    if param == nil
      critical_error("param_set was called with the id #{id} but the Params_download database does not posses it")
    end
    case id
      when 'lt'
        return param_check_bool(param, value)
      when 'bs', 'fs', 'nbf', 'es', 'ct', 'dt', 'ltt'
        return param_check_nb(param, value)
      when 'mp'
        begin
          Utils_file::dir_create(value)
        rescue StandardError => error
          write_output 'could not create requested path'
          write_output "error message is : '" + error.message + "'"
          return false
        end
        return param_exec_value_change(param, value)
      else
        critical_error("Did not find id #{id} in Param_download database")
    end
  end

  # warning : the params MUST be in the same order as the database
  def get_params(default = false)
    ret = []
    ret << Struct::Param_value.new('manga_path', 'mp', 'string', ((default) ? $default_manga_path : @params[:manga_path]), self)
    ret << Struct::Param_value.new('between_sleep', 'bs', 'float', ((default) ? 0.1 : @params[:between_sleep]), self, 0.1, 300)
    ret << Struct::Param_value.new('failure_sleep', 'fs', 'float', ((default) ? 0.1 : @params[:failure_sleep]), self, 0.1, 300)
    ret << Struct::Param_value.new('nb_tries_on_fail', 'nbf', 'int', ((default) ? 20 : @params[:nb_tries_on_fail]), self, 1, 300)
    ret << Struct::Param_value.new('error_sleep', 'es', 'float', ((default) ? 20 : @params[:error_sleep]), self, 0.1, 300)
    ret << Struct::Param_value.new('connect_timeout', 'cto', 'int', ((default) ? 20 : @params[:connect_timeout]), self, 1, 300)
    ret << Struct::Param_value.new('download_timeout', 'dt', 'int', ((default) ? 300 : @params[:download_timeout]), self, 0, 300)
    ret << Struct::Param_value.new('loop_on_todo', 'lt', 'bool', ((default) ? true : @params[:loop_on_todo]), self)
    ret << Struct::Param_value.new('loop_on_todo_times', 'ltt', 'int', ((default) ? 5 : @params[:loop_on_todo_times]), self, 1, 10)
  end

  def initialize
    @display = true
    @db_name = 'Download'
    @template_file = 'sources/templates/text/params/download.txt'
    Struct.new('Download_params', :id, :manga_path, :between_sleep, :failure_sleep, :nb_tries_on_fail, :error_sleep,
               :connect_timeout, :download_timeout, :loop_on_todo, :loop_on_todo_times)
    init("CREATE TABLE IF NOT EXISTS #{@db_name} (
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
        manga_path TEXT,
        between_sleep FLOAT,
        failure_sleep FLOAT,
        nb_tries_on_fail INT,
        error_sleep FLOAT,
        connect_timeout INT,
        download_timeout INT,
        loop_on_todo VARCHAR(5),
        loop_on_todo_times INT)") do |data|
      @params = Struct::Download_params.new(*data)
    end
  end
end
