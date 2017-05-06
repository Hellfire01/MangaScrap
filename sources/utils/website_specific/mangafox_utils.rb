module Utils_website_specific
  module Mangafox
    # for mangafox only => transforms the string value of the volumes to an int
    def self.volume_string_to_int(string)
      case string
        when (string == 'TBD')
          volume = -2
        when (string == 'NA')
          volume = -3
        when (string == 'ANT')
          volume = -4
        else
          volume = string.to_i
      end
      volume
    end

    # used to get the volume, chapter and page of a link as an array
    def self.data_extractor(link)
      link += '1.html'
      link_split = link.split('/')
      page = link_split[link_split.size - 1].chomp('.html').to_i
      link_split[link_split.size - 2][0] = ''
      chapter = link_split[link_split.size - 2].to_f
      if chapter % 1 == 0
        chapter = chapter.to_i
      end
      if link_split.size == 8
        link_split[link_split.size - 3][0] = ''
        if link_split[link_split.size - 3] =~ /\A\d+\z/
          volume = link_split[link_split.size - 3].to_i
        else
          if link_split[link_split.size - 3] == 'NA'
            volume = -3
          elsif link_split[link_split.size - 3] == 'TBD'
            volume = -2
          elsif link_split[link_split.size - 3] == 'ANT'
            volume = -4
          else
            volume = -42 # error value
          end
        end
      else
        volume = -1 # no volume
      end
      ret = Array.new
      ret << volume << chapter << page
      ret
    end
  end
end
