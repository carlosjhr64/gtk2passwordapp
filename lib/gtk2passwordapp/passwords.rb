require 'gtk2passwordapp/passwords_data'
module Gtk2Password
# Passwords subclasses PasswordsData :P
class Passwords < PasswordsData

  def initialize(dump,pwd=nil)
    if pwd.nil? then
      pwd = yield('Password')
      again = true
      while again do
        super(dump,pwd)
        begin
          # Password file exist?
          if self.exist? # then
            # Yes, load passwords file.
            self.load 
          else
            verify = nil
            while !(verify == pwd) do
              verify = pwd
              pwd = yield('Again')
            end
            super(dump,pwd)
            self.save
          end
          again = false # good to go!
        rescue StandardError
          pwd = yield('Retry')
        end
      end
    else
      super(dump,pwd)
    end
    # Off to the races...
  end

end
end
