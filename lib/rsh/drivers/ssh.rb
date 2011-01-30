module Rsh
  module Drivers
    class Ssh < Abstract
      def initialize options = {}
        super
        raise "ssh options not provided!" unless options[:ssh]
        raise "invalid ssh options!" unless options[:ssh].is_a?(Hash)
      end
    
      def upload_file from_local_path, to_remote_path
        remote do |ssh, sftp|
          sftp.upload! from_local_path, fix_path(to_remote_path)
        end
      end

      def download_file from_remote_path, to_local_path
        File.open to_local_path, "w" do |out|
          remote do |ssh, sftp|
            sftp.download! fix_path(from_remote_path), out #, :recursive => true          
          end
        end
      end

      def exist? remote_file_path
        remote do |ssh, sftp|
          begin
            fattrs = sftp.stat! fix_path(remote_file_path)
            fattrs.directory? or fattrs.file? or fattrs.symlink?
          rescue Net::SFTP::StatusException
            false
          end
        end
      end
      alias_method :directory_exist?, :exist?
      alias_method :file_exist?, :exist?

      def remove_file remote_file_path
        remote do |ssh, sftp|
          sftp.remove! fix_path(remote_file_path)
        end
      end

      def exec command
        remote do |ssh, sftp|
          # somehow net-ssh doesn't executes ~/.profile, so we need to execute it manually
          # command = ". ~/.profile && #{command}"

          stdout, stderr, code, signal = hacked_exec! ssh, command

          return code, stdout, stderr
        end
      end    
    
      def open_connection      
        ssh_options = self.options[:ssh].clone
        host = options[:host] || raise('host not provided!')
        user = ssh_options.delete(:user) || raise('user not provied!')
        @ssh = Net::SSH.start(host, user, ssh_options)
        @sftp = @ssh.sftp.connect
      end
    
      def close_connection
        @ssh.close
        # @sftp.close not needed
        @ssh, @sftp = nil
      end
    
      def bulk &block
        remote &block
      end
    
      def create_directory path
        remote do |ssh, sftp|          
          sftp.mkdir! path
          # exec "mkdir #{path}"
        end        
      end
    
      def remove_directory path
        exec "rm -r #{path}"
      end
      
      def upload_directory from_local_path, to_remote_path
        remote do |ssh, sftp|
          sftp.upload! from_local_path, fix_path(to_remote_path)
        end
      end
      
      def download_directory from_remote_path, to_local_path
        remote do |ssh, sftp|
          sftp.download! fix_path(from_remote_path), to_local_path, :recursive => true
        end
      end
    
      protected
        def fix_path path
          path.sub(/^\~/, home)
        end
        
        def home
          unless @home
            command = 'cd ~; pwd'
            code, stdout, stderr = exec command
            raise "can't execute '#{command}'!" unless code == 0
            @home = stdout.gsub("\n", '')    
          end
          @home
        end
      
        # taken from here http://stackoverflow.com/questions/3386233/how-to-get-exit-status-with-rubys-netssh-library/3386375#3386375
        def hacked_exec!(ssh, command, &block)
          stdout_data = ""
          stderr_data = ""
          exit_code = nil
          exit_signal = nil
        
          channel = ssh.open_channel do |channel|
            channel.exec(command) do |ch, success|
              raise "could not execute command: #{command.inspect}" unless success

              channel.on_data{|ch2, data| stdout_data << data}
              channel.on_extended_data{|ch2, type, data| stderr_data << data}
              channel.on_request("exit-status"){|ch,data| exit_code = data.read_long}
              channel.on_request("exit-signal"){|ch, data| exit_signal = data.read_long}
            end          
          end  
        
          channel.wait      
        
          [stdout_data, stderr_data, exit_code, exit_signal]
        end
    
        def remote(&block)
          if @ssh
            block.call @ssh, @sftp
          else            
            # Rails.logger.info "Connecting to remote Hadoop #{options[:user]}@#{options[:host]}"          
            begin
              open_connection
              block.call @ssh, @sftp
            ensure
              close_connection
            end
                              
            # Net::SSH.start options[:host], options[:user], :config => true do |ssh|
            #   ssh.sftp.connect do |sftp|
            #     begin
            #       @ssh, @sftp = ssh, sftp
            #       block.call @ssh, @sftp
            #     ensure
            #       @ssh, @sftp = nil
            #     end
            #   end
            # end
          end
        end
    end
  end
end