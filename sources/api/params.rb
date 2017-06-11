# params related

module MangaScrap_API
  # returns all of the parameters in an array of [name, id, value]
  def self.get_params_list
    Params.instance.param_classes
  end

  def self.display_params
    Params.instance.display_params
  end

  # allows you to set the parameters
  # id = the 2 letter string that identifies a parameter
  # value = value on witch you wish to set the parameter. WARNING : booleans are sent as strings 'true' / 'false'
  # display = writes or not on the terminal in case of failure
  # exit = exits or not in case or error ( bad imput )
  def self.param_set (id, value, display = true, exit = true)
    if Params.instance.param_set(id, value, display) == false && exit
      exit 5
    end
  end

  # used to check if the user really wants to reset
  # require_confirmation = bool, if true, will ask confirmation through STDIN ( terminal )
  def self.param_reset (require_confirmation  = true)
    Params.instance.param_reset(require_confirmation)
  end

  # used by the instruction parser ho gives all of the arguments to the params_management
  def self.params_management(args)
    case args[0]
      when 'list'
        display_params
      when 'reset'
        Params.instance.param_reset
      when 'set'
        param_set(args[1], args[2])
      else
        puts 'Error : '.red + 'unrecognised argument ' + args[0].yellow + ' for params'
        puts './MangaScrap help'.yellow + ' for help'
    end
  end
end
