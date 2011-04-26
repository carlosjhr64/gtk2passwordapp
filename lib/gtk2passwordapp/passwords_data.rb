require 'gtk2passwordapp/iocrypt'
require 'digest/md5'

module Gtk2Password
# PasswordsData maitains passwords
class PasswordsData
  include Configuration
  attr_accessor :account
  attr_reader :data, :dumpfile

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
    _reset(passphrase) if !passphrase.nil?
    iocrypt = IOCrypt.new(@passphrase)
    @data = iocrypt.load(@dumpfile)
  end

  def save(passphrase = nil)
    # just in case, keep a backup
    File.rename(@dumpfile, @dumpfile+'.bak') if File.exist?(@dumpfile)
    _reset(passphrase) if !passphrase.nil?
    iocrypt = IOCrypt.new(@passphrase)
    iocrypt.dump(@dumpfile, @data)
    File.chmod(0600, @dumpfile)
  end

  def add(account)
    raise "Pre-existing" if @data[account]
    raise "Can't have nil account" if account.nil?
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
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    data_account[URL] = url if !url.nil?
    return data_account[URL]	|| ''
  end

  def expired?(account)
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    last_update = data_account[LAST_UPDATE]
    return true if last_update.nil? || ((Time.now.to_i - last_update) > PASSWORD_EXPIRED)
    return false
  end

  def password_of(account, password=nil)
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    if !password.nil? then
      data_account[PREVIOUS] = data_account[PASSWORD]
      data_account[PASSWORD] = password
      data_account[LAST_UPDATE] = Time.now.to_i
    end
    return data_account[PASSWORD]	|| ''
  end

  # previous password
  def previous_password_of(account)
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    return data_account[PREVIOUS]	|| ''
  end

  def note_of(account, note=nil)
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    data_account[NOTE] = note if !note.nil?
    return data_account[NOTE]	|| ''
  end

  def username_of(account, usr=nil)
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    data_account[USERNAME] = usr if !usr.nil?
    return data_account[USERNAME]	|| ''
  end
end
end
