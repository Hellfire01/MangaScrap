# this class is used to cut the arguments given to MangaScrap and allow
class Instruction_parser
  private
  # function used to exit whenever there is not enough argument for a 'jump'
  # jump : number of arguments required
  # prev : the argument
  # parent : the instruction
  def jump_error_exit(prev, jump, parent)
    puts 'Error : '.red + prev.yellow + ' requires ' + jump.to_s.yellow + ' more argument(s)'
    puts 'in : [' + parent + ']'
    case prev
      when 'id'
        puts 'id '.yellow + 'requires a ' + 'name'.blue + ' ( first argument ) and a ' + 'site'.blue + ' ( second argument )'
s      else
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
      display = 'executing : ' + buff[0].green + ' ' + buff[1].join(' ')
      @jump.each do |e|
        display = display.gsub(e[0] + ' ', e[0].yellow + ' ') # todo improve this to avoid colorizing arguments
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
    ret = [] # extracted arguments
    jump = 0 # used if a @jump argument is found
    prev = @args[0] # used for error display purposes
    # args_extract tries to shift all of @args but stops when an @instruction is found
    while @args.size != 0
      if jump == 0
        prev = @args[0]
      end
      key = @instructions.key?(@args[0])
      buff = @jump.select{|e| e[0] == @args[0]}[0]
      if buff != nil
        jump = buff[1] + 1
      end
      if jump == 0 && key
        return ret
      else
        if @args.empty?
          jump_error_exit(prev, jump, arg + ' ' + ret)
        end
        ret << @args[0]
        @args.shift
      end
      if jump != 0
        jump -= 1
      end
    end
    if jump != 0
      jump_error_exit(prev, jump, arg.green + ' ' + prev)
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
        buff = args_extract(arg)
        @to_exec << [arg, buff]
      else
        puts 'Error : '.red + 'unrecognised instruction "' + arg.yellow + '"'
        exit 4
      end
    end
    run
  end

  # adds instruction with a block
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
