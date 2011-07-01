require 'gtk2passwordapp/iocrypt'

  include Gtk2Password
  errors = 0
  puts "IOCrypt::LENGTH: #{IOCrypt::LENGTH}"
  if !(IOCrypt::LENGTH == 16) then
    errors += 1
    puts "Expected 16"
  end
  iocrypt = IOCrypt.new("IOCrypt Testing")
  data = ['This','is','a','test.']
  dump = './test.dump'
  iocrypt.dump(dump,data)
  if File.exist?(dump) then
    data = iocrypt.load(dump)
    if (data.class == Array) then
      result =  data.join(' ')
      puts result
      if !(result == 'This is a test.') then
        errors += 1
        puts 'Could not decrypt dump file.'
      end
    else
      errors += 1
      puts "Expected Array data"
    end
    File.unlink(dump)
  else
    puts "Did not create dump file"
    puts errors+=1
  end
  puts "There were #{errors} errors."
