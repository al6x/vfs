module Vfs
  module Operations
    def open_file path, mode = 'r', &block
      mode = mode.to_s
      open do
        if mode == 'r' or mode == 'r+'
          unless driver.file_exist?(path)
            if mode == 'r+'
              open_file path, 'w'
            else
              raise "file #{path} not exists!" 
            end
          end
          driver.open_file path, mode, &block
        elsif mode == 'w' or mode == 'w+'
          if driver.file_exist?(path)
            if mode == 'w+'
              driver.remove_file path
            else
              raise "file '#{path}' already exists!" 
            end            
          end  
          driver.open_file path, mode, &block
        else
          raise "invalid mode :#{mode}"
        end
      end
    end
        
    def remove_file remote_file_path, options = {}
      open do
        if driver.file_exist? remote_file_path
          driver.remove_file remote_file_path
        else
          raise "file #{remote_file_path} not exists!" unless options[:silent]
        end        
      end
    end
    
    def exist? remote_path
      open do
        driver.exist? remote_path
      end
    end
    
    def file_exist? remote_file_path
      open do
        driver.file_exist? remote_file_path
      end
    end
    
    def remove_directory remote_directory_path, options = {}
      open do
        if driver.directory_exist? remote_directory_path
          driver.remove_directory remote_directory_path
        else
          raise "directory #{remote_directory_path} not exists!" unless options[:silent]
        end
      end
    end
    
    def create_directory remote_path, options = {}
      open do
        if driver.directory_exist?(remote_path)
          if options[:override]
            driver.remove_directory remote_path
            driver.create_directory remote_path
          elsif options[:silent]
            # do nothing
          else
            raise "directory '#{remote_path}' already exists!"
          end
        else
          driver.create_directory remote_path
        end        
      end
    end
    
    def directory_exist? remote_path
      open do
        driver.directory_exist? remote_path
      end
    end
    
    def upload_directory from_local_path, to_remote_path, options = {}
      open do
        raise "directory '#{from_local_path}' not exists!" unless local_driver.directory_exist? from_local_path
        if driver.directory_exist?(to_remote_path)
          if options[:override]
            driver.remove_directory to_remote_path
          else
            raise "directory '#{to_remote_path}' already exists!"
          end
        end        
        driver.upload_directory from_local_path, to_remote_path
      end
    end
    
    def download_directory from_remote_path, to_local_path, options = {}
      open do
        raise "directory #{from_remote_path} not exists!" unless driver.directory_exist?(from_remote_path)
        if local_driver.directory_exist? to_local_path
          if options[:override]
            local_driver.remove_directory to_local_path
          else
            raise "directory #{to_local_path} already exists!" 
          end
        end
        driver.download_directory from_remote_path, to_local_path
      end
    end
    
    def with_tmp_dir &block
      open do
        tmp_dir = driver.generate_tmp_dir_name
        begin   
          remove_directory tmp_dir if directory_exist? tmp_dir
          create_directory tmp_dir
          block.call
        ensure
          remove_directory tmp_dir if directory_exist? tmp_dir
        end
      end
    end
    
    def bash cmd, options = {}
      ignore_stderr = options.delete :ignore_stderr
      raise "invalid options :#{options.keys.join(', :')}" unless options.empty?
    
      code, stdout, stderr = exec cmd
      unless code == 0
        puts stdout
        puts stderr
        raise "can't execute '#{cmd}'!" 
      end
      unless stderr.empty? or ignore_stderr
        puts stderr
        raise "stderr not empty for '#{cmd}'!"
      end
      stdout + stderr
    end
    
    def exec cmd
      open do
        driver.exec cmd
      end
    end
    
    def home path = nil
      open do
        @home ||= bash('cd ~; pwd').gsub("\n", '')    
        "#{@home}#{path}"
      end
    end    
    
    def generate_tmp_dir_name
      open do
        driver.generate_tmp_dir_name
      end
    end
    
    def inspect
      "<Box: #{options[:host]}>"
    end
    alias_method :to_s, :inspect
  end
end