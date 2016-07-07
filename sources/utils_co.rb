$nb_tries = -1
$between_sleep = -1
$failure_sleep = -1
$error_sleep = -1

#inits the global variables
def init_utils()
  db = Params.new()
  params = db.get_params()
  $between_sleep = params[2]
  $failure_sleep = params[3]
  $nb_tries = params[4]
  $error_sleep = params[5]
end

# detects if there whas a redirection on the required link
def redirection_detection(url)
  tries ||= $nb_tries
  begin
    open(url) do |resp|
      if (resp.base_uri.to_s != url)
        return true
      end
    end
  rescue Exception => error
    if tries > 0
	tries -= 1
	sleep($failure_sleep)
	retry
    else
      puts "connection is lost or could not find manga, stopping programm"
      puts url
      puts "message is : " + error.message
      abort()
    end
  end
  return false
end  

# conect to link and download page
def get_page(link)
  tries ||= $nb_tries
  begin
    page = Nokogiri::HTML(open(link, "User-Agent" => "Ruby/#{RUBY_VERSION}")) do |noko|
      noko.noblanks.noerror
    end
  rescue Exception => error
    if tries > 0
      tries -= 1
      sleep($failure_sleep)
      retry
    else
      puts 'could not get page ' + link + ' after ' + $nb_tries.to_s + ' tries'
      puts "message is : " + error.message
      return nil
    end
  end
  sleep($between_sleep)
  return page
end

# conect to link and download picture
def get_pic(link)
  safe_link = link.gsub(/[\[\]]/) { '%%%s' % $&.ord.to_s(16) }
  tries ||= $nb_tries
  begin
    page = open(safe_link, "User-Agent" => "Ruby/#{RUBY_VERSION}")
  rescue URI::InvalidURIError => error
    puts "Warning : bad url"
    puts link
    puts "message is : " + error.message
    return nil
  rescue Exception => error
    if tries > 0
	tries -= 1
	sleep($failure_sleep)
	retry
    else
      puts 'could not get picture ' + safe_link + ' after ' + $nb_tries.to_s + ' tries'
      puts "message is : " + error.message
      return nil
    end
  end
  sleep($between_sleep)
  return page
end
