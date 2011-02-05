module Vfs
  class Entry
    attr_reader :storage, :path
    
    def initialize storage, path
      @path_cache = path.is_a?(Path) ? path : Path.new(path)
      @storage, @path = storage, path_cache.to_s
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
        Dir.new storage, path_cache
      end
    end
    alias_method :to_dir, :dir
    
    def file path = nil
      if path
        new_path = path_cache + path
        File.new storage, new_path
      else
        File.new storage, path_cache
      end
    end
    alias_method :to_file, :file
    
    def entry path = nil
      entry = if path
        
        new_path = path_cache + path
        klass = new_path.probably_dir? ? Dir : UniversalEntry
        entry = klass.new storage, new_path        
      else
        UniversalEntry.new storage, path_cache
      end
      EntryProxy.new entry
    end
    alias_method :to_entry, :entry
                
                
    # 
    # Attributes
    # 
    def get attr_name = nil
      attrs = storage.attributes(path)
      attr_name ? (attrs && attrs[attr_name]) : (attrs || {})
    end
    
    def set options
      not_implemented
    end
    
    def dir?
      !!get(:dir)
    end
    
    def file?
      !!get(:file)
    end
    
    
    # 
    # Micelaneous
    # 
    def name
      path_cache.name
    end
        
    
    # 
    # Utils
    #             
    def inspect
      "#{storage}:#{path}"
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
      attr_reader :path_cache
      
      def driver
        storage.driver
      end
  end
end