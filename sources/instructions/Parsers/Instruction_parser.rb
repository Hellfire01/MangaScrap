# this class is used to cut the arguments given to MangaScrap and allow
class Instruction_parser
  private
  # function used to exit whenever there is not enough argument for a 'jump'
  # jump : number of arguments required
  # prev : the argument
  # parent : the instruction
  def jump_error_exit(data_argument, jump, parent)
    puts 'Error : '.red + data_argument.yellow + ' requires ' + jump.to_s.yellow + ' more argument(s)'
    puts 'in : [' + parent + ']'
    case prev
      when 'id'
        puts 'id '.yellow + 'requires a ' + 'name'.blue + ' ( first argument ) and a ' + 'site'.blue + ' ( second argument )'
      else
        # other instructions
    end
    exit 4
  end

  # executes the previously parsed arguments
  def run
    lock = true
    @to_exec.each do |args|
      buff = args
      if lock
        lock = false
        puts ''
      else
        puts '', '', '', '', ''
      end
      display = 'executing : ' + buff[0].green + ' ' + buff[1].join(' ') + ' '
      @jump.each do |e|
        display = display.gsub(' ' + e[0] + ' ', ' ' + e[0].yellow + ' ') # todo improve this to avoid colorizing arguments
      end
      puts display
      puts ''
      @instructions[args[0]].call args[1]
    end
  end

  # the arguments are cut with the @instructions
  # the @jump variables are used to allow arguments ( such as a file name ) to have
  #    values as instructions
  def args_extract(arg)
    ret = []
    while @args.size != 0
      key = @instructions.key?(@args[0])
      data_instruction = @args[0]
      ret << @args[0]
      @args.shift
      if key
        return ret
      end
      to_jump = @jump.select{|e| e[0] == @args[0]}[0]
      if to_jump != nil
        i = 0
        while i < to_jump[1]
          if @args.size == 0
            jump_error_exit(data_instruction, to_jump, arg.green + ' ' + ret)
          end
          ret << @args[0]
          @args.shift
          i += 1
        end
      else
        ret << @args[0]
        @args.shift
      end
    end
    ret
  end

  public
  # gets an array of arguments and cuts it into more readable arrays witch are then used by run
  def parse(args)
    @args = args
    until @args.empty?
      arg = @args[0]
      if @instructions.key? arg
        @args.shift
        @to_exec << [arg, args_extract(arg)]
      else
        puts 'Error : '.red + 'unrecognised instruction "' + arg.yellow + '"'
        exit 4
      end
    end
    run
  end

  # adds instruction
  def on(*args, &test)
    args.each do |arg|
      @instructions[arg] = test
    end
  end

  # this option allows for file names / site names / ... that are recognised as instructions
  # ex : file update
  def jump_when(data, values)
    unless data != nil && data != '' && values <= 0
      @jump << [data, values]
    end
  end

  def initialize(nb_args = nil)
    @to_exec = []
    @jump = []
    @instructions = {}
    @on_array = nil
    @args = ''
    @nb_args = nb_args
  end
end
