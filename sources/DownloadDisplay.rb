# this class is used to manage the display of the Downloader classes
# at no moment does it take any decision, it only displays
# it's purpose is to store all the errors and stats and display them as one nice readable message
# the point of this class is to avoid giving to much useless information to the user

class DownloadDisplay
  # displays all errors and stats for a single chapter
  def dump_chapter
    printf "\n"
    STDOUT.flush
    if @ref[:pages] != 0
      puts ('downloaded ' + @ref[:pages].to_s + ' page' + ((@ref[:pages] > 1) ? 's' : '')).green
    end
    if @ref[:failed] != 0
      puts 'could not download '.yellow + @ref[:failed].to_s.red + ' out of '.yellow + @ref[:pages].to_s
      unless @todo
        puts 'all pages were added to the todo database'
      end
    end
    @ref[:failed] = 0
    @ref[:pages] = 0
  end

  # the introduction part of the dump() function
  def dump_introduced(end_space)
    if @introduced == true && @ref[:downloaded_page] == true
      puts ('downloaded a total of ' + @ref[:total_pages].to_s + ' page' + ((@ref[:total_pages] != 1) ? 's' : '')).green
      if @ref[:total_failed_pages] > 0
        puts @ref[:total_failed_pages].to_s.red + (' page' + ((@ref[:total_failed_pages] != 1) ? 's' : '') + ' could not be downloaded and ' + ((@total_failed_pages > 1) ? 'where' : 'was') + ' added to the todo database').yellow
      end
      @unmanaged_volume_types = []
      @ref[:total_failed_pages] = 0
      @ref[:failed] = 0
      @ref[:total_pages] = 0
      @ref[:pages] = 0
      puts 'downloaded missing chapters for '.green + @manga_data[:name].yellow
      unless end_space
        puts ''
        return true
      end
    end
    end_space
  end

  # displays all the stats for a manga update ( unmanaged links, failed pages, ... )
  def dump
    end_space = false
    if @unmanaged_volume_types.size != 0
      if !@introduced
        introduce_manga
        puts ''
      else
        puts ''
      end
      puts ('volumes / chapters could not be downloaded because the following volume values are not managed :').yellow
      @unmanaged_volume_types.each do |unmanaged|
        puts unmanaged.red
      end
      puts ''
    end
    end_space = dump_introduced(end_space)
    if @introduced == false && @unmanaged_volume_types.size == 0
      puts "no missing chapters for #{@manga_data[:name]}"
      if end_space
        puts ''
      end
    end
  end

  # prepares the todo display ( called at the beginning of todo )
  def prepare_todo
    @todo = true
    unless @introduced
      introduce_manga
    end
    puts ''
    puts 'downloading todo pages'.magenta
  end

  # called when an error occured while trying to download a todo element
  def todo_err(string, chapter = false)
    puts string.red
  end

  # this is called once the todo is done ( called at the end of todo )
  def end_todo
    @todo = false
    puts ''
    puts 'finished downloading todo pages'.magenta
    puts ''
  end

  # stores the unmanaged link value in @unmanaged_volume_type
  def unmanaged_link(link)
    case @manga_data[:website][:link]
    when 'http://mangafox.me/'
      link_split = link.split('/')
      value = link_split[link_split.size - 3]
      unless @unmanaged_volume_types.include?(value)
        @unmanaged_volume_types << value
      end
    else
      # unmanaged site
    end
  end

  # this function is only called when a chapter / page ... is updated
  def introduce_manga
    puts ''
    puts 'updating '.yellow + @manga_data[:name].blue + ' from '.yellow + @manga_data[:website][:link].blue
    @introduced = true
  end

  # this function is only called when a chapter / page ... is updated
  def introduce_chapter
    puts ''
    puts @prepare_chapter
  end

  # called as a chapter is about to be downloaded, DownloadDisplay them chooses to display it or not  
  def prepare_chapter(string)
    @prepare_chapter = string.yellow
    if @introduced
      puts ''
      puts @prepare_chapter
    end
  end

  # calls all the introduction functions
  def introduction
    introduce_manga
    introduce_chapter
  end

  # displays an error mark ( ex : X )
  def error_on_page_download(error = 'X')
    unless @introduced
      introduction
    end
    # depending on the error message a different character can be displayed
    printf error.red
    STDOUT.flush
    @ref[:total_failed_pages] += 1
    @ref[:failed] += 1
  end

  # normal display for a downloaded page
  def downloaded_page(page_nb)
    unless @introduced
      introduction
    end
    if page_nb > 1
      if page_nb % 50 == 0
        printf ';'
      elsif page_nb % 10 == 0
        printf ','
      else
        printf '.'
      end
    else
      printf '.'
    end
    STDOUT.flush
    @ref[:total_pages] += 1
    @ref[:pages] += 1
    @ref[:downloaded_page] = true
  end

  # display for when the data of a manga is downloaded
  def data_disp(is_in_db)
    puts 'extracted data for ' + @manga_data[:name]
    unless is_in_db
      puts ("added #{@manga_data[:name]} to database").yellow
    end
  end

  # the name of the targeted site of the downloader is required
  # ex : Download_Mangafox => "mangafox"
  def initialize(manga_data)
    @unmanaged_volume_types = []
    @ref = Struct::Download_display_ref.new(0, 0, 0, 0, false)
    @introduced = false
    @manga_data = manga_data
    @prepare_chapter = ''
    @todo = false
  end
end
