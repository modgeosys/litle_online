
require 'rubygems'
require 'ckuru-tools'

module LitleOnline

  # :stopdoc:
  VERSION = '1.0.1'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    emacs_trace do 
      dir ||= ::File.basename(fname, '.*')
      search_me = ::File.expand_path(
                                     ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

      fails = [] # if at first you don't succeed....

      Dir.glob(search_me).sort.each do |rb|
        ckebug 1, "loading #{rb}"
        begin
          require rb
        rescue Exception => e
          ckebug 1, "warning ; failed to load #{rb}, will try again"
          fails.push rb
        end
      end

      fails.each do |rb|
        ckebug 1, "failsafe loading #{rb}"
        begin
          require rb
        rescue Exception => e
          ckebug 0, "fatal ; failed to load #{rb}."
          raise e
        end
      end
    end
  end

end  # module LitleOnline

LitleOnline.require_all_libs_relative_to(__FILE__)

# EOF
