module Vfs
  class Entry
    attr_reader :storage, :path, :path_cache

    def initialize *args
      if args.size == 1 and args.first.is_a? Entry
        entry = args.first
        @path_cache = entry.path_cache
        @storage, @path = entry.storage, entry.path
      else
        storage, path = *args
        @path_cache = Path.new path
        @storage, @path = storage, path_cache.to_s
      end
      raise "storage not defined!" unless self.storage
    end


    #
    # Navigation
    #
    def parent
      Dir.new(storage, path_cache + '..')
    end


    #
    # Transformations
    #
    def dir path = nil
      if path
        new_path = path_cache + path
        Dir.new storage, new_path
      else
        Dir.new self
      end
    end
    alias_method :to_dir, :dir

    def file path = nil
      if path
        new_path = path_cache + path
        File.new storage, new_path
      else
        File.new self
      end
    end
    alias_method :to_file, :file

    def entry path = nil
      entry = if path

        new_path = path_cache + path
        klass = new_path.probably_dir? ? Dir : UniversalEntry
        entry = klass.new storage, new_path
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
      attrs = storage.open{|fs| fs.attributes(path)}
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
      storage.open do |fs|
        if block
          fs.tmp do |path|
            block.call Dir.new(storage, path)
          end
        else
          Dir.new storage, fs.tmp
        end
      end
    end

    def local?
      storage.local?
    end


    #
    # Utils
    #
    def inspect
      "#{storage}#{':' unless storage.to_s.empty?}#{path}"
    end
    alias_method :to_s, :inspect

    def == other
      return false unless other.is_a? Entry
      storage == other.storage and path == other.path
    end

    def hash
      storage.hash + path.hash
    end

    def eql? other
      return false unless other.class == self.class
      storage.eql?(other.storage) and path.eql?(other.path)
    end
    
    protected
      def destroy_entry first = :file, second = :dir
        storage.open do |fs|
          begin
            fs.send :"delete_#{first}", path
          rescue StandardError => e
            attrs = get
            if attrs and attrs[first]
              # some unknown error
              raise e              
            elsif attrs and attrs[second]
              fs.send :"delete_#{second}", path
            else
              # do nothing, entry already not exist
            end
          end
        end
        self
      end
  end
end