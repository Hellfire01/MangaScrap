# this is the class that manages all of the compatible websites ( chooses witch class to use / gives the directory / ... )
class Web_data
  include Singleton

  attr_reader :sites

  private
  # private instance methods
  def initialize
    @sites = []
    @sites << Struct::Website.new('http://mangafox.la/', %w(http://mangafox.la mangafox.la mangafox),
                                  'mangafox/', 'manga/', Download_Mangafox)
    @sites << Struct::Website.new('http://www.mangareader.net/', %w(http://www.mangareader.net www.mangareader.net mangareader.net mangareader),
                                  'mangareader/', '', Download_Mangareader_Pandamanga)
    @sites << Struct::Website.new('http://www.mangapanda.com/', %w(http://www.mangapanda.com www.mangapanda.com mangapanda.com mangapanda),
                                  'mangapanda/', '', Download_Mangareader_Pandamanga)
  end

  public
  # public static methods

  def extract_values_from_link(link)
    # get site
    # throw exception if bad site
    # call static method of download class
  end

  # ensures that the link is correct to avoid pointless redirection
  # ex : a missing '/' at the end of the link can cause a redirection
  # and then extracts the name and the site
  def get_web_info_from_link(data, display)
    unless data[:link].start_with?('http://', 'https://')
      data[:link] = 'http://' + data[:link]
    end
    unless data[:link].end_with?('/')
      data[:link] += '/'
    end
    buff = data[:link].split('/')
    tmp_site = buff[2]
    data[:website] = is_site_compatible?(tmp_site, display)
    if data[:website] == nil
      return false
    end
    if data[:website][:to_complete] == ''
      data[:name] = buff[3]
    else
      data[:name] = buff[4]
    end
    data[:link] = data[:website][:link] + data[:website][:to_complete] + data[:name] + '/'
    true
  end

  # gets the name of the manga / light novel / ... from the link
  def self.extract_name_from_link(link)
    tmp = link.gsub('http://', '')
    tmp = tmp.gsub('https://', '')
    site_string = extract_site_from_link(link)
    site = instance.get_site(site_string)
    if site == nil
      return nil
    end
    if site[:to_complete] == ''
      return tmp.split('/')[1]
    else
      return tmp.split('/')[2]
    end
  end

  # gets the site of the manga / light novel / ... from the link
  # may need to be adapted if the first element of the url is not the name of the site ( seems unlikely )
  def self.extract_site_from_link(link)
    tmp = link.gsub('http://', '')
    tmp = tmp.gsub('https://', '')
    tmp.split('/').first
  end

  # public instance methods

  # returns the Website structure if it found a match else returns nil
  def get_site(site_string)
    @sites.each do |site|
      if site[:link] == site_string || site[:aliases].include?(site_string)
        return site
      end
    end
    nil
  end

  # check if the site is managed and correct it to be compatible with the DB
  def is_site_compatible?(site_link, display)
    site = get_site(site_link)
    if site == nil
      puts 'Data error '.red + '(invalid website) :' + ' the website ' + site_link.yellow + ' is unmanaged' if display
    end
    site
  end

  # returns an array of the sites that MangaScrap currently manages
  def get_compatible_sites
    ret = []
    @sites.each do |site|
      ret << site[:link]
    end
    ret
  end

  # returns the directory of the website
  def get_dir_from_site(site_string)
    site = get_site(site_string)
    if site == nil
      # return nil or an error
    end
    site[:dir]
  end

end
