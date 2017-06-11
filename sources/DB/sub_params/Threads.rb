class Params_threads
  include Params_module

  public
  def param_set(id, value, display = true)
    @display = display
    param = @params_list.select{|e| e[:id] == id}[0]
    if param == nil
      critical_error("param_set was called with the id #{id} but the Param_threads database does not posses it")
    end
    case id
      when 'emt'
        return param_check_bool(param, value)
      when 'nt'
        return param_check_nb(param, value)
      else
        critical_error("Did not find id #{id} in Param_threads database")
    end
  end

  # warning : the params MUST be in the same order as the database
  def get_params(default = false)
    ret = []
    ret << Struct::Param_value.new('enable_multi_threading', 'emt', 'bool', ((default) ? true : @params[:enable_multi_threading]), self)
    ret << Struct::Param_value.new('nb_threads', 'nt', 'int', ((default) ? 8 : @params[:nb_threads]), self, 2, 100)
    ret
  end

  def initialize
    @display = true
    @db_name = 'Threads'
    @template_file = 'sources/templates/text/params/threads.txt'
    Struct.new('Thread_params', :id, :enable_multi_threading, :nb_threads)
    init("CREATE TABLE IF NOT EXISTS #{@db_name} (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        enable_multi_threading VARCHAR(5),
        nb_threads INT)") do |data|
      @params = Struct::Thread_params.new(*data)
    end
  end
end
