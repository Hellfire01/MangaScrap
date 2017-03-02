class HTML_buffer
  include Singleton

  def add_chapter(manga_name, chapter, volume)
    ret = @dl.select{|struct| struct['name'] == manga_name}
    if ret.size != 0
      ret[0]['downloaded'] << [volume, chapter]
    else
      buff = [volume, chapter]
      @dl << Struct::Updated.new(manga_name, buff);
    end
  end

  def clear_data
    @dl = []
  end

  def get_data
    @dl
  end

  def initialize
    @dl = []
  end
end
