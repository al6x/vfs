warn 'remove trailing spaces'
require 'tempfile'

module Vfs
  module Storages
    class Local
      class Writer
        def initialize out
          @out = out
        end
        
        def write data
          @out.write data
        end
      end
      
      module LocalVfsHelper
        DEFAULT_BUFFER = 1000 * 1024
        
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
          attrs[:size] = stat.size if stat.file?
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
          # TODO2 Performance lost, extra call to check file existence
          raise "can't write, entry #{path} already exist!" if !append and ::File.exist?(path)
          
          option = append ? 'a' : 'w'          
          ::File.open path, option do |out|
            block.call Writer.new(out)
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
          # TODO2 Performance lost, extra call to check file existence
          raise "can't delete file (#{path})!" if ::File.file?(path)
          
          FileUtils.rm_r path
        end      

        def each_entry path, query, &block
          if query
            path_with_trailing_slash = path == '/' ? path : "#{path}/"
            ::Dir["#{path_with_trailing_slash}#{query}"].each do |absolute_path|
              relative_path = absolute_path.sub path_with_trailing_slash, ''
              if ::File.directory? absolute_path
                block.call relative_path, :dir
              else
                block.call relative_path, :file
              end
            end
          else
            ::Dir.foreach path do |relative_name|
              next if relative_name == '.' or relative_name == '..'
              if ::File.directory? "#{path}/#{relative_name}"
                block.call relative_name, :dir
              else
                block.call relative_name, :file
              end
            end
          end
        end
        
        # def efficient_dir_copy from, to, override          
        #   return false if override # FileUtils.cp_r doesn't support this behaviour
        #     
        #   from.storage.open_fs do |from_fs|          
        #     to.storage.open_fs do |to_fs|
        #       if from_fs.local? and to_fs.local?
        #         FileUtils.cp_r from.path, to.path
        #         true
        #       else
        #         false
        #       end
        #     end
        #   end
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