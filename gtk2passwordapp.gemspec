Gem::Specification.new do |s|

  s.name     = 'gtk2passwordapp'
  s.version  = '4.2.1'

  s.homepage = 'https://github.com/carlosjhr64/gtk2passwordapp'

  s.author   = 'carlosjhr64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2017-01-07'
  s.licenses = ['MIT']

  s.description = <<DESCRIPTION
Ruby-Gnome Password Manager.

Uses Blowfish to encrypt the datafile.
Features random password generator and clipboard use.
DESCRIPTION

  s.summary = <<SUMMARY
Ruby-Gnome Password Manager.
SUMMARY

  s.extra_rdoc_files = ['README.rdoc']
  s.rdoc_options     = ["--main", "README.rdoc"]

  s.require_paths = ["lib"]
  s.files = %w(
README.rdoc
bin/gtk2passwordapp
data/VERSION
data/logo.png
lib/gtk2passwordapp.rb
lib/gtk2passwordapp/account.rb
lib/gtk2passwordapp/accounts.rb
lib/gtk2passwordapp/config.rb
lib/gtk2passwordapp/gtk2passwordapp.rb
lib/gtk2passwordapp/such_parts.rb
lib/gtk2passwordapp/version.rb
  )
  s.executables << 'gtk2passwordapp'

  s.add_runtime_dependency 'xdg', '= 2.2.3'

  s.add_runtime_dependency 'rafini', '~> 1.2', '>= 1.2.0'
  s.add_runtime_dependency 'user_space', '~> 2.0', '>= 2.0.1'
  s.add_runtime_dependency 'yaml_zlib_blowfish', '~> 0.0', '>= 0.0.1'
  s.add_runtime_dependency 'super_random', '~> 0.1', '>= 0.1.0'
  s.add_runtime_dependency 'base_convert', '~> 2.0', '>= 2.0.0'
  s.add_runtime_dependency 'helpema', '~> 0.1', '>= 0.1.0'
  s.requirements << 'ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-linux]'
  s.requirements << 'gtk3app: 1.5.0'
  s.requirements << 'system: linux/bash'

end
