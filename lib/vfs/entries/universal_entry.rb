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
  end
end