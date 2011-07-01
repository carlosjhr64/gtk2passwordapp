require 'gtk2passwordapp/passwords_data'
require 'gtk2passwordapp/rnd'
module Gtk2Password
# Passwords subclasses PasswordsData :P
class Passwords < PasswordsData

  def initialize(pwd=nil)
    gui = pwd.nil?
    @pwd = (gui)? Passwords.get_password('Password') : pwd
    super(@pwd)
    again = true
    while again do
      begin
        # Password file exist?
        if self.exist? # then
          # Yes, load passwords file.
          self.load 
        else
          self.install{ super(@pwd) }
        end
        again = false # good to go!
      rescue StandardError
        raise "bad password" unless gui
        @pwd = Passwords.get_password('Retry')
      end
    end
    # Off to the races...
  end

  def install(&block)
    pwd = nil
    while !(pwd == @pwd) do
      pwd = @pwd
      @pwd = Passwords.get_password('Again')
    end
    block.call
    self.save
  end

  def self.get_password(prompt)
    (ret = Gtk2Password.get_password(prompt,'Password')) || exit
    ret.strip
  end

  def save!(pwd)
    backup = (dumpfile = self.dumpfile) + '.bak'
    self.save(pwd)
    @pwd = pwd
    File.unlink(backup) if File.exist?(backup)
    return dumpfile
  end

end
end
