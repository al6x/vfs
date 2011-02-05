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
    rescue StandardError => error
      entry = self.entry
      if entry.exist?
        if override
          entry.destroy
        else
          raise Error, "entry #{self} already exist!"
        end
      else
        parent = self.parent
        if parent.exist?
          # some unknown error
          raise error          
        else
          parent.create(override)        
        end        
      end
      
      retry
    end    
    def create!
      create true
    end
            
    def destroy force = false
      driver.delete_dir path          
    rescue StandardError => e
      attrs = get
      if attrs[:file]
        if force
          file.destroy
        else
          raise Error, "can't destroy File #{dir} (You are trying to destroy it as if it's a Dir)"
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