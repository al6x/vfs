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
      storage.open do |fs|
        begin
          if block
            fs.read_file path, &block
          else
            data = ""
            fs.read_file(path){|buff| data << buff}
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

    def content options = {}
      read options
    end

    def create options = {}
      write '', options
      self
    end
    def create! options = {}
      options[:override] = true
      create options
    end

    def write *args, &block
      if block
        options = args.first || {}
      else
        data, options = *args
        options ||= {}
      end
      raise "can't do :override and :append at the same time!" if options[:override] and options[:append]

      storage.open do |fs|
        # TODO2 Performance lost, extra call to check file existence
        # We need to check if the file exist before writing to it, otherwise it's
        # impossible to distinguish if the StandardError caused by the 'already exist' error or
        # some other error.
        entry = self.entry
        if entry.exist?
          if options[:override]
            entry.destroy
          else
            raise Error, "entry #{self} already exist!"
          end
        end

        try = 0
        begin
          try += 1
          if block
            fs.write_file(path, options[:append], &block)
          else
            fs.write_file(path, options[:append]){|writer| writer.write data}
          end
        rescue StandardError => error
          parent = self.parent
          if parent.exist?
            # some unknown error
            raise error
          else
            parent.create(options)
          end

          try < 2 ? retry : raise(error)
        end
      end
      self
    end
    def write! *args, &block
      args << {} unless args.last.is_a? Hash
      args.last[:override] = true
      write *args, &block
    end

    def append *args, &block
      options = (args.last.is_a?(Hash) && args.pop) || {}
      options[:append] = true
      write(*(args << options), &block)
    end

    def update options = {}, &block
      options[:override] = true
      data = read options
      write block.call(data), options
    end

    def destroy options = {}
      storage.open do |fs|
        begin
          fs.delete_file path
          self
        rescue StandardError => e
          attrs = get
          if attrs and attrs[:dir]
            if options[:force]
              dir.destroy
            else
              raise Error, "can't destroy Dir #{dir} (you are trying to destroy it as if it's a File)"
            end
          elsif attrs and attrs[:file]
            # unknown internal error
            raise e
          else
            # do nothing, file already not exist
          end
        end
      end
      self
    end
    def destroy! options = {}
      options[:force] = true
      destroy options
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
    def copy_to! to, options = {}
      options[:override] = true
      copy_to to, options
    end

    def move_to to, options = {}
      copy_to to, options
      destroy options
      to
    end
    def move_to! to, options = {}
      options[:override] = true
      move_to to, options
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