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

def param_set()
  db = Params.new()
  if (ARGV.size < 3)
    puts "not enought arguments for parameter set"
    puts "--help for help"
  else
    case ARGV[1]
    when 'mp'
      if (ARGV[2].size == 0)
	puts "the manga path cannot be empty"
      else
	db.set_params_path(ARGV[2])
	puts "updated manga path to '#{ARGV[2]}'"
      end
    when 'bs'
      if (ARGV[2].size == 0)
	puts "you need to give a value"
      else
	tmp = ARGV[2].to_f
	if (tmp < 0.2)
	  puts "the 'between sleep' value canot be < 0.2"
	else
	  db.set_params_between_sleep(tmp)
	  puts "updated between sleep to " + ARGV[2]
	end
      end
    when 'fs'
      if (ARGV[2].size == 0)
	puts "you need to give a value"
      else
	tmp = ARGV[2].to_f
	if (tmp < 0.2)
	  puts "the 'failure sleep' value canot be < 0.2"
	else
	  db.set_params_failure_sleep(tmp)
	  puts "updated failure sleep to " + ARGV[2]
	end
      end
    when 'nb'
      if (ARGV[2].size == 0)
	puts "you need to give a value"
      else
	tmp = ARGV[2].to_i
	if (tmp < 1)
	  puts "the 'number of tries' value canot be < 1"
	else
	  db.set_params_nb_tries(tmp)
	  puts "updated number of tries to " + ARGV[2]
	end
      end
    when 'es'
      if (ARGV[2].size == 0)
	puts "you need to give a value"
      else
	tmp = ARGV[2].to_f
	if (tmp < 0.5)
	  puts "the 'error sleep' value canot be < 0.5"
	else
	  db.set_params_error_sleep(tmp)
	  puts "updated failure sleep to " + ARGV[2]
	end
      end
    when 'dd'
      if (ARGV[2].size == 0)
	puts "you need to give a value"
      else
	tmp = ARGV[2]
	if (tmp != "true" && tmp != "false")
          puts "argument must be 'true' or 'false'"
	else
	  db.set_params_delete_diff(tmp)
	  puts "updated delete diff to " + ARGV[2]
	end
      end
    else
      puts "error, unknown parameter id : " + ARGV[1]
      puts "--help for help"
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
