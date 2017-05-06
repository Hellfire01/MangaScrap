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
  attr_reader :to_complete, :link, :name, :site_dir, :id, :site, :data, :status, :in_db

  private
  # ensures that the link starts with http or https
  def link_correction
    unless @link.start_with?('http://', 'https://')
      @link = 'http://' + @link
    end
  end

  # see if the link exists ( is it redirected ? )
  def check_link(display)
    if @link == nil
      @link = @site + @to_complete + @name
      if @name.count('/') == 0
        @link += '/'
      end
    end
    if Utils_connection::redirection_detection(@link)
        puts 'Warning :'.yellow + ' could not connect to ' + @link.yellow if display
      return false
    end
    true
  end

  # todo: currently only usable with mangafox
  # gets the name of the manga / light novel / ... from the link
  def extract_name_from_link(link)
    tmp = link.gsub('http://', '')
    tmp = tmp.gsub('https://', '')
    tmp.split('/').last
  end

  # todo: the function may need to be further improved for other sites
  # gets the site of the manga / light novel / ... from the link
  def extract_site_from_link(link)
    tmp = link.gsub('http://', '')
    tmp = tmp.gsub('https://', '')
    tmp.split('/').first
  end

  # if the manga is already in the database, get all the information
  def get_data_in_db
    ret = Manga_database.instance.get_manga(self)
    if ret != nil
      @status = true
      @in_db = true
      @data = ret
      @link = ret[4]
      @id = ret[0]
      true
    else
      false
    end
  end

  # check if the site is managed and correct it to be compatible with the DB
  def is_site_compatible?(display)
    case @site
      when 'http://mangafox.me/', 'http://mangafox.me', 'mangafox.me', 'mangafox'
        @site = 'http://mangafox.me/'
        @to_complete = 'manga/'
      when 'http://www.mangareader.net/', 'http://www.mangareader.net', 'www.mangareader.net', 'mangareader.net', 'mangareader'
        @site = 'http://www.mangareader.net/'
        @to_complete = ''
      when 'http://www.mangapanda.com/', 'http://www.mangapanda.com', 'www.mangapanda.com', 'mangapanda.com', 'mangapanda'
        @site = 'http://www.mangapanda.com/'
        @to_complete = ''
      else
        puts 'Data error '.red + '(invalid link) :' + ' the site ' + @site.yellow + ' is unmanaged' if display
        return false
    end
    if @link == nil
      @link = @site + @to_complete + @name
    end
    @site_dir = Manga_data::get_dir_from_site(@site)
    true
  end

  public
  # returns an array of the sites that MangaScrap currently manages
  def self.get_compatible_sites
    %w(http://mangafox.me/ http://www.mangareader.net/ http://www.mangapanda.com/)
  end

  def self.get_dir_from_site(site)
    case site
      when 'http://mangafox.me/', 'http://mangafox.me', 'mangafox.me', 'mangafox'
        return 'mangafox/'
      when 'http://www.mangareader.net/', 'http://www.mangareader.net', 'mangareader.net', 'mangareader'
        return 'mangareader/'
      when 'http://www.mangapanda.com/', 'http://www.mangapanda.com', 'mangapanda.com', 'mangapanda'
        return 'mangapanda/'
      else
       Utils_errors::critical_error('the function get_dir_from_site was called with a bad argument (' + site.yellow + ')')
    end
  end

  def to_s
    'link = ' + ((@link == nil) ? '/' : '"' + @link + '"') + ', name = ' + ((@name == nil) ? '/' : '"' + @name + '"') +
      ', site = ' + ((@site == nil) ? '/' : '"' + @site + '"')
  end

  # used to get an array containing the volume / chapter / page values from a link
  # will exit if the resolve method was not called before and did not return true
  def extract_values_from_link(link)
    unless @status
     Utils_errors::critical_error('the extract_values_from_link method was called when the data class was not resolved or invalid')
    end
    case @site
      when 'http://mangafox.me/'
        Utils_website_specific::Mangafox::data_extractor(link)
      when 'http://www.mangareader.net/', 'http://www.mangapanda.com/'
        Utils_website_specific::Mangareader_Mangapanda::data_extractor(link)
      else
       Utils_errors::critical_error('extract_values_from_link function was called with an unknown site (' + @site.yellow + ') value')
    end
  end

  # returns the class used to download the manga
  # will exit if the resolve method was not called before and did not return true
  def get_download_class(download_data = true)
    unless @status
     Utils_errors::critical_error('the get_download_class method was called when the data class was not resolved or invalid')
    end
    if @download_class == nil
      begin
        case @site
          when 'http://mangafox.me/'
            return Download_Mangafox.new(self, download_data)
          when 'http://www.mangareader.net/', 'http://www.mangapanda.com/'
            return Download_Mangareader_Pandamanga.new(self, download_data)
          else
           Utils_errors::critical_error('the data class tried to get a download class that does not exist for the site "' + @site.yellow + '"')
        end
      rescue => e
        puts 'Exception while trying to get '.red + @name.yellow
        puts 'reason is : '.yellow + e.message
        return nil
      end
    end
    @download_class
  end

  # the function resolve will try to complete the missing information
  # for that it will connect to the database and check or look online unless get_data_in_db
  # please note that the function will exit if the constructor was not called with the good arguments
  # connect = bool, determines if the class can try to use internet if it could not find in the database
  # display = bool, used to allow writing on the standard output or not
  def resolve(connect, display)
    if @status
      return true
    end
    if @name != nil && @site != nil # got manga_data with id
      unless is_site_compatible?(display)
        return false
      end
    elsif @link != nil # got manga_data with link
      link_correction
      @site = extract_site_from_link(@link)
      @name = extract_name_from_link(@link)
      unless is_site_compatible?(display)
        return false
      end
    else # Error => the data was not fed correctly to the class
      pp self
      puts ''
     Utils_errors::critical_error('the data class was called with incorrect parameters')
    end
    ret = get_data_in_db
    if !ret && connect # if it is not in the database and a connection is required, then it is good
      if check_link(display)
        @status = true
        return true
      end
      return false
    end
    if ret && connect # if connect is true, the manga should not be found in the database
      puts 'Warning :'.yellow + ' ' + @name + ' of ' + @site + ' is already in the database, ignoring it'
      return false
    end
    if !ret && !connect # if connect is false, it should be in the database
      puts 'Warning :'.yellow + ' ' + @name + ' of ' + @site + ' is not in the database, ignoring it'
      return false
    end
    # should the manga not be in the database and Manga_data require connection,
    #    it will try to valid / invalid the link
    if !ret && connect && @link != nil && !check_link(display)
      false
    else
      ret
    end
  end

  # the constructor takes multiple arguments but they should not all be given at once unless the data comes from the database
  # id = int / nil, is the id used in the database
  # name = string / nil, is the name used in the url of the manga
  # site = string / nil, is the name of the website hosting the manga
  # link = string / nil, is the url of the manga
  # data = array of elements / nil, the array contains the line of the manga in the database
  def initialize(id, name, site, link, data)
    @name = name
    @site = site
    @link = link
    @id = id
    @data = data
    # should the data come from the database it will be ready
    @status = (id != nil && name != nil && site != nil && link != nil && data != nil)
    @site_dir = ''
    @to_complete = ''
    @in_db = @status
    @download_class = nil
    if @in_db
      is_site_compatible?(false) # function used here to get @site_dir and @ to_complete
    end
  end
end
