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
    def create options = {}
      storage.open_fs do |fs|
        try = 0
        begin
          try += 1
          fs.create_dir path
        rescue StandardError => error          
          tried = true
          entry = self.entry
          attrs = entry.get          
          if attrs[:file] #entry.exist?
            if options[:override]
              entry.destroy
            else
              raise Error, "entry #{self} already exist!"
            end
          elsif attrs[:dir]
            # do nothing
          else
            parent = self.parent
            if parent.exist?
              # some unknown error
              raise error          
            else
              parent.create(options)        
            end        
          end
      
          retry if try < 2
        end
      end
      self
    end    
    def create! options = {}
      options[:override] = true
      create options
    end
            
    def destroy options = {}
      storage.open_fs do |fs|
        begin
          fs.delete_dir path    
        rescue StandardError => e
          attrs = get
          if attrs[:file]
            if options[:force]
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
      end      
      self
    end
    def destroy! options = {}
      options[:force] = true
      destroy options
    end
    
    
    # 
    # Content
    # 
    def entries options = {}, &block
      options[:bang] = true unless options.include? :bang      
      storage.open_fs do |fs| 
        begin
          list = []
          fs.each path do |name, type|
            next if options[:filter] and options[:filter] != type
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
            raise Error, "'#{self}' not exist!" if options[:bang]
            []
          else
            # unknown error
            raise error
          end
        end
      end
    end
    alias_method :each, :entries
    
    def files options = {}, &block
      options[:filter] = :file
      entries options, &block
    end
    
    def dirs options = {}, &block
      options[:filter] = :dir
      entries options, &block
    end    
    
    def include? name
      entry[name].exist?
    end
    alias_method :has?, :include?
    
    
    # 
    # Transfers
    # 
    def copy_to entry, options = {}
      raise Error, 'invalid argument' unless entry.is_a? Entry
      raise Error, "you can't copy to itself" if self == entry

      target = if entry.is_a? File
        raise "can't copy Dir to File ('#{self}')!" unless options[:override]
        entry.dir
      elsif entry.is_a? Dir
        entry.dir #(name)
      elsif entry.is_a? UniversalEntry
        # raise "can't copy Dir to File ('#{self}')!" if entry.file? and !options[:override]
        entry.dir #.create
      else
        raise "can't copy to unknown Entry!"
      end

      target.create options
      entries do |e|
        if e.is_a? Dir
          e.copy_to target.dir(e.name), options
        elsif e.is_a? File
          e.copy_to target.file(e.name), options
        else
          raise 'internal error'
        end        
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