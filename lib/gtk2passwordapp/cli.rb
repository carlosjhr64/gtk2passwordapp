class Gtk2PasswordApp
def self.run(pattern='.', dump=File.expand_path('~/.cache/gtk3app/gtk2passwordapp/dump.yzb'), *trash)
  unless trash.empty?
    $stderr.puts HELP
    $stderr.puts "Please match usage."
    exit 64
  end
  begin
    pattern = Regexp.new pattern, Regexp::IGNORECASE
  rescue RegexpError
    $stderr.puts $!.message
    exit 65
  end
  unless File.exist? dump
    $stderr.puts "Passwords data file missing: #{dump}"
    exit 66
  end
  system('clear; clear')
  print "Enter password: "
  pwd = $stdin.gets.strip
  system('clear; clear')
  print "Enter salt: "
  pwd << $stdin.gets.strip
  system('clear; clear')
  h2q = BaseConvert::FromTo.new base: 16, digits: '0123456789ABCDEF', to_base: 91, to_digits: :qgraph
  pwd = h2q.convert Digest::SHA256.hexdigest(pwd).upcase
  begin
    lst = YamlZlibBlowfish.new(pwd).load(dump)
  rescue OpenSSL::Cipher::CipherError
    $stderr.puts "Bad password+salt"
    exit 65
  end
  pp lst.select{|k,v|pattern.match? k}
end
end
