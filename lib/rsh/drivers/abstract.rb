module Rsh
  module Drivers
    class Abstract
      attr_reader :options
    
      def initialize options = {}
        @options = options
      end
    
      def bulk &b
        b.call
      end
    
      def generate_tmp_dir_name
        "/tmp/ssh_tmp_dir_#{rand(10**6)}"
      end
    end
  end
end