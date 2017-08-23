Gem::Specification.new do |s|

  s.name     = 'gtk2passwordapp'
  s.version  = '5.1.0'

  s.homepage = 'https://github.com/carlosjhr64/gtk2passwordapp'

  s.author   = 'carlosjhr64'
  s.email    = 'carlosjhr64@gmail.com'

  s.date     = '2017-08-23'
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
  s.rdoc_options     = ['--main', 'README.rdoc']

  s.require_paths = ['lib']
  s.files = %w(
README.rdoc
bin/gtk2pwdV
data/VERSION
data/logo.png
lib/gtk2passwordapp.rb
lib/gtk2passwordapp/account.rb
lib/gtk2passwordapp/accounts.rb
lib/gtk2passwordapp/config.rb
lib/gtk2passwordapp/gtk2pwdv.rb
lib/gtk2passwordapp/such_parts.rb
lib/gtk2passwordapp/version.rb
  )

  s.executables << 'gtk2pwdV'
  s.add_runtime_dependency 'yaml_zlib_blowfish', '~> 1.0', '>= 1.0.0'
  s.add_runtime_dependency 'gtk3app', '~> 2.0', '>= 2.0.0'
  s.add_runtime_dependency 'super_random', '~> 1.0', '>= 1.0.0'
  s.add_runtime_dependency 'base_convert', '~> 2.0', '>= 2.0.0'
  s.add_runtime_dependency 'helpema', '~> 0.2', '>= 0.2.0'
  s.requirements << 'ruby: ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-linux]'

end
