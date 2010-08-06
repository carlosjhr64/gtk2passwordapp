require 'gtk2passwordapp/passwords_data.rb'
module Gtk2PasswordApp
class Passwords < PasswordsData

  def _create_passphrase
    passphrase = ''

    IOCrypt::LENGTH.times do
      passphrase += (rand(94)+33).chr
    end
    File.open(@pfile,'w'){|fh| fh.write passphrase }
    File.chmod(0600, @pfile)

    return passphrase
  end

  def get_passphrase(mv=false)
    passphrase = ''

    @pfile = UserSpace::DIRECTORY+'/passphrase.txt'
    if mv then
      File.rename(@pfile, @pfile+'.bak') if File.exist?(@pfile)
      passphrase = _create_passphrase
    else
      if File.exist?(@pfile) then
        File.open(@pfile,'r'){|fh| passphrase = fh.read }
      else
        passphrase = _create_passphrase
      end
    end

    return passphrase
  end

  def has_datafile?
    Find.find(UserSpace::DIRECTORY){|fn|
      Find.prune if !(fn==UserSpace::DIRECTORY) &&  File.directory?(fn)
      if fn =~/[0123456789abcdef]{32}\.dat$/ then
        return true
      end
    }
    return false
  end

  def self._get_salt(prompt)
    (ret = Gtk2PasswordApp.get_salt(prompt,'Salt')) || exit
    ret.strip
  end

  attr_reader :pfile
  def initialize
    @pwd = Passwords._get_salt('Short Password')
    @pfile = nil
    @pph = get_passphrase
    super(@pwd+@pph)
    # Password file exist?
    if self.exist? # then
      # Yes, load passwords file.
      self.load 
    else
      # No, check if there is a file....
      if has_datafile? # then
        # Yes, it's got a datafile. Ask for password again.
        while !self.exist? do
          @pwd = Passwords._get_salt('Try again!')
          super(@pwd+@pph)
        end
        self.load 
      else
      # Else, must be a new install.
        pwd = @pwd
        @pwd = Passwords._get_salt('Verify New Password')
        while !(pwd == @pwd) do
          pwd = Passwords._get_salt('Try again!')
          @pwd = Passwords._get_salt('Verify New Password')
        end
      end
    end
    # Off to the races...
  end

  def save(pwd=nil)
    if pwd then
      pfbak = self.pfile + '.bak'
      pph = get_passphrase(true) # new passphrase
      dfbak = self.dumpfile + '.bak'
      super(pwd+pph)
      @pwd = pwd
      @pph = pph
      File.unlink(pfbak) if File.exist?(pfbak)
      File.unlink(dfbak) if File.exist?(dfbak)
    else
      super()
    end
    return self.dumpfile
  end

end
end
