require 'tempfile'

module Vfs
  module Storages
    class Local
      module LocalVfsHelper
        DEFAULT_BUFFER = 1024*128
        
        attr_writer :buffer
        def buffer
          @buffer || DEFAULT_BUFFER
        end        
        
        # 
        # Attributes
        # 
        def attributes path
          stat = ::File.stat path
          attrs = {}
          attrs[:file] = stat.file?
          attrs[:dir] = stat.directory?
          
          # attributes special for file system
          attrs[:created_at] = stat.ctime
          attrs[:updated_at] = stat.mtime
          attrs
        rescue Errno::ENOENT
          {}
        end

        def set_attributes path, attrs      
          raise 'not supported'
        end


        # 
        # File
        #       
        def read_file path, &block
          ::File.open path, 'r' do |is|
            while buff = is.gets(self.buffer || DEFAULT_BUFFER)            
              block.call buff
            end
          end
        end

        def write_file path, append, &block        
          option = append ? 'a' : 'w'
          ::File.open path, option do |os|
            writer = -> buff {os.write buff}
            block.call writer
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

        def each_entry path, &block
          ::Dir.foreach path do |relative_name|
            next if relative_name == '.' or relative_name == '..'
            if ::File.directory? "#{path}/#{relative_name}"
              block.call relative_name, :dir
            else
              block.call relative_name, :file
            end
          end
        end
        
        def efficient_dir_copy from, to, override          
          return false if override # FileUtils.cp_r doesn't support this behaviour
            
          from.storage.open_fs do |from_fs|          
            to.storage.open_fs do |to_fs|
              if from_fs.local? and to_fs.local?
                FileUtils.cp_r from.path, to.path
                true
              else
                false
              end
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
        # Other
        # 
        def local?; true end
        
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
        
        def to_s; '' end
      end
      
      include LocalVfsHelper
      
      def open_fs &block
        block.call self
      end
    end
  end
end