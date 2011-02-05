module Vfs
  class Dir < Entry
    # 
    # Attributes
    # 
    alias_method :exist?, :dir?
    
    
    #
    # CRUD
    #
    def create override = false
      driver.create_dir path
    rescue RuntimeError
      parent && parent.create(override)

      # override if already exist and :override specified
      entry = to_entry
      if override
        entry.destroy
        retry
      else
        raise Vfs::Error, "entry #{self} already exist!"
      end
    end    
    def create!
      create true
    def 
            
    def destroy force = false
      driver.delete_dir path          
    rescue RuntimeError => e
      attrs = get
      if attrs[:file]
        if force
          to_file.destroy
        else
          raise Vfs::Error, "can't destroy File #{to_dir} (You are trying to destroy it as if it's a Dir)"
        end
      elsif attrs[:dir]
        # unknown internal error
        raise e
      else
        # do nothing, file already not exist
      end
    end
    def destroy!
      destroy true
    end
  end
end