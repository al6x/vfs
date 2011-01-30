module Ros
  class Dsl
    attr_reader :package
    
    def initialize package
      @package = package
    end
    
    def applied? &b        
      package.applied = b
    end
  
    def apply &b
      package.apply = b
    end
  end
  
  class Package
    attr_accessor :applied, :apply, :name
    
    def initialize name
      @name = name
    end
    
    def configure_with &b
      dsl = Dsl.new self
      dsl.instance_eval &b
    end
    
    def apply_to box
      unless applied and applied.call(box)
        print "applying '#{name}' to '#{box.options[:host]}'\n"
        apply.call box
        print "done\n"
      end
    end
  end
  
  class << self
    def each_box_cached &b
      unless @each_box_cached
        unless Object.private_instance_methods(false).include?(:each_box)
          raise "you must define 'each_box' method!"
        end
        
        @each_box_cached = []
        each_box do |box| 
          @each_box_cached << box
          
          # cache ssh connection
          box.open_connection
        end
      end
      @each_box_cached.each &b
    end
  end
end