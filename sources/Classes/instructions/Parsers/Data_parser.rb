# this class is used to cut the arguments given to MangaScrap and allow
class Data_parser
  private
  # executes the previously parsed arguments
  def run
    @to_exec.each do |args|
      @instructions[args[0]][1].call args[1]
    end
  end

  # function used to exit whenever there is not enought arguments for a data
  def nb_arguments_exit(arg, qt, count)
    puts 'Error :'.red + ' for instruction "' + @command.yellow + ' ' + @instruction.yellow + '"'
    puts arg.yellow + ' was given ' + count.to_s.yellow + ' argument(s), ' + qt.to_s.yellow + ' are required'
    exit 4
  end

  def bad_argument_exit(error)
    puts 'Error :'.red + ' for instruction "' + @command.yellow + ' ' + @instruction.yellow + '"'
    puts 'unrecognised argument "' + error.yellow + '"'
    exit 4
  end

  # the arguments are cut with the @instructions
  def args_extract(arg, qt)
    ret = [] # extracted arguments
    count = 0
    while @args.size != 0 && count < qt
      ret << @args[0]
      @args.shift
      count += 1
    end
    if count != qt
      nb_arguments_exit(arg, qt, count)
    end
    ret
  end

  public
  # gets an array of arguments and cuts it into more readable arrays witch are then used by run
  def parse(args)
    @args = args
    @instruction = args.join(' ')
    until @args.empty?
      arg = @args[0]
      if @instructions.key? arg
        @args.shift
        buff = args_extract(arg, @instructions[arg][0])
        @to_exec << [arg, buff]
      else
        bad_argument_exit(arg)
      end
    end
    run
  end

  # adds instruction with a block
  def on(instruction, arguments, &bloc)
    @instructions[instruction] = [arguments, bloc]
  end

  def initialize(command)
    @to_exec = []
    @instructions = {}
    @args = ''
    @command = command
    @instruction = ''
  end
end
