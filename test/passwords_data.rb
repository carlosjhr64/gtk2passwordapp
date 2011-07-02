require 'gtk2passwordapp/passwords_data'

  include Gtk2Password
  errors = 0

  dump = './test.dump'
  pd = PasswordsData.new(dump,'A password')

  if pd.exist? then
    File.unlink(dump)
  end
  if File.exist?(dump) then
    errors += 1
    puts "Dumpfile should have been deleted."
  end

  if !(pd.data.class == Hash) then
    errors += 1
    puts "Data is not a hash?"
  end
  if !(pd.data.length == 0) then
    errors += 1
    puts "Expected an empty hash"
  end

 
  pd.add('2. Second Account')
  pd.add('1. First Account')

  if !(pd.data.length == 2) then
    errors += 1
    puts "Expected two account"
  end

  puts pd.accounts
  if !(pd.accounts.last == '2. Second Account') then
    errors += 1
    puts "Sort not working?"
  end

  pd.save
  pd.data.clear
  if !(pd.data.length == 0) then
    errors += 1
    puts "Expected no accounts"
  end

  pd.load
  if !(pd.data.length == 2) then
    errors += 1
    puts "Expected two accounts"
  end

  pd.reset('Bad password')
  got_it = false
  begin
    pd.load
  rescue Exception
    if $!.message == 'decryption error' then
      got_it = true
    end
  end
  if !got_it then
    errors += 1
    puts "Expected decryption error"
  end

  pd.save!('Good password')
  pd.load
  if !(pd.data.length == 2) then
    errors += 1
    puts "Expected two accounts"
  end

  if !pd.include?('1. First Account') then
    errors += 1
    puts "What happened to first account?"
  end

  if !pd.verify?('1. First Account','') then
    errors += 1
    puts "Everything is supposed to start out ''."
  end

  got_error = false
  begin
    pd.add('1. First Account')
  rescue Exception
    got_error = true
  end
  if !got_error then
    errors += 1
    puts "Expected an error on adding existing account"
  end

  pd.delete('1. First Account')
  if !(pd.data.length == 1) then
    errors += 1
    puts "Did not delete first account?"
  end

  data = pd.get_data_account('2. Second Account')
  if !(data.class == Array) then
    errors += 1
    puts "Expected to get record from secound account."
  end

  got_error = false
  begin
    pd.get_data_account('1. First Account')
  rescue Exception
    got_error = true
  end
  if !got_error then
    errors += 1
    puts "Expected a no account error"
  end

  if !pd.expired?('2. Second Account') then
    errors += 1
    puts "Since there's no password set yet, really expected expired to be true"
  end
  pd.password_of('2. Second Account','Password for second account')
  if pd.expired?('2. Second Account') then
    errors += 1
    puts "Expired?  I just set it!"
  end
  # and the rest is fine.  :P

  puts "There were #{errors} errors."



