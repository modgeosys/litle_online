# -*-ruby-*-

# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

#begin
  require 'bones'
  Bones.setup
#rescue LoadError
#  begin
#    load 'tasks/setup.rb'
#  rescue LoadError
#    raise RuntimeError, '### please install the "bones" gem ###'
#  end
#end

ensure_in_path 'lib'
require 'litle_online'

task :default => 'spec:run'

PROJ.name = 'litle_online'
PROJ.authors = 'Andrius, Bret'
PROJ.email = 'bret@ckuru.com'
PROJ.url = 'http://www.ckuru.com'
PROJ.version = LitleOnline::VERSION
PROJ.rubyforge.name = 'litle_online'

PROJ.spec.opts << '--color'

# EOF
