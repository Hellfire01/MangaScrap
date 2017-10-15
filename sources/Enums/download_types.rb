#this module mostly serves the purpose of an Enum but also has a method to allow easy translation from value to char

module Download_type
  def self.related_char_error(value)
    case value
      when PAGE
        return 'x'
      when PICTURE
        return '!'
      when INDEX
        return 'X'
      when COVER
        return 'c'
      else
        Utils_errors::critical_error('bad enum value of ' + value.to_s + ' this means there is an internal error ( a missing piece of code )')
    end
  end

  PAGE = 0
  PICTURE = 1
  INDEX = 2
  COVER = 3
end
