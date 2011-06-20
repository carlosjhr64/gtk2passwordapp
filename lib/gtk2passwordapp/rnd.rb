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

    def initialize
      @bucket = []
      @refilling = false
      self.refill	if REALRAND
    end

    def refill
      return if @refilling
      @refilling = true
      Thread.new do
        begin
          Timeout.timeout(60) do
            generator1 = Random::RandomOrg.new
            @bucket += generator1.randnum(200, 0, 2657849) # 2657850 % <75,10,58,26,94>
          end
        rescue Exception
          $stderr.puts $!
          $stderr.puts "Failed to fill the bucket"
        ensure
          @refilling = false
        end
      end
    end

    def random(n)
      if ![75,10,58,26,94].include?(n) then
        $stderr.puts "Did not code for that number" 
        exit # seriously messed up! :))
      end
      if REALRAND then
        refill if @bucket.length < 100
        if rnd = @bucket.shift then
          rnd = ((rnd + rand(n)) % n)
          return rnd
        else
          return rand(n)
        end
      else
        return rand(n)
      end
      raise "Should not get here"
    end

    RND = Rnd.new
  end
end
