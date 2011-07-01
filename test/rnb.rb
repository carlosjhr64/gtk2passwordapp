require 'gtk2passwordapp/rnd'
include Gtk2Password

module Test
    def self.cf?(count)
      common_factor = Rnd::NUMBERS.inject(true){|boolean,number| boolean && (count%number==0)}
    end

    def self.lcf
      count, common_factor = Rnd::NUMBERS.minmax.inject(1,:*) - 1, false
      while !common_factor do
        count += 1
        common_factor = Test.cf?(count)
      end
      return count
    end

  errors = 0

  if Rnd::REALRAND then
    puts "Got REALRAND"
  else
    errors += 1
    puts "REALRAND not available"
  end

  puts "Acceptable random numbers #{Rnd::NUMBERS.join(', ')}."
  puts "LCF = #{Rnd::LCF}"

  if !Test.cf?(Rnd::LCF) then
    errors += 1
    "LCF is not a common factor"
  end

  if !(Rnd::LCF == Test.lcf) then
    errors += 1
    "LCF is not the lowest common factor"
  end

  rnd = Rnd.new
  Thread.pass
  puts "Refilling..."
  Thread.pass
  while rnd.refilling do
    Thread.pass
  end
  puts rnd.bucket.join(' ')

  puts "Bucket size: #{Rnd::BUCKET_LENGTH}"
  if !(rnd.bucket.length == Rnd::BUCKET_LENGTH) then
    errors += 1
    puts "Did not fill bucket to #{Rnd::BUCKET_LENGTH}"
  end

  puts "Some randomized numbers"
  Rnd::NUMBERS.each do |number|
    r = Rnd.randomize(number,number)
    puts "Number:#{number} Random:#{r}"
    errors += 1 if r == number
    errors += 1 if r < 0
  end

  puts "Some real_random numbers"
  Rnd::NUMBERS.each do |number|
    r = rnd.real_random(number)
    puts "Number:#{number} Random:#{r}"
    errors += 1 if r == number
    errors += 1 if r < 0
  end

  puts "Bucket size after use #{rnd.bucket.length}"
  if !(rnd.bucket.length == Rnd::BUCKET_LENGTH - Rnd::NUMBERS.length) then
    errors += 1
    puts "Got an unexpected bucket size after use"
  end

  valid = Rnd::NUMBERS.max
  not_valid = valid + 1

  puts "#{valid} is a valid number, should continue..."
  got_error = false
  begin
    rnd.validate(valid)
  rescue Exception
    puts $!
    errors += 1
    got_error = true
  ensure
    puts "That should not have happened!" if got_error
  end

  puts "#{not_valid} is a NOT valid number, should raise exit"
  got_exit = false
  begin
    rnd.validate(not_valid)
  rescue Exception
    if !($!.message == 'exit') then
      errors += 1
    else
      got_exit = true
    end
  ensure
    puts "Did not raise exit, why?" unless got_exit
  end

  puts "Some rnd.random numbers"
  Rnd::NUMBERS.each do |number|
    r = rnd.random(number)
    puts "Number:#{number} Random:#{r}"
    errors += 1 if r == number
    errors += 1 if r < 0
  end

  puts "Bucket size after second use #{rnd.bucket.length}"
  if !(rnd.bucket.length == Rnd::BUCKET_LENGTH - 2*Rnd::NUMBERS.length) then
    errors += 1
    puts "Got an unexpected bucket size after second use"
  end

  puts "There were #{errors} error."
end
