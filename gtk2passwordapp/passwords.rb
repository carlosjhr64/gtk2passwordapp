require 'gtk2passwordapp/passwords_data.rb'
module Gtk2PasswordApp
class Passwords < PasswordsData

  def _create_passphrase(pfile)
    passphrase = ''

    IOCrypt::LENGTH.times do
      passphrase += (rand(94)+33).chr
    end
    File.open(pfile,'w'){|fh| fh.write passphrase }
    File.chmod(0600, pfile)

    return passphrase
  end

  def get_passphrase(mv=false)
    passphrase = ''

    pfile = UserSpace::DIRECTORY+'/passphrase.txt'
    if mv then
      File.rename(pfile, pfile+'.bak') if File.exist?(pfile)
      passphrase = _create_passphrase(pfile)
    else
      if File.exist?(pfile) then
        File.open(pfile,'r'){|fh| passphrase = fh.read }
      else
        passphrase = _create_passphrase(pfile)
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

  def initialize
    @pwd = Gtk2PasswordApp.get_salt || exit
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
          @pwd = Gtk2PasswordApp.get_salt('Try again!') || exit
          super(@pwd+@pph)
        end
        self.load 
      else
      # Else, must be a new install.
        pwd = @pwd
        @pwd = Gtk2PasswordApp.get_salt('Verify New Password') || exit
        while !(pwd == @pwd) do
          pwd = Gtk2PasswordApp.get_salt('Try again!') || exit
          @pwd = Gtk2PasswordApp.get_salt('Verify New Password') || exit
        end
      end
    end
    # Off to the races...
  end

end
end
