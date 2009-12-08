require 'yaml'
require 'rubygems'
begin
  require 'crypt_tea'
rescue Exception
  # above is what works, but documentation shows this...
  require 'crypt-tea'
end

class IOCrypt
  LENGTH = 15
  #HTTPX = Regexp.new('^https?:\/\/')

  def initialize(passphrase)
    #@key = Crypt::Blowfish.new(passphrase[0..55])  
    @key = Crypt::XXTEA.new(passphrase[0..LENGTH])
  end

  def load(dumpfile)
    data = nil

    #if dumpfile =~ HTTPX then
    #  require 'open-uri'
    #  open(dumpfile){|fh|
    #    #data = YAML.load( @key.decrypt_string( fh.read ) )
    #    data = YAML.load( @key.decrypt( fh.read ) )
    #  }
    #else
      File.open(dumpfile,'r'){|fh|
        #data = YAML.load( @key.decrypt_string( fh.read ) )
        data = YAML.load( @key.decrypt( fh.read ) )
      }
    #end

    return data
  end

  def dump(dumpfile, data)
    count = nil
    raise "Http PUT not supported" if dumpfile =~ HTTPX

    File.open(dumpfile,'w') do |fh|
      #count = fh.write( @key.encrypt_string( YAML.dump( data ) ) )
      count = fh.write( @key.encrypt( YAML.dump( data ) ) )
    end

    return count
  end
end
