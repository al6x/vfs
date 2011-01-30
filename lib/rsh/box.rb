module Rsh
  class Box
    attr_accessor :options
    
    def initialize options = {}
      @options = options
      options[:host] ||= 'localhost'
    end
    
    def driver
      unless @driver
        klass = options[:host] == 'localhost' ? Drivers::Local : Drivers::Ssh
        @driver = klass.new options
      end
      @driver
    end
    
    def local_driver
      @local_driver ||= Drivers::Local.new
    end
    
    def bulk &b
      driver.bulk &b
    end
    
    def upload_file from_local_path, to_remote_path, options = {}
      bulk do
        raise "file '#{from_local_path}' not exists!" unless local_driver.file_exist? from_local_path
        if driver.file_exist?(to_remote_path)
          if options[:override]
            driver.remove_file to_remote_path
          else
            raise "file '#{to_remote_path}' already exists!"
          end
        end        
        driver.upload_file from_local_path, to_remote_path
      end
    end
    
    def download_file from_remote_path, to_local_path, options = {}
      bulk do
        raise "file #{from_remote_path} not exists!" unless driver.file_exist?(from_remote_path)
        if local_driver.file_exist? to_local_path
          if options[:override]
            local_driver.remove_file to_local_path
          else
            raise "file #{to_local_path} already exists!" 
          end
        end
        driver.download_file from_remote_path, to_local_path
      end
    end
    
    def remove_file remote_file_path
      bulk do
        raise "file #{remote_file_path} not exists!" unless driver.file_exist? remote_file_path
        driver.remove_file remote_file_path
      end
    end
    
    def exist? remote_path
      driver.exist? remote_path
    end
    
    def file_exist? remote_file_path
      driver.file_exist? remote_file_path
    end
    
    def remove_directory remote_directory_path
      bulk do
        raise "directory #{remote_directory_path} not exists!" unless driver.directory_exist? remote_directory_path
        driver.remove_directory remote_directory_path
      end
    end
    
    def create_directory remote_path, options = {}
      bulk do
        if driver.directory_exist?(remote_path)
          if options[:override]
            driver.remove_directory remote_path
          else
            raise "directory '#{remote_path}' already exists!"
          end
        end
        driver.create_directory remote_path
      end
    end
    
    def directory_exist? remote_path
      driver.directory_exist? remote_path
    end
    
    def upload_directory from_local_path, to_remote_path, options = {}
      bulk do
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
      bulk do
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
      bulk do
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
    
    def bash cmd
      code, stdout, stderr = driver.exec cmd
      raise "can't execute '#{cmd}'!" unless code == 0
      return stdout, stderr
    end
    
    protected
      def method_missing m, *a, &b
        driver.send m, *a, &b
      end
  end
end