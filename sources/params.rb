def param_list()
  db = Params.instance()
  params = db.get_params()
  params_template = File.open(Dir.home + "/.MangaScrap/templates/params.txt").read
  params_template = params_template.gsub('#{params[1]}', params[1])
  params_template = params_template.gsub('#{params[2]}', params[2].to_s)
  params_template = params_template.gsub('#{params[3]}', params[3].to_s)
  params_template = params_template.gsub('#{params[4]}', params[4].to_s)
  params_template = params_template.gsub('#{params[5]}', params[5].to_s)
  params_template = params_template.gsub('#{params[6]}', params[6])
  params_template = params_template.gsub('#{params[7]}', params[7])
  params_template = params_template.gsub('#{params[8]}', params[8])
  params_template = params_template.gsub('#{params[9]}', params[9])
  params_template = params_template.gsub('#{params[10]}', params[10])
  puts params_template
end

def param_critical_error(param, func)
  puts "Error : the " + param + " ended in the wrong function (" + func + ")"
  puts "This is a Mangascrap error, please report it"
  puts "( unless you caused it by altering the code )"
  exit(4)
end

def param_check_nb(db, param, disp, value, min_value)
  if (value < min_value)
    puts "the '" + disp[0] + "' value canot be < " + min_value.to_s
    exit(5)
  end
  db.set_param(disp[1], value)
  puts "updated " + disp[0] + " param to " + value.to_s
end

def param_check_bool(db, param, disp, value)
  if (value != "true" && value != "false")
    puts "argument must be 'true' or 'false'"
    exit 5
  end
  db.set_param(disp[1], value)
  puts "updated " + disp[0] + " to " + value
end

def param_check_string(db, param, disp, value)
  case param
  when 'mp'
    if value[0, 1] != '~' && value[0, 1] != '/'
      puts "cannot create local directory"
      exit 5
    end
    begin
      dir_create(value)
    rescue StandardError => error
      puts "could not create requested path"
      puts "error message is : '" + error.message + "'"
      exit 5
    end
    db.set_param(disp[1], value)
  when 'nd'
    puts "nsfw genres are : \n\n" + value.split(", ").join("\n") + "\n\n"
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ""
    if (ret == "YES")
      db.set_param(disp[1], value)
    else
      puts "did not updtate"
      return
    end
  else
    param_critical_error(param, "param_check_string")
  end
  puts "updated " + disp[0] + " to " + value
end

def args_check()
  if (ARGV.size < 3)
    puts "not enought arguments for parameter set"
    puts "--help for help"
    exit 5
  end
  if ARGV[2].size == 0
    puts "you cannot give an empty argument"
    exit 5
  end
end

def param_set()
  db = Params.instance()
  args_check()
  case ARGV[1]
  when 'dd'
    param_check_bool(db, ARGV[1], ["delete diff", "delete_diff"], ARGV[2])
  when 'ce'
    param_check_bool(db, ARGV[1], ["catch exception", "catch_execption"], ARGV[2])
  when 'mp'
    param_check_string(db, ARGV[1], ["manga path", "manga_path"], ARGV[2])
  when 'bs'
    param_check_nb(db, ARGV[1], ["between sleep", "between_sleep"], ARGV[2].to_f, 0.1)
  when 'fs'
    param_check_nb(db, ARGV[1], ["failure sleep", "failure_sleep"], ARGV[2].to_f, 0.1)
  when 'es'
    param_check_nb(db, ARGV[1], ["error sleep", "error_sleep"], ARGV[2].to_f, 0.5)
  when 'nb'
    param_check_nb(db, ARGV[1], ["number of tries", "nb_tries_on_fail"], ARGV[2].to_i, 1)
  when 'gh'
    param_check_bool(db, ARGV[1], ["generate html", "generate_html"], ARGV[2])
  when 'hn'
    param_check_bool(db, ARGV[1], ["html nsfw", "html_nsfw"], ARGV[2])
  when 'nd'
    param_check_string(db, ARGV[1], ["nsfw data", "html_nsfw_data"], ARGV[2])
  else
    puts "error, unknown parameter id : " + ARGV[1]
    puts "--help for help"
    exit 5
  end
end

def param_reset()
  db = Params.instance
  puts ""
  puts "WARNING ! You are about to reset your parameters !"
  puts "the parameters will be set to :"
  puts "manga path      = " + Dir.home + "/Documents/mangas/"
  puts "between sleep   = 0.1"
  puts "failure sleep   = 0.1"
  puts "number of tries = 20"
  puts "error sleep     = 30"
  puts "delete diff     = true"
  puts "catch ecxeption = true"
  puts "generate html   = true"
  puts "html nsfw       = true"
  puts "html nsfw data  = Ecchi, Mature, Smut, Adult"
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
