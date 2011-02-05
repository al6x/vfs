module Vfs
  module Storages
    class Local    
      def driver
        self
      end
      
      DEFAULT_BUFFER = 1024*128
      class << self
        attr_accessor :buffer
      end
            
      
      # 
      # Attributes
      # 
      def attributes path
        stat = ::File.stat path
        attrs = {}
        attrs[:file] = stat.file?
        attrs[:dir] = stat.directory?
        attrs
      rescue Errno::ENOENT
        nil
      end
      
      def set_attributes path, attrs      
        raise 'not supported'
      end
      
      
      # 
      # File
      #       
      def read_file path, &block
        ::File.open path, 'r' do |is|
          while buff = is.gets(self.class.buffer || DEFAULT_BUFFER)            
            block.call buff
          end
        end
      end
      
      def write_file path, &block        
        ::File.open path, 'w' do |os|
          callback = -> buff {os.write buff}
          block.call callback
        end
      end
      
      def delete_file path
        ::File.delete path
      end
      
      # def move_file from, to
      #   FileUtils.mv from, to
      # end
    
      
      # 
      # Dir
      #
      def create_dir path
        ::Dir.mkdir path
      end
    
      def delete_dir path
        FileUtils.rm_r path
      end      
      
      def each path, &block
        ::Dir.foreach path do |relative_name|
          next if relative_name == '.' or relative_name == '..'
          if ::File.directory? "#{path}/#{relative_name}"
            block.call relative_name, :dir
          else
            block.call relative_name, :file
          end
        end
      end
      
      # def move_dir path
      #   raise 'not supported'
      # end
      
      # def upload_directory from_local_path, to_remote_path
      #   FileUtils.cp_r from_local_path, to_remote_path
      # end
      # 
      # def download_directory from_remote_path, to_local_path
      #   FileUtils.cp_r from_remote_path, to_local_path
      # end
      
      
      # 
      # tmp
      # 
      def tmp &block
        tmp_dir = "#{::Dir.tmpdir}/#{rand(10**3)}"        
        if block
          begin
            create_dir tmp_dir
            block.call tmp_dir
          ensure
            delete_dir tmp_dir
          end
        else
          create_dir tmp_dir
          tmp_dir
        end
      end
    end
  end
end