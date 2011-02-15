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
          fs.each_entry path do |name, type|
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
          attrs = get
          if attrs[:file]
            raise Error, "can't query entries on File ('#{self}')!"
          elsif attrs[:dir]
            # unknown error
            raise error
          else
            raise Error, "'#{self}' not exist!" if options[:bang]
            []            
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
    
    def empty?
      entries.empty?
    end
    
    
    # 
    # Transfers
    # 
    def copy_to to, options = {}
      options[:bang] = true unless options.include? :bang
      
      raise Error, 'invalid argument' unless to.is_a? Entry
      raise Error, "you can't copy to itself" if self == to

      target = if to.is_a? File
        raise Error, "can't copy Dir to File ('#{self}')!" unless options[:override]
        to.dir
      elsif to.is_a? Dir
        to.dir #(name)
      elsif to.is_a? UniversalEntry
        # raise "can't copy Dir to File ('#{self}')!" if to.file? and !options[:override]
        to.dir #.create
      else
        raise "can't copy to unknown Entry!"
      end
      
      efficient_dir_copy(target, options) || unefficient_dir_copy(target, options)      
      
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
    
    protected
      def unefficient_dir_copy to, options       
        to.create options
        entries options do |e|        
          if e.is_a? Dir
            e.copy_to to.dir(e.name), options
          elsif e.is_a? File
            e.copy_to to.file(e.name), options
          else
            raise 'internal error'
          end        
        end
      end
      
      def efficient_dir_copy to, options
        storage.open_fs do |fs|
          try = 0
          begin                                
            try += 1                    
            self.class.efficient_dir_copy(self, to, options[:override])
          rescue StandardError => error          
            unknown_errors = 0
          
            attrs = get
            if attrs[:file]
              raise Error, "can't copy File as a Dir ('#{self}')!"
            elsif attrs[:dir]
              # some unknown error (but it also maybe caused by to be fixed error in 'to')
              unknown_errors += 1   
            else
              raise Error, "'#{self}' not exist!" if options[:bang]
              return true
            end
            
            attrs = to.get
            if attrs[:file]
              if options[:override]
                to.destroy
              else
                raise Vfs::Error, "entry #{to} already exist!"
              end
            elsif attrs[:dir]
              unknown_errors += 1
              # if options[:override]
              #   to.destroy
              # else
              #   dir_already_exist = true              
              #   # raise Vfs::Error, "entry #{to} already exist!"
              # end
            else # parent not exist
              parent = to.parent
              if parent.exist?
                # some unknown error (but it also maybe caused by already fixed error in 'from')
                unknown_errors += 1
              else
                parent.create(options)        
              end        
            end

            raise error if unknown_errors > 1
            try < 2 ? retry : raise(error)
          end
        end
      end
      
      def self.efficient_dir_copy from, to, override
        from.storage.open_fs{|fs|
          fs.respond_to?(:efficient_dir_copy) and fs.efficient_dir_copy(from, to, override)
        } or
        to.storage.open_fs{|fs|
          fs.respond_to?(:efficient_dir_copy) and fs.efficient_dir_copy(from, to, override)
        }
      end
  end
end