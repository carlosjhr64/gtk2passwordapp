Gem::Specification.new do |s|

  s.name     = 'gtk2passwordapp'
  s.version  = '6.3.250921'

  s.homepage = 'https://github.com/carlosjhr64/gtk2passwordapp'

  s.author   = 'CarlosJHR64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2025-09-21'
  s.licenses = ['MIT']

  s.description = <<DESCRIPTION
Ruby-Gnome Password Manager.

Uses Blowfish to encrypt the datafile.
Features random password generator, clipboard use, and TOTP.
DESCRIPTION

  s.summary = <<SUMMARY
Ruby-Gnome Password Manager.
SUMMARY

  s.require_paths = ['lib']
  s.files = %w(
README.md
bin/gtk2passwordapp
data/logo.png
lib/gtk2passwordapp.rb
lib/gtk2passwordapp/account.rb
lib/gtk2passwordapp/accounts.rb
lib/gtk2passwordapp/cli.rb
lib/gtk2passwordapp/config.rb
lib/gtk2passwordapp/gui.rb
  )
  s.executables << 'gtk2passwordapp'
  s.add_runtime_dependency 'yaml_zlib_blowfish', '~> 2.0', '>= 2.0.250921'
  s.add_runtime_dependency 'base_convert', '~> 7.1', '>= 7.1.221229'
  s.add_runtime_dependency 'gtk3app', '~> 5.4', '>= 5.4.230109'
  s.add_runtime_dependency 'base32', '= 0.3.4'
  s.add_runtime_dependency 'totp', '= 1.0.1'
  s.add_runtime_dependency 'super_random', '~> 3.2', '>= 3.2.230116'
  s.required_ruby_version = '>= 3.4'

end
