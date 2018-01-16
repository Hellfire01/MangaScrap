# only directly used by the Params class, must NOT be directly called elsewhere

class Params_misc
  include Params_module

  public
  def param_set(id, value, display = true)
    @display = display
    param = @params_list.select{|e| e[:id] == id}[0]
    if param == nil
      critical_error("param_set was called with the id #{id} but the Param_misc database does not posses it")
    end
    case id
      when 'ct', 'dd', 'ce', 'cu'
        return param_check_bool(param, value)
      when 've'
        if value == 'low' || value == 'normal' || value == 'high'
          return param_exec_value_change(param, value)
        end
        puts 'Error '.red + ' the value for ' + 'verbose'.yellow + ' needs to be : ' + 'low'.yellow + ' or ' + 'normal'.yellow + ' or ' + 'high'/yellow
        return false
      else
        critical_error("Did not find id #{id} in Param_misc database")
    end
  end

  # warning : the params MUST be in the same order as the database
  def get_params(default = false)
    ret = []
    ret << Struct::Param_value.new('color_text', 'ct', 'bool', ((default) ? true : @params[:color_text]), self)
    ret << Struct::Param_value.new('delete_diff', 'dd', 'bool', ((default) ? true : @params[:delete_diff]), self)
    ret << Struct::Param_value.new('verbose', 've', 'string', ((default) ? 'high' : @params[:verbose]), self)
    ret << Struct::Param_value.new('check_for_updates', 'cu', 'bool', ((default) ? true : @params[:check_for_updates]), self)
  end

  def initialize
    @display = true
    @db_name = 'Misc'
    @template_file = 'sources/templates/text/params/misc.txt'
    Struct.new('Misc_params', :id, :color_text, :delete_diff, :verbose, :check_for_updates)
    init("CREATE TABLE IF NOT EXISTS #{@db_name} (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        color_text VARCHAR(5),
        delete_diff VARCHAR(5),
        verbose VARCHAR(32),
        check_for_updates VARCHAR(5))") do |data|
      # bloc
      @params = Struct::Misc_params.new(*data)
    end
    # code
  end
end
