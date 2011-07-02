require 'gtk2passwordapp/passwords'

  include Gtk2Password
  errors = 0
  dump = './test.dump'
  File.unlink(dump) if File.exist?(dump)

  pwds = Passwords.new(dump,'password')

  if !(dump == pwds.dumpfile) then
    errors += 1
    puts "Dumpfile did not match"
  end

  if pwds.exist? then
    errors += 1
    puts "Did not expect passwords file to exist yet"
  end

  puts "Creating new account" 
  pwds = Passwords.new(dump) do |prompt|
    print "#{prompt}: "
    ret = $stdin.gets.strip
    (ret.length==0)? nil: ret
  end

  puts "Now relog in"
  pwds = Passwords.new(dump) do |prompt|
    print "#{prompt}: "
    ret = $stdin.gets.strip
    (ret.length==0)? nil: ret
  end

  puts "Now relog in, but purposely enter the wrong password"
  pwds = Passwords.new(dump) do |prompt|
    print "#{prompt}: "
    ret = $stdin.gets.strip
    (ret.length==0)? nil: ret
  end

  pwds.save!('Dude!')
  puts "Password was reset to 'Dude!'.  Now relog in:"
  pwds = Passwords.new(dump) do |prompt|
    print "#{prompt}: "
    ret = $stdin.gets.strip
    (ret.length==0)? nil: ret
  end

  File.unlink(dump) if File.exist?(dump)
  puts "There were #{errors} errors."
