require 'yaml'
require 'rubygems'
gem 'crypt-tea','= 1.3.0'
begin
  require 'crypt_tea'
rescue Exception
  # above is what works, but documentation shows this...
  require 'crypt-tea'
end

module Gtk2Password
# Wrapper around Crypt::XXTEA
class IOCrypt
  LENGTH = 16

  def initialize(passphrase)
    @key = Crypt::XXTEA.new(passphrase[0..(LENGTH-1)])
  end

  def load(dumpfile)
    data = nil
    begin
      File.open(dumpfile,'r'){|fh| data = YAML.load( @key.decrypt( fh.read ) ) }
    rescue Psych::SyntaxError
      # assume it's syck
      YAML::ENGINE.yamler = 'syck'
      File.open(dumpfile,'r'){|fh| data = YAML.load( @key.decrypt( fh.read ) ) }
      YAML::ENGINE.yamler = 'psych' # make it psych
    end
    return data
  end

  def dump(dumpfile, data)
    count = nil
    File.open(dumpfile,'w') { |fh| count = fh.write( @key.encrypt( YAML.dump( data ) ) ) }
    return count
  end
end
end
