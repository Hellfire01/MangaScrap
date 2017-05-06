# warning, not implemented yed
# todo : implementation of the scam option
module Scan
=begin
  def get_data(dir, db, name)
      puts 'scanning'
      scan_dir(dir, db, name)
  end

  # method used to add elements to the database from files
  def scan_add(db, name, dir, data, chap_list) # calls scan correct if delete diff == true
  end

  def scan_correct(db, name, dir, chap_list) # does not add the manga
    puts 'deleting difference trace / chapter list'
    delete_diff(db, chap_list, dir, name)
    puts 'deleting excess files'
    delete_bad_files(db_to_trace(db, name), get_data(dir, db, name), dir)
    puts 'done'
  end

  # entry point => argv scan
  def scan(db, mode) # todo => must be able to use files ( -f option )
    puts 'preparing'
    params = Params.instance
    if ARGV.size != 3
      puts 'wrong number of arguments : expected 2'
      exit 5
    end
    site = ARGV[1]
    name = ARGV[2]
    if site != 'mangafox'
      puts 'unmanaged site ' + site
      exit 4
    end
    puts 'getting chapter list from site'
    chap_list = Download_mf.new(db, name, false).get_links
    dir = params.get_params[1] + site + '/' + name + '/'
    Dir.chdir(dir)
    if mode == 'add'
      data = get_data(dir, db, name)
      puts 'adding pages to trace database'
      scan_add(db, name, dir, data, chap_list)
    elsif mode == 'correct'
      puts 'correcting scan'
      scan_correct(db, name, dir, chap_list)
    else
      puts 'critical error : unkown scan mode : ' + mode
    end
=end
end

#Warning !
#One last scan must be performed to manage the todo files
#L=> add them to todo database
#Note :
#Chapters with the wrong number of pages should be completely deleted and re-downloaded
#( new parameter ? => correct = trim || severe )
