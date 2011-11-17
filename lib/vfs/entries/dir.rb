module Vfs
  class Dir < Entry

    # Container.
    def [] path
      path = path.to_s
      if path =~ /.+[\/]$/
        path = path.sub /\/$/, ''
        dir path
      elsif path =~ /\*/
        entries path
      else
        entry path
      end
    end
    alias_method :/, :[]


    # Attributes.
    alias_method :exist?, :dir?

    # CRUD.

    def create options = {}
      driver.open do
        try = 0
        begin
          try += 1
          driver.create_dir path
        rescue StandardError => error
          entry = self.entry
          attrs = entry.get
          if attrs and attrs[:file] #entry.exist?
            entry.destroy
          elsif attrs and attrs[:dir]
            # dir already exist, no need to recreate it
            return self
          else
            parent = self.parent
            if parent.exist?
              # some unknown error
              raise error
            else
              parent.create(options)
            end
          end

          try < 2 ? retry : raise(error)
        end
      end
      self
    end

    def delete options = {}
      delete_entry :dir, :file
    end

    # Content.

    def entries *args, &block
      raise "invalid arguments #{args.inspect}!" if args.size > 2
      options = args.last.is_a?(Hash) ? args.pop : {}
      query = args.first
      options[:bang] = true unless options.include? :bang
      filter = options[:filter]
      type_required = options[:type]

      driver.open do
        begin
          list = []
          # Query option is optional and supported only for some drivers (local driver for example).
          driver.each_entry path, query do |name, type|
            # For performance reasons some drivers may return the type of entry as
            # optionally evaluated callback.
            type = type.call if (filter or type_required) and type.is_a?(Proc)

            next if filter and (filter != type)

            entry = if type == :dir
              dir(name)
            elsif type == :file
              file(name)
            else
              entry(name)
            end
            block ? block.call(entry) : (list << entry)
          end
          block ? nil : list
        rescue StandardError => error
          attrs = get
          if attrs and attrs[:file]
            raise Error, "can't query entries on File ('#{self}')!"
          elsif attrs and attrs[:dir]
            # Some unknown error.
            raise error
          else
            # TODO2 remove :bang.
            raise Error, "'#{self}' not exist!" if options[:bang]
            []
          end
        end
      end
    end
    alias_method :each, :entries

    def files *args, &block
      options = args.last.is_a?(Hash) ? args.pop : {}

      options[:filter] = :file
      args << options
      entries *args, &block
    end

    def dirs *args, &block
      options = args.last.is_a?(Hash) ? args.pop : {}

      options[:filter] = :dir
      args << options
      entries *args, &block
    end

    def include? name
      entry[name].exist?
    end
    alias_method :has?, :include?

    def empty?
      catch :break do
        entries{|e| throw :break, false}
        true
      end
    end

    # Transfers.

    def copy_to to, options = {}
      options[:bang] = true unless options.include? :bang

      raise Error, "invalid argument, destination should be a Entry (#{to})!" unless to.is_a? Entry
      raise Error, "you can't copy to itself" if self == to

      target = if to.is_a? File
        to.dir
      elsif to.is_a? Dir
        to.dir
      elsif to.is_a? UniversalEntry
        to.dir
      else
        raise "can't copy to unknown Entry!"
      end

      # efficient_dir_copy(target, options) || unefficient_dir_copy(target, options)
      unefficient_dir_copy(target, options)

      target
    end

    def move_to to, options = {}
      copy_to to, options
      destroy options
      to
    end

    protected
      def unefficient_dir_copy to, options
        to.create options
        entries options.merge(type: true) do |e|
          if e.is_a? Dir
            e.copy_to to.dir(e.name), options
          elsif e.is_a? File
            e.copy_to to.file(e.name), options
          else
            raise 'internal error'
          end
        end
      end

      # def efficient_dir_copy to, options
      #   return false if self.class.dont_use_efficient_dir_copy
      #
      #   driver.open do
      #     try = 0
      #     begin
      #       try += 1
      #       self.class.efficient_dir_copy(self, to, options[:override])
      #     rescue StandardError => error
      #       unknown_errors = 0
      #
      #       attrs = get
      #       if attrs and attrs[:file]
      #         raise Error, "can't copy File as a Dir ('#{self}')!"
      #       elsif attrs and attrs[:dir]
      #         # some unknown error (but it also maybe caused by to be fixed error in 'to')
      #         unknown_errors += 1
      #       else
      #         raise Error, "'#{self}' not exist!" if options[:bang]
      #         return true
      #       end
      #
      #       attrs = to.get
      #       if attrs and attrs[:file]
      #         if options[:override]
      #           to.destroy
      #         else
      #           raise Vfs::Error, "entry #{to} already exist!"
      #         end
      #       elsif attrs and attrs[:dir]
      #         unknown_errors += 1
      #         # if options[:override]
      #         #   to.destroy
      #         # else
      #         #   dir_already_exist = true
      #         #   # raise Vfs::Error, "entry #{to} already exist!"
      #         # end
      #       else # parent not exist
      #         parent = to.parent
      #         if parent.exist?
      #           # some unknown error (but it also maybe caused by already fixed error in 'from')
      #           unknown_errors += 1
      #         else
      #           parent.create(options)
      #         end
      #       end
      #
      #       raise error if unknown_errors > 1
      #       try < 2 ? retry : raise(error)
      #     end
      #   end
      # end
      #
      # def self.efficient_dir_copy from, to, override
      #   from.driver.open{
      #     driver.respond_to?(:efficient_dir_copy) and driver.efficient_dir_copy(from, to, override)
      #   } or
      #   to.driver.open{
      #     driver.respond_to?(:efficient_dir_copy) and driver.efficient_dir_copy(from, to, override)
      #   }
      # end
  end
end