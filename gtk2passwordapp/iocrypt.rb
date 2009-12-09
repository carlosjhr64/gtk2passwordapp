require 'yaml'
require 'rubygems'
begin
  require 'crypt_tea'
rescue Exception
  # above is what works, but documentation shows this...
  require 'crypt-tea'
end

module Gtk2PasswordApp
class IOCrypt
  LENGTH = 15

  def initialize(passphrase)
    @key = Crypt::XXTEA.new(passphrase[0..LENGTH])
  end

  def load(dumpfile)
    data = nil
    File.open(dumpfile,'r'){|fh| data = YAML.load( @key.decrypt( fh.read ) ) }
    return data
  end

  def dump(dumpfile, data)
    count = nil
    File.open(dumpfile,'w') { |fh| count = fh.write( @key.encrypt( YAML.dump( data ) ) ) }
    return count
  end
end
end
