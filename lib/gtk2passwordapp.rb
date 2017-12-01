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
require_relative 'gtk2passwordapp/such_parts.rb'
require_relative 'gtk2passwordapp/account.rb'
require_relative 'gtk2passwordapp/accounts.rb'
require_relative 'gtk2passwordapp/gtk2pwdv.rb'

# Requires:
#`ruby`
