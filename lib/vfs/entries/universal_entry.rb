module Vfs
  class UniversalEntry < Entry
    attr_reader :storage, :path    
    
    # 
    # Attributes
    # 
    def exist?
      attrs = get
      attrs[:dir] or attrs[:file]
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
    alias_method :to_s, :inspect
    
    protected
      attr_reader :path_cache
      
      def driver
        storage.driver
      end
  end
end