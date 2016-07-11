def db_error_exit(message, error)
  puts message
  puts "message is : '" + error.message + "'"
  exit 2
end
