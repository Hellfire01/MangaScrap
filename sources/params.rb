def param_list()
  db = Params.new()
  params = db.get_params()
  puts ""
  puts "list of paramaters and values :"
  puts ""
  puts "manga path    (mp) = #{params[1]}"
  puts "folder where you would like your mangas downloaded"
  puts ""
  puts "between sleep (bs) = #{params[2]}"
  puts "time between 2 requests on the site of the manga ( seconds )"
  puts ""
  puts "failure sleep (fs) = #{params[3]}"
  puts "time between 2 request failures ( seconds )"
  puts ""
  puts "nb tries      (nb) = #{params[4]}"
  puts "the number of tries MangaScrap will do before putting the page in the todo database"
  puts ""
  puts "error sleep   (es) = #{params[5]}"
  puts "time between 2 errors - such as a conection loss - ( seconds )"
  puts "30 seconds or more is advised"
  puts ""
  puts "delete diff   (dd) = #{params[6]}"
  puts "if ever durring an update a chapter is in the traces database but not in the chapter list, it is deleted ( or not )"
  puts "this can happen when a chapter is mistankingly uploaded to the wrong manga or the chapter list / organisation changed"
  puts ""
end

def param_critical_error(param, func)
  puts "Error : the " + param + " ended in the wrong function (" + func + ")"
  puts "This is a Mangascrap error, please report it"
  puts "( unless you caused it by altering the code )"
  exit(4)
end

def param_check_nb(db, param, disp, value, min_value)
  if (value < min_value)
    puts "the '" + disp + "' value canot be < " + min_value.to_s
    exit(5)
  end
  case param
  when 'bs'
    db.set_params_between_sleep(value)
  when 'fs'
    db.set_params_failure_sleep(value)
  when 'es'
    db.set_params_error_sleep(value)
  when 'nb'
    db.set_params_nb_tries(value)
  else
    param_critical_error(param, "param_check_nb")
  end
  puts "updated " + disp + " param to " + value.to_s
end

def param_check_bool(db, param, disp, value)
  if (value != "true" && value != "false")
    puts "argument must be 'true' or 'false'"
    exit 5
  end
  case param
  when 'dd'
    db.set_params_delete_diff(value)
  else
    param_critical_error(param, "param_check_bool")
  end
  puts "updated " + disp + " to " + value
end

def param_check_string(db, param, disp, value)
  case param
  when 'mp'
    db.set_params_path(value)
  else
    param_critical_error(param, "param_check_string")
  end
  puts "updated " + disp + " to " + value
end

def param_set()
  db = Params.new()
  if (ARGV.size < 3)
    puts "not enought arguments for parameter set"
    puts "--help for help"
  else
    if ARGV[2].size == 0
      puts "you cannot give an empty argument"
      exit 5
    end
    case ARGV[1]
    when 'dd'
      param_check_bool(db, ARGV[1], "delete diff", ARGV[2])
    when 'mp'
      param_check_string(db, ARGV[1], "manga path", ARGV[2])
    when 'bs'
      param_check_nb(db, ARGV[1], "between sleep", ARGV[2].to_f, 0.2)
    when 'fs'
      param_check_nb(db, ARGV[1], "failure sleep", ARGV[2].to_f, 0.2)
    when 'es'
      param_check_nb(db, ARGV[1], "error sleep", ARGV[2].to_f, 0.5)
    when 'nb'
      param_check_nb(db, ARGV[1], "number of tries", ARGV[2].to_i, 1)
    else
      puts "error, unknown parameter id : " + ARGV[1]
      puts "--help for help"
      exit 5
    end
  end
end

def param_reset()
  db = Params.new
  puts ""
  puts "WARNING ! You are about to reset your parameters !"
  puts "the parameters will be set to :"
  puts "manga path      = " + Dir.home + "/Documents/mangas/"
  puts "between sleep   = 0.2"
  puts "failure sleep   = 0.2"
  puts "number of tries = 20"
  puts "error sleep     = 30"
  puts "delete diif     = true"
  puts ""
  puts "Write 'YES' to continue"
  ret = STDIN.gets.chomp
  puts ""
  if (ret == "YES")
    db.reset_parameters()
    puts "reset all parameters"
  else
    puts "did not reset parameters"
  end
end
