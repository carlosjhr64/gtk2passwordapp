require 'gtk2passwordapp/iocrypt'
require 'digest/md5'

module Gtk2Password
# PasswordsData maitains passwords
class PasswordsData

  PASSWORD	= 0
  PREVIOUS	= 1
  NOTE		= 2
  USERNAME	= 3
  URL		= 4
  LAST_UPDATE	= 5

  def reset(password)
    raise "password too short" if password.length < 7
    # MD5 digest length is 16 to match tiny encryption's block length
    passphrase = Digest::MD5.digest( password )
    @iocrypt =  IOCrypt.new(passphrase)
  end

  attr_reader :data
  attr_accessor :expired, :dumpfile
  def initialize(dumpfile,password)
    reset(password) # sets @iocrypt
    @dumpfile = dumpfile
    @expired = 60*60*24*30*3 # 3 months
    @data = {}
  end

  def exist?
    File.exist?(@dumpfile)
  end

  # will raise an exception on failed decryption
  def load
    data = @iocrypt.load(@dumpfile)
    raise "decryption error" unless data.class == Hash
    @data = data
  end

  def save
    # just in case, keep a backup
    File.rename(@dumpfile, @dumpfile+'.bak') if File.exist?(@dumpfile)
    @iocrypt.dump(@dumpfile, @data)
    File.chmod(0600, @dumpfile)
  end

  def save!(password)
    reset(password)
    save
  end

  def add(account)
    raise "pre-existing" unless @data[account].nil?
    raise "can't have nil account" if account.nil?
    @data[account] = [ '', '', '', '', '', 0 ]
  end

  def accounts
    @data.keys.sort
  end

  def include?(account)
    return !@data[account].nil?
  end

  def verify?(account,password)
    return @data[account][PASSWORD] == password
  end

  def delete(account)
    raise "#{account} not found" if @data[account].nil?
    @data.delete(account)
  end

  def get_data_account(account)
    data_account = @data[account]
    raise "#{account} not found" if data_account.nil?
    return data_account
  end

  def self.url_of(data_account, url)
    data_account[URL] = url unless url.nil?
    return data_account[URL]
  end

  def url_of(account, url=nil)
    PasswordsData.url_of( get_data_account(account), url )
  end

  def expired?(account)
    data_account = get_data_account(account)
    last_update = data_account[LAST_UPDATE]
    ((Time.now.to_i - last_update) > @expired)
  end

  def self.password_of(data_account,password)
    data_account[PREVIOUS] = data_account[PASSWORD]
    data_account[PASSWORD] = password
    data_account[LAST_UPDATE] = Time.now.to_i
  end

  def password_of(account, password=nil)
    data_account = get_data_account(account)
    PasswordsData.password_of(data_account,password) unless password.nil?
    return data_account[PASSWORD]
  end

  # previous password
  def previous_password_of(account)
    data_account = get_data_account(account)
    return data_account[PREVIOUS]
  end

  def self.note_of(data_account,note)
    data_account[NOTE] = note unless note.nil?
    return data_account[NOTE]
  end

  def note_of(account, note=nil)
    PasswordsData.note_of( get_data_account(account), note )
  end

  def self.username_of(data_account,usr)
    data_account[USERNAME] = usr unless usr.nil?
    return data_account[USERNAME]
  end

  def username_of(account, usr=nil)
    PasswordsData.username_of( get_data_account(account), usr )
  end
end
end
