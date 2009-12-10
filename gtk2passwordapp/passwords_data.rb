require 'gtk2passwordapp/iocrypt'
require 'digest/md5'

module Gtk2PasswordApp
class PasswordsData
  include Configuration
  attr_accessor :account
  attr_reader :data

  PASSWORD	= 0
  PREVIOUS	= 1
  NOTE		= 2
  USERNAME	= 3
  URL		= 4
  LAST_UPDATE	= 5

  def _reset(passphrase)
    raise "Need a good passphrase" if !passphrase || passphrase.length < 7
    @passphrase = passphrase[0..IOCrypt::LENGTH]
    @dumpfile = PASSWORDS_DATA_DIR + '/' + Digest::MD5.hexdigest(@passphrase) + '.dat'
  end

  def initialize(passphrase)
    _reset(passphrase)
    @data = {}
  end

  def exist?
    File.exist?(@dumpfile)
  end

  def load(passphrase = nil)
    _reset(passphrase) if passphrase 
    iocrypt = IOCrypt.new(@passphrase)
    @data = iocrypt.load(@dumpfile)
  end

  def save(passphrase = nil)
    # just in case, keep a backup
    bak = @dumpfile+'.bak'
    File.rename(@dumpfile, bak) if File.exist?(@dumpfile)
    _reset(passphrase) if passphrase 
    iocrypt = IOCrypt.new(@passphrase)
    iocrypt.dump(@dumpfile, @data)
    File.chmod(0600, @dumpfile)
    File.unlink(bak) if File.exist?(bak)
  end

  def add(account)
    raise "Pre-existing" if @data[account]
    raise "Can't have nil account" if !account
    @data[account] = ['','','','','']
  end

  def accounts
    @data.keys.sort
  end

  def include?(account)
    return (@data[account])? true: false
  end

  def verify?(account,password)
    return @data[account][PASSWORD] == password
  end

  def delete(account)
    raise "#{account} not found" if !@data[account]
    @data.delete(account)
  end

  def url_of(account, url=nil)
    raise "#{account} not found" if !@data[account]
    @data[account][URL] = url if url
    return @data[account][URL]	|| ''
  end

  def expired?(account)
    raise "#{account} not found" if !@data[account]
    return true if !@data[account][LAST_UPDATE] || ((Time.now.to_i - @data[account][LAST_UPDATE]) > PASSWORD_EXPIRED)
    return false
  end

  def password_of(account, p=nil)
    raise "#{account} not found" if !@data[account]
    if p then
      @data[account][PREVIOUS] = @data[account][PASSWORD]
      @data[account][PASSWORD] = p
      @data[account][LAST_UPDATE] = Time.now.to_i
    end
    return @data[account][PASSWORD]	|| ''
  end

  # previous password
  def previous_password_of(account)
    raise "#{account} not found" if !@data[account]
    return @data[account][PREVIOUS]	|| ''
  end

  def note_of(account, n=nil)
    raise "#{account} not found" if !@data[account]
    @data[account][NOTE] = n if n
    return @data[account][NOTE]	|| ''
  end

  def username_of(account, usr=nil)
    raise "#{account} not found" if !@data[account]
    @data[account][USERNAME] = usr if usr 
    return @data[account][USERNAME]	|| ''
  end
end
end
