module Gtk2Password
  # This class combines realrand with rand such that
  # if either one is honest, we'll get honest random numbers.
  class Rnd

    BUCKET_LENGTH = 100
    NUMBERS = [75,10,58,26,94]
    LCF = 2657850
    RANDOM_ORG = 'http://www.random.org/integers/'

    attr_reader :bucket, :refilling
    def initialize
      begin
        raise "no command line realrand" if $options =~ /-no-gui/
        # Checking if online refill of real random numbers available....
        require 'open-uri'
        require 'timeout'
        @bucket = []
        @refilling = false
        self.refill_timeout
      rescue Exception
        $stderr.puts $!
        @bucket = nil
        @refilling = false
      end
    end

    def refill_timeout
      Timeout.timeout(60) do
        @bucket += open("#{RANDOM_ORG}?num=#{BUCKET_LENGTH}&min=0&max=#{LCF-1}&col=#{BUCKET_LENGTH}&format=plain&base=10&rnd=new").read.strip.split(/\s+/).map{|s| s.to_i}
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
      refill if @bucket.length < BUCKET_LENGTH/2
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
      (@bucket)? real_random(number) : rand(number)
    end

    RND = Rnd.new
  end
end
