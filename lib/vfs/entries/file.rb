module Vfs
  class File < Entry
    # 
    # Attributes
    # 
    alias_method :exist?, :file?
    
    
    #
    # CRUD
    #
    def read options = {}, &block
      options[:bang] = true unless options.include? :bang
      if block
        storage.read_file path, &block
      else
        data = ""
        storage.read_file(path){|buff| data << buff}
        data
      end
    rescue StandardError => e
      raise Vrs::Error, "can't read Dir #{self}!" if dir.exist?
      attrs = get
      if attrs[:file]
        # unknown internal error
        raise e
      elsif attrs[:dir]
        raise Error, "You are trying to read Dir '#{self}' as if it's a File!"
      else
        if options[:bang]
          raise Error, "file #{self} not exist!"
        else
          block ? block.call('') : ''
        end        
      end      
    end
    
    def create options = {}
      write '', options
      self
    end    
    def create! options = {}
      options[:override] = true
      create options
    end
        
    def write *args, &block
      if block
        options = args.first || {}
        storage.write_file(path, &block)
      else
        data, options = *args
        options ||= {}
        storage.write_file(path){|writer| writer.call data}
      end
    rescue StandardError => error
      entry = self.entry
      if entry.exist?
        if options[:override]
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
          parent.create(options)        
        end
      end
      
      retry
    end    
    def write! *args, &block
      args << {} unless args.last.is_a? Hash
      args.last[:override] = true
      write *args, &block
    end
    
    def destroy options = {}
      storage.delete_file path          
      self
    rescue StandardError => e
      attrs = get
      if attrs[:dir]
        if options[:force]
          dir.destroy          
        else
          raise Error, "can't destroy Dir #{dir} (you are trying to destroy it as if it's a File)"
        end
      elsif attrs[:file]
        # unknown internal error
        raise e
      else
        # do nothing, file already not exist
      end
      self
    end
    def destroy! options = {}
      options[:force] = true
      destroy options
    end
    
    
    #
    # Transfers
    #      
    def copy_to to, options = {}
      raise Error, "you can't copy to itself" if self == to
     
      target = if to.is_a? File
        to
      elsif to.is_a? Dir
        to.file #(name)  
      elsif to.is_a? UniversalEntry
        to.file      
      else
        raise "can't copy to unknown Entry!"
      end      
      
      target.write options do |writer|
        read(options){|buff| writer.call buff}
      end
      
      target
    end
    def copy_to! to, options = {}
      options[:override] = true
      copy_to to, options
    end
    
    def move_to to, options = {}
      copy_to to, options
      destroy options
      to
    end
    def move_to! to, options = {}
      options[:override] = true
      move_to to, options
    end
  end
end