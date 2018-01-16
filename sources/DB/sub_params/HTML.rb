# only directly used by the Params class, must NOT be directly called elsewhere
class Params_HTML
  include Params_module

  public
  def param_set(id, value, display = true)
    @display = display
    param = @params_list.select{|e| e[:id] == id}[0]
    if param == nil
      critical_error("param_set was called with the id #{id} but the Param_HTML database does not posses it")
    end
    case id
      when 'agh', 'ne', 'nm'
        return param_check_bool(param, value)
      when 'nc'
        ret = param_exec_value_change(param, value)
        puts 'array inserted into the database :'
        pp value.split(', ')
        return ret
      when 'td'
        return param_exec_value_change(param, value)
      else
        Utils_errors::critical_error("Did not find id #{id} in Param_HTML database")
    end
  end

  # warning : the params MUST be in the same order as the database
  def get_params(default = false)
    ret = []
    ret << Struct::Param_value.new('auto_generate_html', 'agh', 'bool', ((default) ? true : @params[:auto_generate_html]), self)
    ret << Struct::Param_value.new('nsfw_enabled', 'ne', 'bool', ((default) ? true : @params[:nsfw_enabled]), self)
    ret << Struct::Param_value.new('nsfw_categories', 'nc', 'array', ((default) ? 'Ecchi, Mature, Smut, Adult' : @params[:nsfw_categories]), self)
    ret << Struct::Param_value.new('template_dir', 'td', 'string', ((default) ? 'default' : @params[:template_dir]), self)
    ret << Struct::Param_value.new('night_mode', 'nm', 'bool', ((default) ? false : @params[:night_mode]), self)
    ret
  end

  def initialize
    @display = true
    @db_name = 'HTML'
    @template_file = 'sources/templates/text/params/html.txt'
    Struct.new('HTML_params', :id, :auto_generate_html, :nsfw_enabled, :nsfw_categories, :template_dir, :night_mode)
    init("CREATE TABLE IF NOT EXISTS #{@db_name} (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        auto_generate_html VARCHAR(5),
        nsfw_enabled VARCHAR(5),
        nsfw_categories TEXT,
        template_dir TEXT,
        night_mode VARCHAR(5))") do |data|
      @params = Struct::HTML_params.new(*data)
    end
  end
end
