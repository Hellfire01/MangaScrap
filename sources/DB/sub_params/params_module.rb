$db_path = 'db/'

module Params_module
  attr_reader :params, :params_list, :db_name

  private
  # used to output strings depending on the value of @display
  def write_output(message)
    if @display
      puts message
    end
  end

  # used to write in the database
  def set_param_value(param)
    value = param[:value]
    if param[:type] == 'bool'
      value = value.to_s
    end
    Utils_database::db_exec("UPDATE #{@db_name} SET #{param[:string]} = ?", 'could not update ' + param[:string], @db, [value])
  end

  # this function should only be called if there is an error
  def param_critical_error(param, func)
    write_output 'Error : the ' + param + ' ended in the wrong function (' + func + ')'
    write_output 'This is a Mangascrap error, please report it'
    write_output '( unless you caused it by altering the code )'
    false
  end

  # used to validate a paarm value change
  def param_exec_value_change(param, value)
    if param[:type] == 'bool'
      if value == 'true'
        param[:value] = true
      else
        param[:value] = false
      end
    else
      param[:value] = value
    end
    write_output "updated #{param[:string]} (#{param[:id].red}) to #{param[:value].to_s.green}"
    set_param_value(param)
    true
  end

  # params check for numbers
  def param_check_nb(param, value)
    value = (param[:type] == 'int' ? value.to_i : value.to_f)
    if value < param[:min_value] || value > param[:max_value]
      write_output "the value cannot be < #{param[:min_value]} or > #{param[:max_value]} for #{param[:string]} (#{param[:id]})"
      return false
    end
    param_exec_value_change(param, value)
  end

  # params check for booleans
  def param_check_bool(param, value)
    if value != 'true' && value != 'false'
      write_output 'Error'.red + " : argument must be 'true' or 'false' when setting param #{param[:string]}\n"
      return false
    end
    param_exec_value_change(param, value)
  end

  # params check for strings
  def param_check_string(_param, _display, _value)
    critical_error('the param_check_string method was not overridden after being included in a database class')
  end

  # gets the required string for database insertion
  def get_insert_string(length)
    i = 0
    lock = true
    ret = ''
    while i < length
      if lock
        lock = false
      else
        ret += ', '
      end
      ret += '?'
      i += 1
    end
    ret
  end

  # used to ensure that the booleans are booleans and not the strings that can be found in the database
  # ( sqlite does not manage the boolean type )
  def prepare_data(data)
    i = -1
    buff = get_params(true)
    good_data = []
    data.each do |value|
      if i == -1 # the first value is an id and is not in the params_list
        good_data << value
        i += 1
        next
      end
      if buff[i][:type] == 'bool'
        if value.is_a?(TrueClass) || value == 'true' # translate string to boolean
          good_data << true
        elsif value.is_a?(FalseClass) || value == 'false' # translate string to boolean
          good_data << false
        else
          Utils_errors::critical_error("The param #{buff[i][:string].gsub('_', ' ')} had a value of '#{buff[i][:value]}' \
(#{buff[i][:value].class.to_s}), it should be 'true' or 'false' (boolean)")
        end
      else
        good_data << value
      end
      i += 1
    end
    good_data
  end

  # gets all of the data form the database
  def get_data_from_db(init_exec)
    @db = SQLite3::Database.new(Dir.home + '/.MangaScrap/' + $db_path + 'params.db')
    @db.execute init_exec
    data = Utils_database::db_exec("Select * from #{@db_name}", "could not get params from the #{@db_name} table", @db)[0]
    if data == nil || data.size == 0 # if the database is empty, the parameters are initialized with the default values
      default = [] << 1 # the id
      begin
        get_params(true).each do |param|
          if param[:type] == 'bool'
            if param[:value].is_a?(TrueClass)
              default << 'true'
            else
              default << 'false'
            end
          else
            default << param[:value]
          end
        end
        insert_string = get_insert_string(default.length)
        Utils_database::db_exec("INSERT INTO #{@db_name} VALUES (#{insert_string})", "could not init #{@db_name} database please reset it", @db, default)
      rescue SQLite3::Exception => e
        Utils_errors::critical_error("exception while retrieving params (#{@db_name}) / initializing params", e)
      end
      data = default
    end
    data
  end

  # method called by the initialize of the Params_class
  def init(init_exec)
    data = get_data_from_db(init_exec)
    data = prepare_data(data)
    yield(data)
    @params_list = get_params # todo : les params ont déjà été get avec les valeurs par défaut, regarder s'il ne serait pas possible de faire usae du tableau de structures plutot que d'en demander un autre
  end

  public # ========================================================================================================= public
  # used to set unit tests environment
  def self.set_unit_tests_env(db_path)
    $db_path = db_path
  end

  # used to access the params directly from the class ( you can see it as some sort of glorified getter )
  def [](id)
    begin
      @params[id]
    rescue NameError => e
      Utils_errors::critical_error("Params module #{@db_name}'s getter was called with a bad argument : '#{id}' ( there is no such id )", e)
    end
  end

  # used to display the parameters and their setting nicely on the terminal by reading a template file in the @template_file
  def params_display
    margin_string = 22
    template = File.open(@template_file).read
    template = template.gsub('(not yet implemented)', '(not yet implemented)'.magenta)
    template = template.gsub("[#{@db_name.downcase}]", "======================= #{@db_name.upcase} =======================".blue)
    @params_list.each do |param|
      template = template.gsub("[#{param[:id]}]", param[:string].gsub('_', ' ').yellow + ((param[:string].size > margin_string) ? ' ' : ' ' * (margin_string - param[:string].size)))
      template = template.gsub("|#{param[:id]}|", param[:string].gsub('_', ' ').yellow)
      template = template.gsub("(#{param[:id]})", "(#{param[:id]})".red + ((param[:id].size == 3) ? '' : ' '))
      template = template.gsub("{#{param[:id]}}", param[:value].to_s.green)
    end
    template
  end

  # id = the 2 short string that identifies a parameter
  # value = value on witch you wish to set the parameter. WARNING : booleans are sent as strings 'true' / 'false'
  # display = writes or not on the terminal in case of failure
  # allows you to set the parameters
  def param_set (_id, _value, _display = true)
    critical_error('the param_set method was not overridden after being included in a database class')
  end

  # used to reset all params
  def params_reset
    buff = []
    names = []
    get_params(true).each do |param|
      if param[:type] == 'bool'
        if param[:value].is_a?(TrueClass)
          buff << 'true'
        elsif param[:value].is_a?(FalseClass)
          buff << 'false'
        else
          Utils_errors::critical_error("The param #{param[:string].gsub('_', ' ')} has a value of '#{param[:value]}' \
(#{param[:value].class.to_s}), it should be 'true' or 'false' (boolean)")
        end
      else
        buff << param[:value]
      end
      names << param[:string] + ' = ?'
    end
    Utils_database::db_exec("UPDATE #{@db_name} SET #{names.join(', ')} WHERE id=1", "could not update #{@db_name}", @db, buff)
  end
end
