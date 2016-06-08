def help()
  begin
    file = File.open("help.txt", "r")
    content = file.read
    puts content
  rescue Errno::ENOENT => e
    puts "could not open help file"
    puts e.message
  end
end
