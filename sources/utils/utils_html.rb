$copied_js_css = []

module HTML_utils
  def self.file_copy(file_name, dest)
    file = File.open(file_name).read
    File.open(dest, 'w') {|f| f.write(file)}
  end

  # copies the static files ( the css and css witch is not edited )
  # keeps track of what was copied to avoid unnecessary copies
  def self.copy_html_related_files(site, dir)
    unless $copied_js_css.include?(site)
      Utils_file::dir_create(dir + 'html/css/')
      Utils_file::dir_create(dir + 'html/js/')
      # css
      file_copy(__dir__ + '/../templates/web/manga_presentation/presentation_template.css', dir + 'html/css/chapter_index.css')
      file_copy(__dir__ + '/../templates/web/chapter/chapter_template.css', dir + 'html/css/chapter.css')
      file_copy(__dir__ + '/../templates/web/site_index/site_index_template.css', dir + 'html/css/manga_index.css')
      file_copy(__dir__ + '/../templates/web/manga_updated_index_template.css', dir + 'html/css/manga_updated_index.css')
      # js
      file_copy(__dir__ + '/../templates/web/manga_presentation/presentation_template.js', dir + 'html/js/chapter_index.js')
      file_copy(__dir__ + '/../templates/web/chapter/chapter_template.js', dir + 'html/js/chapter.js')
      $copied_js_css << site
    end
  end

  # gets the html filename of the chapter ( works nearly the same way as the jpg names )
  def self.html_chapter_filename(chapter, volume)
    '/v' + Utils_file::vol_buffer_string(volume) + 'c' + Utils_file::chap_buffer_string(chapter) + '.html'
  end
end
