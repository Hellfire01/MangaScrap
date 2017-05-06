# the files of this file are used to "translate" arguments into usable data
# print error and leave

module Utils_errors
  def self.critical_error(message, error = nil)
    puts ''
    puts 'Critical Error : ' .red + message
    if error != nil
      puts 'error type is : ' + error.class.to_s.yellow
      puts 'message is : "' + error.message.yellow + '"'
    end
    puts "\ncaller backtrace :".yellow
    puts caller
    puts "\nplease report this on github (unless you edited the code)\n\n".yellow
    exit 4
  end
end
