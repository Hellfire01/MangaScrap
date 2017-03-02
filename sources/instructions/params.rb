# reading the file, adding DB values and setting the colors ( when needed )
def param_list
  params = Params.instance.get_params
  template = File.open('templates/params.txt').read
  template = template.gsub('#{params[1]}', params[1].green)
  template = template.gsub('#{params[2]}', params[2].to_s.green.to_s)
  template = template.gsub('#{params[3]}', params[3].to_s.green.to_s)
  template = template.gsub('#{params[4]}', params[4].to_s.green.to_s)
  template = template.gsub('#{params[5]}', params[5].to_s.green.to_s)
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
  template = template.gsub('(ct)', '(ct)'.red)
  puts template
end

# this function should never be called, when called there is an error in the code
def param_critical_error(param, func)
  puts 'Error : the ' + param + ' ended in the wrong function (' + func + ')'
  puts 'This is a Mangascrap error, please report it'
  puts '( unless you caused it by altering the code )'
  exit(4)
end

# params set for numbers
def param_check_nb(db, param, display, value, min_value)
  if value < min_value
    puts "the '" + display[0] + "' value cannot be < " + min_value.to_s + 'for ' + param
    exit(5)
  end
  db.set_param(display[1], value)
  puts 'updated ' + display[0] + ' param to ' + value.to_s
end

# params set for booleans
def param_check_bool(db, param, display, value)
  if value != 'true' && value != 'false'
    puts "argument must be 'true' or 'false' for " + param
    exit 5
  end
  db.set_param(display[1], value)
  puts 'updated ' + display[0] + ' to ' + value
end

# params set for strings
def param_check_string(db, param, display, value)
  case param
  when 'mp'
    if value[0, 1] != '~' && value[0, 1] != '/'
      puts 'cannot create local directory'
      exit 5
    end
    begin
      dir_create(value)
    rescue StandardError => error
      puts 'could not create requested path'
      puts "error message is : '" + error.message + "'"
      exit 5
    end
    db.set_param(display[1], value)
  when 'nd'
    puts 'nsfw genres are : \n\n' + value.split(', ').join('\n') + '\n\n'
    puts "Write 'YES' to continue"
    ret = STDIN.gets.chomp
    puts ''
    if ret == 'YES'
      db.set_param(display[1], value)
    else
      puts 'did not update'
      return
    end
  else
    param_critical_error(param, 'param_check_string')
  end
  puts 'updated ' + display[0] + ' to ' + value
end

# checking arguments for params
def args_check(args)
  if args.size < 3
    puts 'not enough arguments for parameter set'
    puts '--help for help'
    exit 5
  end
  if args[2].size == 0
    puts 'you cannot give an empty argument'
    exit 5
  end
end

# this function call the good params set function for the good variable type
def param_set(args)
  db = Params.instance
  args_check(args)
  case args[1]
  when 'dd'
    param_check_bool(db, args[1], ['delete diff', 'delete_diff'], args[2])
  when 'ce'
    param_check_bool(db, args[1], ['catch exception', 'catch_execption'], args[2])
  when 'mp'
    param_check_string(db, args[1], ['manga path', 'manga_path'], args[2])
  when 'bs'
    param_check_nb(db, args[1], ['between sleep', 'between_sleep'], args[2].to_f, 0.1)
  when 'fs'
    param_check_nb(db, args[1], ['failure sleep', 'failure_sleep'], args[2].to_f, 0.1)
  when 'es'
    param_check_nb(db, args[1], ['error sleep', 'error_sleep'], args[2].to_f, 0.5)
  when 'nb'
    param_check_nb(db, args[1], ['number of tries', 'nb_tries_on_fail'], args[2].to_i, 1)
  when 'gh'
    param_check_bool(db, args[1], ['generate html', 'generate_html'], args[2])
  when 'hn'
    param_check_bool(db, args[1], ['html nsfw', 'html_nsfw'], args[2])
  when 'nd'
    param_check_string(db, args[1], ['nsfw data', 'html_nsfw_data'], args[2])
  when 'ct'
    param_check_bool(db, args[1], ['color text', 'color_text'], args[2])
  else
    puts 'error, unknown parameter id : ' + args[1]
    puts '--help for help'
    exit 5
  end
end

# used to check if the user really wants to reset
def param_reset
  db = Params.instance
  puts ''
  puts 'WARNING ! You are about to reset your parameters !'
  puts 'the parameters will be set to :'
  puts 'manga path      = ' + (Dir.home + '/Documents/mangas/').yellow
  puts 'between sleep   = ' + '0.1'.yellow
  puts 'failure sleep   = ' + '0.1'.yellow
  puts 'number of tries = ' + '20'.yellow
  puts 'error sleep     = ' + '30'.yellow
  puts 'delete diff     = ' + 'true'.yellow
  puts 'catch exception = ' + 'true'.yellow
  puts 'generate html   = ' + 'true'.yellow
  puts 'html nsfw       = ' + 'true'.yellow
  puts 'html nsfw data  = ' + 'Ecchi, Mature, Smut, Adult'.yellow
  puts 'color text      = ' + 'true'.yellow
  puts ''
  puts "Write 'YES' to continue"
  ret = STDIN.gets.chomp
  puts ''
  if ret == 'YES'
    db.reset_parameters
    puts 'reset all parameters'
  else
    puts 'did not reset parameters'
  end
end

def params_management(args)
  case args[0]
    when 'list'
      param_list
    when 'reset'
      param_reset
    when 'set'
      param_set(args)
    else
      puts 'Error : '.red + 'unrecognised argument ' + args[0].yellow + ' for params'
      puts './MangaScrap help'.yellow + ' for help'
  end
end