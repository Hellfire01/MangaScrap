=begin
this class is used to ensure that only the required Manga_data are used by the
instructions's functions.
The instructions are in 2 distinct groups :
- those that need data from the database
- Those that need data from internet
=end
class Manga_data_filter
  private
  def add_to_return(todo)
    # checking if the data is not already in the new array to avoid duplicates
    if @ret.select{|elem| elem.link == todo.link}[0] == nil
      @ret << todo
    end
  end

  def connection(data_display)
    @array.each do |todo|
      if todo.resolve(true, data_display)
        add_to_return(todo)
      else # the data cannot be resolved, ignoring it
        next
      end
    end
  end

  def no_connection(data_display)
    @array.each do |todo|
      if todo.in_db
        add_to_return(todo)
      elsif todo.resolve(false, data_display)
        add_to_return(todo)
      else # the data cannot be resolved, ignoring it
        next
      end
    end
  end

  public
  # function used to filter the array and return the "good" array
  def run(connect, data_display)
    if connect
      connection(data_display)
    else
      no_connection(data_display)
    end
    @ret.sort{|a, b| a.link <=> b.link}
    @ret
  end

  def initialize(array)
    @array = array
    @ret = []
    @db = Manga_database.instance
  end
end
