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
    
    def dir path
      new_path = path_cache + path
      Dir.new storage, new_path
    end
    
    def file path
      new_path = path_cache + path
      File.new storage, new_path
    end
    
    def entry path
      new_path = path_cache + path
      Entry.new storage, new_path
    end
    
    def [] path
      path = path.to_s
      if path =~ /.+[\/]$/
        path = path.sub(/\/$/, '')
        new_path = path_cache + path
        Dir.new storage, new_path
      else
        new_path = path_cache + path
        klass = new_path.probably_dir? ? Dir : Entry
        klass.new storage, new_path
      end
    end
    
    def to_entry; Entry.new storage, path_cache end
    
    def to_dir; Dir.new storage, path_cache end
    
    def to_file; File.new storage, path_cache end
    
    
    # 
    # Attributes
    # 
    def get attr_name = nil
      attrs = storage.attributes(path)
      attr_name ? (attrs && attrs[name]) : (attrs || {})
    end
    
    def set options
      not_implemented
    end
    
    def exist?
      attrs = get
      attrs[:dir] or attrs[:file]
    end
    
    def dir?
      !!get(:dir)
    end
    
    def file?
      !!get(:file)
    end
    
    
    #
    # CRUD
    #
    def destroy
      attrs = get
      storage.delete_dir path if attrs[:dir]
      storage.delete_file path if attrs[:file]
    end
    
    
    # 
    # Utils
    #             
    def inspect
      "#{storage}:#{path}"
    end
    alias_method :to_s :inspect
    
    protected
      attr_reader :path_cache
      
      def driver
        storage.driver
      end
  end
end