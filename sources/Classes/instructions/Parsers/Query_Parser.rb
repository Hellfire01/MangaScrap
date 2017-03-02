class Query_Parser
  private

  public
  def run(query)
    @query = query
    pp @query
  end

  # adds instruction with a block
  def on(instruction, arguments, is_array_in_db = false, &bloc)
    @instructions[instruction] = [arguments, is_array_in_db, bloc]
  end

  def initialize
    @instructions = {}
    @query = []
  end
end
