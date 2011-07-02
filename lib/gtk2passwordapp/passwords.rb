require 'gtk2passwordapp/passwords_data'
module Gtk2Password
# Passwords subclasses PasswordsData :P
class Passwords < PasswordsData

  # Configurable prompts
  PROMPT = {
	:password	=> 'Password',
	:again		=> 'Again',
	:retry		=> 'Retry',
  }

  def initialize(dump,pwd=nil)
    if pwd.nil? then
      pwd = yield(PROMPT[:password])
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
              pwd = yield(PROMPT[:again])
            end
            super(dump,pwd)
            self.save
          end
          again = false # good to go!
        rescue StandardError
          pwd = yield(PROMPT[:retry])
        end
      end
    else
      super(dump,pwd)
    end
    # Off to the races...
  end

end
end
