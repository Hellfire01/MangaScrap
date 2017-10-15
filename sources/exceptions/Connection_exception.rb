# custom exception class to deal with connection issues and display more information

class Connection_exception < StandardError
  attr_reader :data

  def initialize(data)
    @data = data
  end
end
