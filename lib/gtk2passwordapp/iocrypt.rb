require 'yaml'
require 'zlib'
require 'openssl'
require 'digest/sha2'

YAML::ENGINE.yamler = 'psych' # ensure it's psych

module Gtk2Password

class IOCrypt
  def initialize(passphrase)
    @key = Digest::SHA256.digest passphrase
  end

  def _cipher(mode, data)
    cipher = OpenSSL::Cipher::Cipher.new('bf-cbc').send(mode)
    cipher.key = @key
    cipher.update(data) << cipher.final
  end

  def _decrypt(e)
    Zlib::Inflate.inflate(_cipher(:decrypt, e))
  end

  def _encrypt(p)
     _cipher(:encrypt, Zlib::Deflate.deflate(p))
  end

  def load(dumpfile)
    data = nil
    begin
      File.open(dumpfile,'r'){|fh| data = YAML.load( _decrypt( fh.read ) ) }
    rescue Psych::SyntaxError
      # assume it's syck
      YAML::ENGINE.yamler = 'syck'
      File.open(dumpfile,'r'){|fh| data = YAML.load( _decrypt( fh.read ) ) }
      YAML::ENGINE.yamler = 'psych' # make it psych
    end
    return data
  end

  def dump(dumpfile, data)
    count = nil
    File.open(dumpfile,'w') { |fh| count = fh.write( _encrypt( YAML.dump( data ) ) ) }
    return count
  end
end
end
