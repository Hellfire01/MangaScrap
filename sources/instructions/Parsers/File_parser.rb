class File_parser
  private
  # extracting all the elements from the file
  # ignores empty lines and commented ones
  def parse_file
    line_count = 0
    @text.each_line do |line|
      if line == nil || line == '' || line.size == 0 || line[0] == '#' || line[0] == "\n"
        next
      end
      elements = line.split(' ')
      if elements.size > 2
        puts 'Waring : '.red + 'in file "' + @file_name.yellow + '" ignoring line ' + line_count.to_s.yellow + ' ( it has more than one space and is not a comment )'
      else
        if elements.size == 1
          @ret << Manga_data.new(nil, nil, nil, elements[0], nil)
        else
          @ret << Manga_data.new(nil, elements[0], elements[1], nil, nil)
        end
      end
      line_count += 1
    end
  end

  # file opening with exception handling
  def open_file
    begin
      @text = File.open(@file_name).read
      @text.gsub!(/\r\n?/, '\n')
    rescue => e
      critical_error('could not open file ' + @file_name.yellow, e)
    end
    true
  end

  def run
    if open_file && parse_file
      @status = true
    end
  end

  public
  # this function allows to know if the data whas correctly extracted from the file or not
  def good
    @status
  end

  def initialize(file_name, array)
    @file_name = file_name
    @ret = array
    @text = nil
    @status = false
    run
  end
end
