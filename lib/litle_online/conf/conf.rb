$litle_url = (ENV['RAILS_ENV'] == 'production' ? 'https://payments.litle.com' : 'https://cert.litle.com')
$litle_path = '/vap/communicator/online'

# Don not edit below this line
$template_path = File.expand_path(::File.join(::File.dirname(__FILE__), "..", 'templates'))

