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

  def self.manage_redirection_error(manga_data)
    begin
      yield
    rescue => e
      puts ''
      puts 'Error :'.red
      puts 'Got redirected while downloading ' + manga_data[:name].yellow + "'s chapter index"
      puts 'It seems the link ' + manga_data[:link].yellow + ' is no longer valid'
      puts ''
      return false
    end
    return true
  end

  def self.manage_exceptions(manga_data)
    begin
      yield
    rescue => e
      puts 'Error'.red
      puts e.message
      return false
    end
    return true
  end
end
