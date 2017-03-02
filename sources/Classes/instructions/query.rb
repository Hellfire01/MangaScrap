#class used to get the mangas with the query option
class Query_Manager
  private
  def init_parser
    @parser.on('date', 'year') do |arg|

    end
    @parser.on('site', 'string') do |arg|

    end
    @parser.on('author', 'string', true) do |arg|

    end
    @parser.on('artist', 'string', true) do |arg|

    end
    @parser.on('genres', 'string', true) do |arg|

    end
    @parser.on('added', 'date') do |arg|

    end
    @parser.on('type', 'string') do |arg|

    end
    @parser.on('name', 'string') do |arg|

    end
    @parser.on('description', 'string') do |arg|

    end
  end

  public
  def run(query)
    @query = query.split(' ')
    @parser.run(@query)

  end

  def initialize
    @parser = Query_Parser.new
    @query = ''
    init_parser
  end
end
