module Vfs
  class Box
    include Marks, Operations
    
    attr_accessor :options
    
    def initialize options = {}
      @options = options
      options[:host] ||= 'localhost'
    end
    
    def driver
      unless @driver
        klass = options[:host] == 'localhost' ? Drivers::Local : Drivers::Ssh
        @driver = klass.new options
      end
      @driver
    end






    
    def local_driver
      @local_driver ||= Drivers::Local.new
    end





        
    def opened?; !!@opened end
    def open &block
      if @opened
        block.call if block
      else
        begin
          driver.open; @opened = true
          block.call if block
        ensure
          driver.close; @opened = false if block
        end
      end
    end    
    def close
      driver.close; @opened = false if opened?
    end
  end
end