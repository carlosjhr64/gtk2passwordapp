module Gtk2passwordapp
  APPDIR = File.dirname File.dirname __dir__
  CONFIG = {
    PwdFile: "#{XDG['CACHE']}/gtk3app/gtk2passwordapp/passwords.dat",
  }
end
