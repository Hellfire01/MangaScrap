#!/usr/bin/env ruby
# coding: utf-8

# this script should only be used if there is an issue with multiple file names
pattern_to_replace = "****"
replacing_pattern = "####"
dirs = Dir["/home/matthieu/Documents/mangas/mangafox/mangas/*"]
dirs.delete_if {|dir| dir.include?(".jpg")}
dirs.sort.each do |dir|
  puts dir
  files = Dir[dir + "/*"]
  files.sort.each do |file|
    if (File.basename(file).include?(pattern_to_replace))
      puts "replacing " + file + " with " + file.gsub(pattern_to_replace, replacing_pattern)
      File.rename(file, file.gsub(pattern_to_replace, replacing_pattern))
    end
  end
end
