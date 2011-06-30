require 'gtk2passwordapp/passwords_data'
require 'gtk2passwordapp/rnd'
module Gtk2Password
# Passwords subclasses PasswordsData :P
class Passwords < PasswordsData

  attr_reader :pfile
  def initialize(pwd=nil)
    @pwd = (pwd.nil?)? Passwords._get_salt('Short Password') : pwd
    @pfile = nil
    @pph = self.get_passphrase
    super(@pwd+@pph)
    # Password file exist?
    if self.exist? # then
      # Yes, load passwords file.
      self.load 
    else
      raise "bad salt" unless pwd.nil?
      self.reinit{|salt| super(salt) }
    end
    # Off to the races...
  end

  def self.try_again
    Passwords._get_salt('Try again!')
  end

  def self.verify_password
    Passwords._get_salt('Verify New Password')
  end

  def try_again(&block)
    # Yes, it's got a datafile. Ask for password again.
    while !self.exist? do
      @pwd = Passwords.try_again
      block.call(@pwd+@pph)
    end
    self.load 
  end

  def new_install(&block)
      pwd = @pwd
      @pwd = Passwords.verify_password
      while !(pwd == @pwd) do
        pwd = Passwords.try_again
        @pwd = Passwords.verify_password
      end
      block.call(@pwd+@pph)
      self.save
  end

  def reinit(&block)
    # No, check if there is a file....
    if Passwords.has_datafile? # then
      try_again(&block)
    else
    # Else, must be a new install.
      new_install(&block)
    end
  end

  def _create_passphrase
    passphrase = ''

    IOCrypt::LENGTH.times do
      passphrase += (Rnd::RND.random(94)+33).chr
    end
    File.open(@pfile,'w'){|fh| fh.write passphrase }
    File.chmod(0600, @pfile)

    return passphrase
  end

  def mv_create_passphrase
    File.rename(@pfile, @pfile+'.bak') if File.exist?(@pfile)
    _create_passphrase
  end

  def fc_passphrase
    passphrase = nil
    if File.exist?(@pfile) then
      File.open(@pfile,'r'){|fh| passphrase = fh.read }
    else
      passphrase = _create_passphrase
    end
    return passphrase
  end

  def get_passphrase(mv=false)
    @pfile = Gtk2AppLib::USERDIR+'/passphrase.txt'
    (mv)? mv_create_passphrase : fc_passphrase
  end

  def self.has_datafile?
    Find.find(Gtk2AppLib::USERDIR){|fn|
      Find.prune if !(fn==Gtk2AppLib::USERDIR) &&  File.directory?(fn)
      if fn =~/[0123456789abcdef]{32}\.dat$/ then
        return true
      end
    }
    return false
  end

  def self._get_salt(prompt)
    (ret = Gtk2Password.get_salt(prompt,'Salt')) || exit
    ret.strip
  end

  def save(pwd=nil)
    if pwd.nil? then
      super()
    else
      pfbak = self.pfile + '.bak'
      pph = get_passphrase(true) # new passphrase
      dfbak = self.dumpfile + '.bak'
      super(pwd+pph)
      @pwd = pwd
      @pph = pph
      File.unlink(pfbak) if File.exist?(pfbak)
      File.unlink(dfbak) if File.exist?(dfbak)
    end
    return self.dumpfile
  end

end
end
