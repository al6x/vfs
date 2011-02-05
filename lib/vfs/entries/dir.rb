module Vfs
  class Dir < Entry
    # 
    # Container
    #         
    def [] path
      path = path.to_s
      if path =~ /.+[\/]$/
        path = path.sub /\/$/, ''
        dir path
      else
        entry path        
      end      
    end
    alias_method :/, :[]
    
    
    # 
    # Attributes
    # 
    alias_method :exist?, :dir?
    
    
    #
    # CRUD
    #
    def create override = false      
      driver.create_dir path
      self
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
      self        
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
      self
    end
    def destroy!
      destroy true
    end
    
    
    # 
    # Content
    # 
    def entries raise_if_not_exist = true, only = nil, &block
      list = []
      driver.each path do |name, type|
        next if only and only != type
        entry = if type == :dir
          dir(name)
        elsif type == :file
          file(name)
        else
          raise 'invalid entry type!'
        end
        block ? block.call(entry) : (list << entry)
      end
      block ? nil : list
    rescue StandardError => error
      if !exist?
        raise Error, "'#{self}' not exist!" if raise_if_not_exist
        []
      else
        # unknown error
        raise error
      end
    end
    alias_method :each, :entries
    
    def files raise_if_not_exist = true, &block
      entries raise_if_not_exist, :file, &block
    end
    
    def dirs raise_if_not_exist = true, &block
      entries raise_if_not_exist, :dir, &block
    end    
  end
  
  
  # 
  # Transfers
  # 
  def copy_to entry, override = false
    raise Error, 'invalid argument' unless entry.is_a? Entry
    raise Error, "you can't copy to itself" if self == entry
    
    target = if entry.is_a? File
      raise "can't copy Dir to File ('#{self}')!" unless override
      entry.dir
    elsif entry.is_a? Dir
      entry
    elsif entry.is_a? UniversalEntry
      raise "can't copy Dir to File ('#{self}')!" if entry.file? and !override
      entry.dir.create
    else
      raise "can't copy to unknown Entry!"
    end
    
    entries do |entry|      
      entry.copy_to en
      entry.file.write override do |writer|
        read{|buff| writer.call buff}
      end
    end
  end
  def copy_to! entry
    copy_to entry, true
  end
  
  def move_to entry, override = false
    copy_to entry, override
    destroy override
  end
  def move_to! entry
    move_to entry, true
  end
end