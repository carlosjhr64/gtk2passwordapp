module Gtk2passwordapp
class Accounts

  def reset(password)
    @yzb =  YamlZlibBlowfish.new(password)
  end

  def initialize(password, dumpfile)
    reset(password) # sets @yzb
    @dumpfile = dumpfile
    @data = {}
  end

  # will raise an exception on failed decryption
  def load
    data = @yzb.load(@dumpfile)
    raise "Decryption error." unless data.class == Hash
    @data = data
  end

  def save(password=nil)
    reset(password) if password
    @yzb.dump(@dumpfile, @data)
    File.chmod(0600, @dumpfile)
  end

  def accounts
    @data.keys
  end

  def include?(account)
    return @data.has_key?(account)
  end

  def delete(account)
    @data.delete(account)
  end

  def get(account)
    raise "Account #{account} does NOT exists!" unless @data.has_key?(account)
    Account.new(account, @data)
  end

  def add(account)
    raise "Account #{account} exists!" if @data.has_key?(account)
    Account.new(account, @data)
  end

end
end
