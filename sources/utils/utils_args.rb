# the files of this file are used to "translate" arguments into usable data
# print error and leave

def get_dir_from_site(site)
  case site
    when 'mangafox', 'mangafox.me', 'http://mangafox.me', 'http://mangafox.me/'
      return 'mangafox/'
    else
      critical_error('the function get_dir_from_site was called with a bad argument (' + site.yellow + ')')
  end
end

def critical_error(message, error = nil)
  puts 'Critical Error : ' .red + message
  if error != nil
    puts 'error type is : ' + error.class.to_s
  end
  puts "\ncaller backtrace :".yellow
  puts caller
  puts "\nplease report this on github (unless you edited the code)\n\n".yellow
  exit 4
end
