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
      self['..']
    end
        
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
        UniversalEntry.new storage, new_path
      else
        UniversalEntry.new storage, path_cache
      end
      EntryProxy.new entry
    end
    alias_method :to_entry, :entry
    
    def [] path
      path = path.to_s
      entry = if path =~ /.+[\/]$/
        path = path.sub /\/$/, ''
        new_path = path_cache + path
        Dir.new storage, new_path
      else
        new_path = path_cache + path
        klass = new_path.probably_dir? ? Dir : UniversalEntry
        klass.new storage, new_path
      end
      EntryProxy.new(entry)
    end
        
    
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
    # Utils
    #             
    def inspect
      "#{storage}:#{path}"
    end
    alias_method :to_s, :inspect
    
    protected
      attr_reader :path_cache
      
      def driver
        storage.driver
      end
  end
end