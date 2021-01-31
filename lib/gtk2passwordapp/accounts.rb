class Gtk2PasswordApp
class Accounts

  def reset(password)
    @yzb =  YamlZlibBlowfish.new(password)
  end

  attr_reader :data
  def initialize(dumpfile, password=nil)
    reset(password) if password # sets @yzb
    @dumpfile = dumpfile
    @data = {}
  end

  def exist?
    File.exist? @dumpfile
  end

  # will raise an exception on failed decryption
  def load(password=nil)
    reset(password) if password
    data = @yzb.load(@dumpfile)
    # Sanity check... load will raise CipherError on decription error.
    raise CONFIG[:CipherError] unless data.class == Hash
    @data = data
  end

  def save(password=nil)
    reset(password) if password
    @yzb.dump(@dumpfile, @data)
    File.chmod(0600, @dumpfile)
  end

  def names
    @data.keys
  end

  def delete(account)
    raise CONFIG[:AccountMiss] unless @data.has_key?(account)
    @data.delete(account)
  end

  def get(account)
    raise CONFIG[:AccountMiss] unless @data.has_key?(account)
    Account.new(account, @data)
  end

  def add(account)
    raise CONFIG[:AccountHit] if @data.has_key?(account)
    Account.new(account, @data)
  end

end
end
