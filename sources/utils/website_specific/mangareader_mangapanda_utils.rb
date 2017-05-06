module Utils_website_specific
  module Mangareader_Mangapanda
    def self.volume_string_to_int(string)
      string.to_i
    end

    # used to get the volume, chapter and page of a link as an array
    def self.data_extractor(link)
      link_split = link.split('/')
      if link_split.size == 5
        page = 1
        chapter = link_split[link_split.size - 1].to_i
      else
        page = link_split[link_split.size - 1].to_i
        chapter = link_split[link_split.size - 2].to_i
      end
      ret = Array.new
      ret << -1 << chapter << page
      ret
    end
  end
end
