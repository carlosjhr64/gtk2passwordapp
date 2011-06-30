module Gtk2Password
  # This class combines realrand with rand such that
  # if either one is honest, we'll get honest random numbers.
  class Rnd
    begin
      raise "no command line realrand" if $options =~ /-no-gui/
      gem 'realrand', '~> 1.0'
      require 'random/online'
      REALRAND = true
    rescue Exception
      $stderr.puts $!
      REALRAND = false
    end

    NUMBERS = [75,10,58,26,94]

    def initialize
      @bucket = []
      @refilling = false
      self.refill	if REALRAND
    end

    def refill_timeout
      Timeout.timeout(60) do
        generator = Random::RandomOrg.new
        @bucket += generator.randnum(100, 0, 2657849) # 2657850 % <75,10,58,26,94>
      end
    end

    def refill
      return if @refilling
      @refilling = true
      Thread.new do
        begin
          Thread.pass
          refill_timeout
        rescue Exception
          $stderr.puts $!
        ensure
          @refilling = false
        end
      end
    end

    def self.randomize(rnd,number)
      ((rnd + rand(number)) % number)
    end

    def real_random(number)
      refill if @bucket.length < 50
      if rnd = @bucket.shift then
        return Rnd.randomize(rnd,number)
      else
        return rand(number)
      end
    end

    def validate(number)
      if !NUMBERS.include?(number) then
        $stderr.puts "Did not code for that number" 
        exit # seriously messed up! :))
      end
    end

    def random(number)
      validate(number)
      (REALRAND)? real_random(number) : rand(number)
    end

    RND = Rnd.new
  end
end
