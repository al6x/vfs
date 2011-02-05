module Vfs
  class File < Entry
    # 
    # Attributes
    # 
    alias_method :exist?, :file?
    
    
    #
    # CRUD
    #
    def read raise_if_not_exist = true, &block
      storage.read_file path, &block
    rescue RuntimeError => e
      raise Vrs::Error, "can't read Dir #{self}!" if to_dir.exist?
      if exist?
        # unknown internal error
        raise e
      else
        if raise_if_not_exist
          raise Vfs::Error, "file #{self} not exist!"          
        else
          block ? block.call('') : ''
        end        
      end      
    end
    
    def create override = false
      write '', false
    end    
    def create!
      create true
    def 
        
    def write data, override = false, &block
      block ||= -> data {writer.call data}
      storage.write_file path, &block
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
    def write! data, &block
      write data, true, &block
    end
    
    def destroy force = false
      storage.delete_file path          
    rescue RuntimeError => e
      attrs = get
      if attrs[:dir]
        if force
          to_dir.destroy          
        else
          raise Vfs::Error, "can't destroy Dir #{to_dir} (you are trying to destroy it as if it's a File)"
        end
      elsif attrs[:file]
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