class Gtk2PasswordApp
  VERSION = '6.1.210628'
  HELP = <<~HELP
    Usage:
      gtk2passwordapp [:gui+]
      gtk2passwordapp :cli [<pattern> [<file>]]
      gtk2passwordapp :info
    Gui:
      --minime       \tReal minime
      --notoggle     \tMinime wont toggle decorated and keep above
      --notdercorated\tDont decorate window
    Cli:
      --nogui
    Info:
      -v --version   \tShow version and exit
      -h --help      \tShow help and exit
    # Notes #
    With the --nogui cli-option,
    one can give a pattern to filter by account names.
    Default passwords data file is:
      ~/.cache/gtk3app/gtk2passwordapp/dump.yzb
  HELP

  def self.cli
    # User using cli may be experiencing system problems.
    begin
      require 'gtk2passwordapp/cli'
      require 'yaml_zlib_blowfish'
      require 'base_convert'
    rescue LoadError
      $stderr.puts 'Missing Gem:'
      $stderr.puts $!.message
      exit 72
    end
  end

  def self.gui
    # This is a Gtk3App.
    require 'gtk3app'

    # Helper Gems.
    require 'base32'
    require 'totp'
    require 'yaml_zlib_blowfish'
    require 'super_random'
    require 'base_convert'

    # This Gem.
    require_relative 'gtk2passwordapp/config.rb'
    require_relative 'gtk2passwordapp/account.rb'
    require_relative 'gtk2passwordapp/accounts.rb'
    require_relative 'gtk2passwordapp/gui.rb'
  end
end
# Requires:
#`ruby`
