module Vfs
  class UniversalEntry < Entry
    # 
    # Attributes
    # 
    def exist?
      attrs = get
      !!(attrs[:dir] or attrs[:file])
    end
    
    
    #
    # CRUD
    #
    def destroy
      attrs = get
      storage.open_fs do |fs| 
        fs.delete_dir path if attrs[:dir]
        fs.delete_file path if attrs[:file]
      end
      self
    end
  end
end