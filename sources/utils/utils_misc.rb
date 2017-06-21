
module Utils_misc
  def self.sort_chapter_list(chapter_list, pages = false)
    biggest = chapter_list.map { |a| [a[:volume], 0].max }.max
    if pages # used for _todo
      return chapter_list.sort_by { |a| [((a[:volume] < 0) ? (biggest + a[:volume] * -1) : a[:volume]), a[:chapter], a[:page]] }
    else # used for traces
      return chapter_list.sort_by { |a| [((a[:volume] < 0) ? (biggest + a[:volume] * -1) : a[:volume]), a[:chapter]] }
    end
  end
end
