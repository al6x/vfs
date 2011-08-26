require 'tempfile'

module Vfs
  module Storages
    class Local
      class Writer
        def initialize out; @out = out end

        def write data; @out.write data end
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
          path = with_root path

          stat = ::File.stat path
          attrs = {}
          attrs[:file] = !!stat.file?
          attrs[:dir]  = !!stat.directory?

          # attributes special for file system
          attrs[:created_at] = stat.ctime
          attrs[:updated_at] = stat.mtime
          attrs[:size]       = stat.size if attrs[:file]
          attrs
        rescue Errno::ENOENT
          nil
        end

        def set_attributes path, attrs
          # TODO2 set attributes
          not_implemented
        end


        #
        # File
        #
        def read_file path, &block
          path = with_root path
          ::File.open path, 'r' do |is|
            while buff = is.gets(self.buffer || DEFAULT_BUFFER)
              block.call buff
            end
          end
        end

        def write_file original_path, append, &block
          path = with_root original_path

          option = append ? 'a' : 'w'
          ::File.open path, option do |out|
            block.call Writer.new(out)
          end
        end

        def delete_file path
          path = with_root path
          ::File.delete path
        end

        # def move_file from, to
        #   FileUtils.mv from, to
        # end


        #
        # Dir
        #
        def create_dir path
          path = with_root path
          ::Dir.mkdir path
        end

        def delete_dir original_path
          path = with_root original_path
          ::FileUtils.rm_r path
        end

        def each_entry path, query, &block
          path = with_root path

          if query
            path_with_trailing_slash = path == '/' ? path : "#{path}/"
            ::Dir["#{path_with_trailing_slash}#{query}"].each do |absolute_path|
              name = absolute_path.sub path_with_trailing_slash, ''
              block.call name, ->{::File.directory?(absolute_path) ? :dir : :file}
              # if ::File.directory? absolute_path
              #   block.call relative_path, :dir
              # else
              #   block.call relative_path, :file
              # end
            end
          else
            ::Dir.foreach path do |name|
              next if name == '.' or name == '..'
              block.call name, ->{::File.directory?("#{path}/#{name}") ? :dir : :file}
              # if ::File.directory? "#{path}/#{relative_name}"
              #   block.call relative_name, :dir
              # else
              #   block.call relative_name, :file
              # end
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
          path = "/tmp/#{rand(10**6)}"
          # tmp_dir = "#{::Dir.tmpdir}/#{rand(10**6)}"
          if block
            begin
              ::FileUtils.mkdir_p with_root(path)
              block.call path
            ensure
              ::FileUtils.rm_r with_root(path) if ::File.exist? with_root(path)
            end
          else
            ::FileUtils.mkdir_p with_root(path)
            path
          end
        end

        def to_s; '' end

        protected
          def root
            @root || raise('root not defined!')
          end

          def with_root path
            path == '/' ? root : root + path
          end
      end

      include LocalVfsHelper

      def initialize root = ''
        @root = root
      end

      def open &block
        block.call self if block
      end
      def close; end
    end
  end
end