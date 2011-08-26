module Vfs
  class Entry
    attr_reader :driver, :path, :path_cache

    def initialize *args
      if args.size == 1 and args.first.is_a? Entry
        entry = args.first
        @path_cache = entry.path_cache
        @driver, @path = entry.driver, entry.path
      else
        driver, path = *args
        @path_cache = Path.new path
        @driver, @path = driver, path_cache.to_s
      end
      raise "driver not defined!" unless self.driver
    end

    #
    # Navigation
    #
    def parent
      Dir.new(driver, path_cache + '..')
    end


    #
    # Transformations
    #
    def dir path = nil
      if path
        new_path = path_cache + path
        Dir.new driver, new_path
      else
        Dir.new self
      end
    end
    alias_method :to_dir, :dir

    def file path = nil
      if path
        new_path = path_cache + path
        File.new driver, new_path
      else
        File.new self
      end
    end
    alias_method :to_file, :file

    def entry path = nil
      entry = if path
        new_path = path_cache + path
        klass = new_path.probably_dir? ? Dir : UniversalEntry
        klass.new driver, new_path
      else
        UniversalEntry.new self
      end
      EntryProxy.new entry
    end
    alias_method :to_entry, :entry


    #
    # Attributes
    #
    def get attr_name = nil
      attrs = driver.open{driver.attributes(path)}
      (attr_name and attrs) ? attrs[attr_name] : attrs
    end

    def set options
      # TODO2 set attributes
      not_implemented
    end

    def dir?; !!get(:dir) end
    def file?; !!get(:file) end
    def created_at; get :created_at end
    def updated_at; get :updated_at end


    #
    # Miscellaneous
    #
    def name
      path_cache.name
    end

    def tmp &block
      driver.open do
        if block
          driver.tmp do |path|
            block.call Dir.new(driver, path)
          end
        else
          Dir.new driver, driver.tmp
        end
      end
    end

    def local?
      driver.local?
    end


    #
    # Utils
    #
    def inspect
      "#{driver}#{':' unless driver.to_s.empty?}#{path}"
    end
    alias_method :to_s, :inspect

    def == other
      return false unless other.is_a? Entry
      driver == other.driver and path == other.path
    end

    def hash
      driver.hash + path.hash
    end

    def eql? other
      return false unless other.class == self.class
      driver.eql?(other.driver) and path.eql?(other.path)
    end

    protected
      def destroy_entry first = :file, second = :dir
        driver.open do
          begin
            driver.send :"delete_#{first}", path
          rescue StandardError => e
            attrs = get
            if attrs and attrs[first]
              # some unknown error
              raise e
            elsif attrs and attrs[second]
              driver.send :"delete_#{second}", path
            else
              # do nothing, entry already not exist
            end
          end
        end
        self
      end
  end
end