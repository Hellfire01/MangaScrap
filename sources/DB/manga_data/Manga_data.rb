=begin
This class encapsulates the database line of a manga / light novel / ...
It's main purpose is to get all the missing data from a user input

note : this class is absolutely crucial for MangaScrap

To do so it will first try to see if it can find the data in the database
if it cannot, it will try to see if the data is valid by connecting to the internet

the resolve function is the one that executes all of those actions, it returns
false if it could not validate the data
=end

class Manga_data
  private
  # if the manga is already in the database, get all the information
  # there is no need to re-get the name and site as they are used to get all of the elements
  def get_data_in_db
    ret = Manga_database.instance.get_manga(self)
    if ret != nil
      @data[:status] = true
      @data[:in_db] = true
      @data[:data] = ret
      @data[:link] = ret[4]
      @data[:id] = ret[0]
      true
    else
      false
    end
  end

  # the function extract_data will try to complete the missing information
  # the function will exit if the constructor was not called with the good arguments
  def extract_data(display)
    if @data[:status]
      return true
    end
    if @data[:name] != nil && @buff_site != nil # got manga_data with id
      @data[:website] = Web_data.instance.is_site_compatible?(@buff_site, display)
      if @data[:website] == nil
        return false
      end
      @data[:link] = @data[:website][:link] + @data[:website][:to_complete] + @data[:name] + '/'
    elsif @data[:link] != nil # got manga_data with link
      unless Web_data.instance.get_web_info_from_link(@data, display)
        return false
      end
    else # Error => the data was not fed correctly to the class
      pp self
      puts ''
      Utils_errors::critical_error('the data class was called with incorrect parameters')
    end
    true
  end

  # checks if the data is in the database or not and if it should be that way
  def validate_data(connect, display)
    ret = get_data_in_db
    if !ret && connect # if it is not in the database and a connection is required, then it is good
      if get_index(display)
        @data[:status] = true
        return true
      end
      return false
    end
    if ret && connect # if connect is true, the manga should not be found in the database
      puts 'Warning :'.yellow + ' ' + @data[:name] + ' / ' + @data[:link] + ' is already in the database, ignoring it'
      return false
    end
    if !ret && !connect # if connect is false, it should be in the database
      puts 'Warning :'.yellow + ' ' + @data[:name] + ' / ' + @data[:link] + ' is not in the database, ignoring it'
      return false
    end
    # should the manga not be in the database and Manga_data require connection,
    #    it will try to valid / invalid the link
    if !ret && connect && @data[:link] != nil && !get_index(display)
      false
    else
      ret
    end
  end

  # returns the class used to download the manga
  # will exit if the resolve method was not called before and did not return true
  def get_download_class
    begin
      @data[:download_class] = @data[:website][:class].new(self)
    rescue RuntimeError => e
      puts 'Exception while trying to get '.red + @data[:name].yellow + ' (' + e.message + ')'
      return nil
    rescue ArgumentError => e
      puts 'Exception while trying to get '.red + @data[:name].yellow
      Utils_errors::critical_error('Argument error ( something is wrong with the code )', e)
    rescue => e
      puts 'Exception while trying to get '.red + @data[:name].yellow
      puts 'exception is : ' + e.class.to_s
      puts 'reason is : '.yellow + e.message
      return nil
    end
  end

  public
  # this method ensures that all of the data is correct
  # connect = bool, determines if the class can try to use internet if it could not find in the database
  # display = bool, used to allow writing on the standard output or not
  def resolve(connect, display)
    @data[:status] = extract_data(display) && validate_data(connect, display)
    if @data[:status]
      get_download_class
    end
    @data[:status]
  end

  def to_s
    'link = ' + ((@data[:link] == nil) ? '/' : '"' + @data[:link] + '"') + ', name = ' + ((@data[:name] == nil) ? '/' : '"' + @data[:name] + '"') +
      ', site = ' + ((@data[:website] == nil) ? '/' : '"' + @data[:website] + '"')
  end

  # tries to get the index page and sees if the link exists ( is it redirected ? )
  def get_index(display)
    if @data[:link] == nil
      @data[:link] = @data[:website][:link] + @data[:website][:to_complete] + @data[:name]
    end
    begin
      @data[:index_page] = Utils_connection::get_page(@data[:link], Download_type::INDEX, true) if @data[:index_page] == nil
    rescue Connection_exception => e
      if display
        puts 'Error'.red + ' while trying to get ' + @data[:name].red + " chapter's index"
        puts 'Message : ' + e.data[:message].yellow + (e.data[:http_code] != -1 ? ' Code : ' + e.data[:http_code].to_s.yellow : '')
        puts 'Link : ' + e.data[:link].yellow if e.data[:http_code] == 301 || e.data[:http_code] == 302
      end
      return false
    end
    true
  end

  # used to get an array containing the volume / chapter / page values from a link
  # will exit if the resolve method was not called before and did not return true
  def extract_values_from_link(link)
    if @data[:status] == nil
      Utils_errors::critical_error('the extract_values_from_link method was called when the data class was invalid or not resolved')
    end
    @data[:website][:class]::data_extractor(link)
  end

  # only setter for Manga_data to allow write access on @data[:index_page] and avoid it being downloaded twice
  def set_index_page(index_page)
    @data[:index_page] = index_page
  end

  # overload of the [] to allow direct read access to the @data
  def [](param)
    @data[param]
  end

  # the constructor takes multiple arguments but they should not all be given at once unless the data comes from the database
  # id = int / nil, is the id used in the database
  # name = string / nil, is the name used in the url of the manga
  # site = string / nil, is the name of the website hosting the manga
  # link = string / nil, is the url of the manga
  # data = array of elements / nil, the array contains the line of the manga in the database
  # sites = array of Website structures containing
  def initialize(id, name, site, link, data)
    # should the data come from the database it will be ready
    status = (id != nil && name != nil && site != nil && link != nil && data != nil)
    @buff_site = site
    @data = Struct::Manga_data_values.new(name, link, id, status, nil, data, nil, nil, nil)
    if @data[:status]
      @data[:website] = Web_data.instance.is_site_compatible?(site, false)
    end
  end
end
