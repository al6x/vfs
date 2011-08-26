module Vfs
  class File < Entry
    #
    # Attributes
    #
    alias_method :exist?, :file?


    #
    # CRUD
    #
    def read options = {}, &block
      options[:bang] = true unless options.include? :bang
      driver.open do
        begin
          if block
            driver.read_file path, &block
          else
            data = ""
            driver.read_file(path){|buff| data << buff}
            data
          end
        rescue StandardError => e
          raise Vfs::Error, "can't read Dir #{self}!" if dir.exist?
          attrs = get
          if attrs and attrs[:file]
            # unknown internal error
            raise e
          elsif attrs and attrs[:dir]
            raise Error, "You are trying to read Dir '#{self}' as if it's a File!"
          else
            if options[:bang]
              raise Error, "file #{self} not exist!"
            else
              block ? block.call('') : ''
            end
          end
        end
      end
    end

    # def content options = {}
    #   read options
    # end

    def create options = {}
      write '', options
      self
    end

    def write *args, &block
      if block
        options = args.first || {}
      else
        data, options = *args
        options ||= {}
      end
      raise "can't do :override and :append at the same time!" if options[:override] and options[:append]

      driver.open do
        try = 0
        begin
          try += 1
          if block
            driver.write_file(path, options[:append], &block)
          else
            driver.write_file(path, options[:append]){|writer| writer.write data}
          end
        rescue StandardError => error
          parent = self.parent
          if entry.exist?
            entry.destroy
          elsif !parent.exist?
            parent.create(options)
          else
            # unknown error
            raise error
          end

          try < 2 ? retry : raise(error)
        end
      end
      self
    end

    def append *args, &block
      options = (args.last.is_a?(Hash) && args.pop) || {}
      options[:append] = true
      write(*(args << options), &block)
    end

    def update options = {}, &block
      data = read options
      write block.call(data), options
    end

    def destroy
      destroy_entry
    end


    #
    # Transfers
    #
    def copy_to to, options = {}
      raise Error, "you can't copy to itself" if self == to

      target = if to.is_a? File
        to
      elsif to.is_a? Dir
        to.file #(name)
      elsif to.is_a? UniversalEntry
        to.file
      else
        raise "can't copy to unknown Entry!"
      end

      target.write options do |writer|
        read(options){|buff| writer.write buff}
      end

      target
    end

    def move_to to
      copy_to to
      destroy
      to
    end


    #
    # Extra Stuff
    #
    def render *args
      require 'tilt'

      args.unshift Object.new if args.size == 1 and args.first.is_a?(Hash)

      template = Tilt.new(path){read}
      template.render *args
    end

    def size; get :size end

    def basename
      ::File.basename(name, File.extname(name))
    end

    def extension
      ::File.extname(name).sub(/^\./, '')
    end
  end
end